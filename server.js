require('dotenv').config();

const express = require('express');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const fs = require('fs');
const csv = require('csv-parser');
const iconv = require('iconv-lite'); // 한글 깨짐 방지
const app = express();
const port = 3000;

const db = require('./db')

app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET;
const CAREERNET_API_KEY = process.env.CAREERNET_API_KEY;
const DATA_GO_KR_API_KEY = process.env.DATA_GO_KR_API_KEY;
const NAVER_CLIENT_ID = process.env.NAVER_CLIENT_ID;
const NAVER_CLIENT_SECRET = process.env.NAVER_CLIENT_SECRET;

let allUniversities = [];
let koreaAdmissionData = {};
// -----------------------------------API라우트------------------------------------------- //

app.post('/api/auth/kakao', async (req, res) => {
    const { accessToken } = req.body; 

    if (!accessToken) {
        return res.status(400).json({ message: '카카오 토큰이 필요합니다.' });
    }

    try {
        const kakaoResponse = await axios.get('https://kapi.kakao.com/v2/user/me', {
            headers: { 'Authorization': `Bearer ${accessToken}` }
        });

        const kakaoId = kakaoResponse.data.id.toString();
        const nickname = kakaoResponse.data.properties.nickname;
        const email = kakaoResponse.data.kakao_account ? kakaoResponse.data.kakao_account.email : null;
        const [rows] = await db.query('SELECT * FROM users WHERE kakao_id = ?', [kakaoId]);
        let user = rows[0];
        
        if (!user) {
            const [insertResult] = await db.query(
                'INSERT INTO users (kakao_id, name, email) VALUES (?, ?, ?)',
                [kakaoId, nickname, email]
            );
            const [newRows] = await db.query('SELECT * FROM users WHERE user_id = ?', [insertResult.insertId]);
            user = newRows[0];
        }

        const appToken = jwt.sign({ userId: user.user_id }, JWT_SECRET, { expiresIn: '365d' });
        res.status(200).json({ token: appToken });

    } catch (error) {
        console.error("카카오 인증 또는 DB 오류:", error.response ? error.response.data : error.message);
        res.status(500).json({ message: '인증 처리 중 서버에서 오류가 발생했습니다.' });
    }
});

app.get('/api/home', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [userRows] = await db.query('SELECT name FROM users WHERE user_id = ?', [userId]);
        if (userRows.length === 0) return res.status(404).json({ message: '사용자 없음' });
        const user = userRows[0];
        const [scheduleRows] = await db.query(
            'SELECT DATE_FORMAT(start_time, "%H:%i") as startTime, title, type FROM schedules WHERE user_id = ? AND DATE(start_time) = CURDATE() ORDER BY start_time ASC',
            [userId]
        );
        const [gradeRows] = await db.query(
            'SELECT subject_name as subjectName, score, grade_level as gradeLevel FROM grades WHERE user_id = ? ORDER BY exam_date DESC LIMIT 2',
            [userId]
        );
        const [notiRows] = await db.query(
            `SELECT message as content, 
                    DATE_FORMAT(created_at, '%m/%d %H:%i') as createdAt 
             FROM notifications 
             WHERE user_id = ? 
             ORDER BY created_at DESC 
             LIMIT 2`,
            [userId]
        );
        const [myUnivs] = await db.query('SELECT universityName FROM user_universities WHERE userId = ?', [userId]);
        let newsItems = [];
        const searchKeyword = myUnivs.length > 0 ? myUnivs[0].universityName : "대입";
        const naverResults = await searchNaverNews(searchKeyword);
        newsItems = naverResults.slice(0, 2).map((item, index) => ({
            universityName: searchKeyword,
            title: item.title.replace(/<[^>]+>/g, '').replace(/&quot;/g, '"'),
            isNew: index === 0, 
            content: item.description.replace(/<[^>]+>/g, '').replace(/&quot;/g, '"')
        }));
        const homeData = {
            user: { name: user.name },
            todaySchedules: scheduleRows,
            recentGrades: gradeRows,
            notifications: notiRows,
            universityNews: newsItems
        };
        
        res.json(homeData);

    } catch (error) {
        if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("홈 데이터 조회 중 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

app.get('/api/planner', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [todaySchedules] = await db.query(
            'SELECT schedule_id as id, DATE_FORMAT(start_time, "%H:%i") as time, title, "새로 추가된 일정" as subtitle, type as tag, "blue" as color FROM schedules WHERE user_id = ? AND DATE(start_time) = CURDATE() ORDER BY start_time ASC',
            [userId]
        );

        const [deadlines] = await db.query(
            'SELECT schedule_id as id, title, DATE_FORMAT(start_time, "%Y-%m-%d") as date, "높음" as priority, "red" as color FROM schedules WHERE user_id = ? AND DATE(start_time) > CURDATE() ORDER BY start_time ASC LIMIT 5',
            [userId]
        );
        
        const plannerData = {
            todaySchedules: todaySchedules,
            deadlines: deadlines
        };
        res.json(plannerData);

    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("플래너 데이터 조회 중 DB 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

app.post('/api/schedules', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const { title, date, type, priority } = req.body;
        
        await db.query(
            'INSERT INTO schedules (user_id, title, start_time, type, priority) VALUES (?, ?, ?, ?, ?)',
            [userId, title, date, type, priority] 
        );

        res.status(201).json({ message: "일정이 성공적으로 추가되었습니다." });

    } catch (error) {
         if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("일정 추가 중 DB 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

app.post('/api/grades', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const { examName, subjectName, score, gradeLevel, examDate, examType } = req.body;
        
        await db.query(
            'INSERT INTO grades (user_id, exam_type, exam_name, subject_name, score, grade_level, exam_date) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [userId, examType, examName, subjectName, score, gradeLevel, examDate]
        );

        res.status(201).json({ message: "성적이 성공적으로 추가되었습니다." });

    } catch (error) {
         if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("성적 추가 중 DB 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

app.get('/api/grades/internal', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [rows] = await db.query(
            'SELECT exam_name, subject_name, score, exam_date FROM grades WHERE user_id = ? AND exam_type = ? ORDER BY exam_date ASC',
            [userId, '내신']
        );

        const gradesBySubject = {};
        rows.forEach(row => {
            if (!gradesBySubject[row.subject_name]) {
                gradesBySubject[row.subject_name] = [];
            }
            gradesBySubject[row.subject_name].push({ 
                month: row.exam_name, 
                score: row.score,
                date: row.exam_date
            });
        });

        const chartData = Object.keys(gradesBySubject).map(subject => ({
            subject: subject,
            scores: gradesBySubject[subject]
        }));
        
        res.json(chartData);

    } catch (error) {
        if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("내신 성적 조회 중 DB 오류:", error);
        res.status(500).json({ message: '내신 성적 조회 중 서버 오류가 발생했습니다.' });
    }
});

app.get('/api/grades/mock', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [rows] = await db.query(
            'SELECT DATE_FORMAT(exam_date, "%Y-%m") as month, subject_name, score FROM grades WHERE user_id = ? AND exam_type = ? ORDER BY exam_date ASC',
            [userId, '모의고사']
        );
        
        const mockExamScores = rows.map(row => ({
            month: row.month,
            subject: row.subject_name,
            score: row.score,
            color: row.subject_name === "국어" ? "orange" : (row.subject_name === "수학" ? "blue" : "green")
        }));
        
        res.json(mockExamScores);

    } catch (error) {
        if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("모의고사 성적 조회 중 DB 오류:", error);
        res.status(500).json({ message: '모의고사 성적 조회 중 서버 오류가 발생했습니다.' });
    }
});

app.get('/api/grades/distribution', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [rows] = await db.query(
            'SELECT grade_level, COUNT(*) as count FROM grades WHERE user_id = ? AND exam_type = "내신" AND grade_level IS NOT NULL GROUP BY grade_level',
            [userId]
        );
        res.json(rows);
    } catch (error) {
        if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("등급 분포 조회 중 DB 오류:", error);
        res.status(500).json({ message: '등급 분포 조회 중 서버 오류가 발생했습니다.' });
    }
});

app.get('/api/grades/mock/recent', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        const [rows] = await db.query(
            `SELECT exam_name, exam_date, subject_name, score
             FROM grades
             WHERE user_id = ? AND exam_type = '모의고사'
             ORDER BY exam_date DESC, subject_name ASC`,
            [userId]
        );
        const results = {};
        rows.forEach(row => {
            if (!results[row.exam_name]) {
                results[row.exam_name] = {
                    examName: row.exam_name,
                    examDate: row.exam_date,
                    scores: {}
                };
            }
            results[row.exam_name].scores[row.subject_name] = row.score;
        });
        
        const recentResults = Object.values(results);
        res.json(recentResults);

    } catch (error) {
        if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("최근 모의고사 조회 중 DB 오류:", error);
        res.status(500).json({ message: '최근 모의고사 조회 중 서버 오류가 발생했습니다.' });
    }
});

app.get('/api/extracurricular', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [activityStats] = await db.query(
            'SELECT type, SUM(hours) as totalHours FROM activities WHERE user_id = ? GROUP BY type',
            [userId]
        );
        const [readingStatsResult] = await db.query(
            'SELECT COUNT(*) as totalBooks, COALESCE(SUM(has_report = 1), 0) as totalReports FROM reading_activities WHERE user_id = ?',
            [userId]
        );
        const [readingList] = await db.query(
            'SELECT title, author, DATE_FORMAT(read_date, "%Y.%m.%d") as readDate FROM reading_activities WHERE user_id = ? ORDER BY read_date DESC LIMIT 2',
            [userId]
        );
        let readingStats = { totalBooks: 0, totalReports: 0 }; 
        if (readingStatsResult[0]) {
            readingStats = {
                totalBooks: parseInt(readingStatsResult[0].totalBooks, 10),
                totalReports: parseInt(readingStatsResult[0].totalReports, 10)
            };
        }
        
        const formattedActivities = activityStats.map(activity => ({
            type: activity.type,
            totalHours: parseInt(activity.totalHours, 10)
        }));

        const responseData = {
            activities: formattedActivities, 
            readingStats: readingStats,      
            readingList: readingList
        };
        res.json(responseData);
    } catch (error) {
        if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("비교과 데이터 조회 중 DB 오류:", error);
        res.status(500).json({ message: '비교과 데이터 조회 중 서버 오류가 발생했습니다.' });
    }
});

app.post('/api/activities', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const { type, title, hours, activityDate } = req.body;
        await db.query(
            'INSERT INTO activities (user_id, type, title, hours, activity_date) VALUES (?, ?, ?, ?, ?)',
            [userId, type, title, hours, activityDate] 
        );
        res.status(201).json({ message: "활동이 추가되었습니다." });

    } catch (error) {
         if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("활동 추가 중 DB 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

app.post('/api/reading', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const { title, author, readDate, hasReport } = req.body;
        await db.query(
            'INSERT INTO reading_activities (user_id, title, author, read_date, has_report) VALUES (?, ?, ?, ?, ?)',
            [userId, title, author, readDate, hasReport]
        );
        res.status(201).json({ message: "독서 기록이 추가되었습니다." });

    } catch (error) {
         if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("독서 기록 추가 중 DB 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

async function getUserAverageGrade(userId) {
    try {
        const [rows] = await db.query(
            `SELECT grade_level FROM grades 
             WHERE user_id = ? 
             AND exam_type = '내신' 
             AND grade_level IS NOT NULL`, 
            [userId]
        );
        if (rows.length === 0) return 0;
        const total = rows.reduce((sum, row) => {
            const grade = parseFloat(row.grade_level);
            return isNaN(grade) ? sum : sum + grade;
        }, 0);
        const average = total / rows.length;
        const result = Math.round(average * 100) / 100;
        return result;

    } catch (error) {
        console.error("내신 평균 계산 실패:", error);
        return 0;
    }
}

app.get('/api/university/schedule', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);

        const sql = `
            SELECT 
                id, 
                DATE_FORMAT(event_date, '%m/%d') AS dateLabel, 
                title, 
                tag, 
                color,
                DATEDIFF(event_date, CURDATE()) AS dDayNum
            FROM 
                common_schedules
            WHERE 
                event_date >= CURDATE()
            ORDER BY 
                event_date ASC;
        `;
        
        const [rows] = await db.query(sql);
        const mainSchedule = rows.map(row => ({
            id: row.id,
            dateLabel: row.dateLabel,
            title: row.title,
            tag: row.tag,
            color: row.color
        }));

        const dDayAlerts = rows
            .filter(row => row.dDayNum >= 0) 
            .slice(0, 2) 
            .map(row => ({
                id: row.id,
                dDay: `D-${row.dDayNum}`,
                title: row.title,
                color: row.color
            }));
        const responseData = {
            mainSchedule: mainSchedule,
            dDayAlerts: dDayAlerts
        };
        
        res.json(responseData);
    } catch (error) {
        console.error("입시 일정 조회 중 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

function loadCsvData() {
    const results = [];
    
    // [수정] 인코딩 변환 없이 바로 읽기 (UTF-8)
    fs.createReadStream('university_data.csv')
        .pipe(csv()) 
        .on('data', (data) => {
            if (results.length === 0) {
                // BOM 제거 로직 (기존 유지)
                const firstKey = Object.keys(data)[0];
                if (firstKey.includes('조사년도') && firstKey !== '조사년도') {
                     data['조사년도'] = data[firstKey]; 
                }
            }
            results.push(data);
        })
        .on('end', () => {
            allUniversities = results
                .filter(row => {
                    // 1. 학교명이 있고, 폐지되지 않은 학과만 선택
                    if (!row['학교명'] || row['학과상태'] === '폐지') return false;

                    // ⭐️ [추가] 대학원 제외 로직 ⭐️
                    // '대학구분'이 '대학원' 또는 '대학원대학'이면 제외합니다.
                    // '학교구분'에 '대학원' 글자가 포함되어 있어도 제외합니다 (일반대학원, 특수대학원 등)
                    if (row['대학구분'] === '대학원' || row['대학구분'] === '대학원대학') return false;
                    if (row['학교구분'] && row['학교구분'].includes('대학원')) return false;

                    return true;
                })
                .map(row => ({
                    univName: row['학교명'],       
                    deptName: row['학부_과(전공)명'], 
                    location: row['지역'],         
                    category: row['학교구분']       
                }));
            
            console.log(`✅ CSV 데이터 로드 완료! (대학원 제외) 유효한 학과 정보: ${allUniversities.length}개`);
            
            if (allUniversities.length > 0) {
                console.log("✅ 매핑 성공 (첫 번째 데이터):", allUniversities[0]);
            }
        });
}
loadCsvData();

function loadAdmissionData() {
    const results = [];
    fs.createReadStream('korea_univ_recommendation.csv')
        .pipe(csv({ headers: false })) 
        .on('data', (data) => results.push(data))
        .on('end', () => {
            results.forEach(row => {
                let deptName = row['1']; 
                let cut70 = parseFloat(row['2']);

                if (deptName && !isNaN(cut70)) {
                    deptName = deptName.replace(/\s+/g, '').trim();
                    const estimatedCut50 = parseFloat((cut70 - 0.15).toFixed(2));
                    koreaAdmissionData[deptName] = {
                        cut50: estimatedCut50,
                        cut70: cut70
                    };
                }
            });
            const sampleKeys = Object.keys(koreaAdmissionData).slice(0, 5);
        });
}
loadAdmissionData();

app.get('/api/university/search', (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    const { query } = req.query;

    if (!query) {
        return res.json([]);
    }

    try {
        jwt.verify(token, JWT_SECRET);
        const matched = allUniversities.filter(u => u.univName && u.univName.includes(query));
        const uniqueList = [];
        const seenNames = new Set();

        matched.forEach(u => {
            if (!seenNames.has(u.univName)) {
                seenNames.add(u.univName);
                uniqueList.push({
                    name: u.univName,
                    location: u.location
                });
            }
        });
        res.json(uniqueList.slice(0, 30));
    } catch (error) {
        console.error("검색 중 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.get('/api/university/departments', (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    const { univName } = req.query;
    if (!univName) return res.status(400).json({ message: '대학 이름이 필요합니다.' });

    try {
        jwt.verify(token, JWT_SECRET);

        const departments = allUniversities
            .filter(u => u.univName === univName)
            .map((u, index) => ({
                schoolName: u.univName,
                majorName: u.deptName,
                majorSeq: String(index)
            }));
        departments.sort((a, b) => a.majorName.localeCompare(b.majorName));

        res.json(departments);

    } catch (error) {
        console.error("학과 조회 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.get('/api/university/news', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    let userId;
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        userId = decoded.userId;
    } catch (error) {
        return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
    }

    try {
        const [myUniversities] = await db.query(
            'SELECT universityName FROM user_universities WHERE userId = ?', 
            [userId]
        );
        const commonKeywords = ['입시', '수능', '대입'];
        const userKeywords = myUniversities.map(uni => uni.universityName);
        const allKeywords = [...userKeywords, ...commonKeywords];
        const searchPromises = allKeywords.map(keyword => 
            searchNaverNews(keyword)
        );
        const allResults = await Promise.all(searchPromises);
        const allItems = allResults.flat();
        const uniqueItems = Array.from(
            new Map(allItems.map(item => [item.link, item])).values()
        );
        res.json(uniqueItems);
    } catch (error) {
        console.error("뉴스 조회 중 오류:", error.message);
        res.status(500).json({ message: '뉴스 조회 중 서버 오류가 발생했습니다.' });
    }
});

async function searchNaverNews(query) {
    const apiUrl = 'https://openapi.naver.com/v1/search/news.json';
    try {
        const response = await axios.get(apiUrl, {
            params: {
                query: query + " 입시",
                display: 10, 
                sort: 'sim'  
            },
            headers: {
                'X-Naver-Client-Id': NAVER_CLIENT_ID,
                'X-Naver-Client-Secret': NAVER_CLIENT_SECRET
            }
        });
        return response.data.items || [];

    } catch (error) {
        if (error.response) {
            console.error(`[네이버 API] "${query}" 검색 실패 (HTTP ${error.response.status}):`, error.response.data);
        } else {
            console.error(`[네이버 API] "${query}" 요청 실패:`, error.message);
        }
        return [];
    }
}

app.get('/api/university/my', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const myAvgGrade = await getUserAverageGrade(userId);
        const [rows] = await db.query('SELECT * FROM user_universities WHERE userId = ?', [userId]);
        const myUniversities = rows.map(row => {
            let status = "appropriate"; 
            let requiredScore = 0;
            const univName = row.universityName;
            const myDeptName = row.department.replace(/\s+/g, '').trim(); 
            if (univName.includes("고려대")) {
                let data = koreaAdmissionData[myDeptName];
                if (!data) {
                    const foundKey = Object.keys(koreaAdmissionData).find(csvKey => {
                        return myDeptName.includes(csvKey) || csvKey.includes(myDeptName);
                    });
                    if (foundKey) {
                        data = koreaAdmissionData[foundKey];
                    }
                }

                if (data) {
                    requiredScore = data.cut70;
                    if (myAvgGrade > 0) {
                        if (myAvgGrade <= data.cut50) status = "safe";
                        else if (myAvgGrade <= data.cut70) status = "appropriate";
                        else status = "challenging";
                    }
                } else {
                     console.log(`❌ [매칭 실패] DB에 있는 '${myDeptName}'를 CSV에서 못 찾았습니다.`);
                }
            }

            return {
                id: row.id,
                universityName: univName,
                department: row.department,
                major: row.major || "",
                myScore: myAvgGrade,
                requiredScore: requiredScore,
                deadline: row.deadline || "2025-09-13",
                status: status, 
                location: row.location || "",
                competitionRate: row.competitionRate || "15.4:1"
            };
        });

        res.json(myUniversities);

    } catch (error) {
        console.error("내 대학 조회 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.post('/api/university/my', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);
    const { universityName, location, department, majorSeq } = req.body;
    
    if (!universityName || !department) {
        return res.status(400).json({ message: '대학명과 학과명은 필수입니다.' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [result] = await db.query(
            `INSERT INTO user_universities 
             (userId, universityName, location, department) 
             VALUES (?, ?, ?, ?)`,
            [userId, universityName, location, department]
        );

        res.status(201).json({ 
            message: '대학 추가 성공', 
            insertedId: result.insertId 
        });

    } catch (error) {
         if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("'내 대학' 추가 중 DB 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.post('/api/counseling/questions', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const { question, category } = req.body; 

        if (!question) return res.status(400).json({ message: "질문 내용을 입력해주세요." });
        await db.query(
            'INSERT INTO counseling_questions (user_id, question, category) VALUES (?, ?, ?)',
            [userId, question, category || '진학상담']
        );
        res.status(201).json({ message: "질문이 등록되었습니다." });
    } catch (error) {
        console.error("질문 등록 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.get('/api/counseling/questions', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [rows] = await db.query(
            `SELECT id, category, question, answer, counselor_name, status, 
                    DATE_FORMAT(created_at, '%Y-%m-%d') as date 
             FROM counseling_questions 
             WHERE user_id = ? 
             ORDER BY created_at DESC`,
            [userId]
        );
        
        res.json(rows);

    } catch (error) {
        console.error("질문 목록 조회 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.get('/api/admin/questions', async (req, res) => {
    try {
        const [rows] = await db.query(
            `SELECT q.id, q.category, q.question, q.answer, q.status, q.created_at, u.name as userName
             FROM counseling_questions q
             JOIN users u ON q.user_id = u.user_id
             ORDER BY q.status = 'waiting' DESC, q.created_at DESC`
        );
        res.json(rows);
    } catch (error) {
        console.error("관리자 질문 조회 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.put('/api/admin/questions/:id', async (req, res) => {
    const questionId = req.params.id;
    const { answer, counselorName } = req.body;

    try {
        await db.query(
            `UPDATE counseling_questions 
             SET answer = ?, counselor_name = ?, status = 'answered', answered_at = NOW()
             WHERE id = ?`,
            [answer, counselorName, questionId]
        );
        const [rows] = await db.query('SELECT user_id FROM counseling_questions WHERE id = ?', [questionId]);
        
        if (rows.length > 0) {
            const studentId = rows[0].user_id;
            await db.query(
                `INSERT INTO notifications (user_id, type, title, message) 
                 VALUES (?, 'counseling', '진학 상담 답변이 도착했습니다', '등록하신 질문에 선생님이 답변을 남겼습니다.')`,
                [studentId]
            );
        }

        res.json({ message: "답변 및 알림 등록 완료." });
    } catch (error) {
        console.error("답변 등록 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.get('/api/notifications', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const [rows] = await db.query(
            `SELECT id, type, title, message, 
                    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') as time 
             FROM notifications 
             WHERE user_id = ? 
             ORDER BY created_at DESC`,
            [userId]
        );
        res.json(rows);
    } catch (error) {
        console.error("알림 조회 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

app.put('/api/admin/questions/:id', async (req, res) => {
    const questionId = req.params.id;
    const { answer, counselorName } = req.body;

    try {
        await db.query(
            `UPDATE counseling_questions 
             SET answer = ?, counselor_name = ?, status = 'answered', answered_at = NOW()
             WHERE id = ?`,
            [answer, counselorName, questionId]
        );
        res.json({ message: "답변이 등록되었습니다." });
    } catch (error) {
        console.error("답변 등록 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

const path = require('path');
app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'admin.html'));
});

app.listen(port, '0.0.0.0', () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});