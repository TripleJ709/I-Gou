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

// let users = [{ id: 1, name: 'OOO', kakaoId: '12345' }];

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
        const email = kakaoResponse.data.kakao_account ? kakaoResponse.data.kakao_account.email : null; // 이메일 없는 경우 처리

        // [수정] DB를 사용하도록 변경 (가짜 users 배열 대신)
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

        // 1. 사용자 이름 조회
        const [userRows] = await db.query('SELECT name FROM users WHERE user_id = ?', [userId]);
        if (userRows.length === 0) return res.status(404).json({ message: '사용자 없음' });
        const user = userRows[0];

        // 2. 오늘의 일정 조회
        const [scheduleRows] = await db.query(
            'SELECT DATE_FORMAT(start_time, "%H:%i") as startTime, title, type FROM schedules WHERE user_id = ? AND DATE(start_time) = CURDATE() ORDER BY start_time ASC',
            [userId]
        );

        // 3. 최근 성적 조회
        const [gradeRows] = await db.query(
            'SELECT subject_name as subjectName, score, grade_level as gradeLevel FROM grades WHERE user_id = ? ORDER BY exam_date DESC LIMIT 2',
            [userId]
        );
        
        // ⭐️ [수정 4] 알림 (DB 연동) - notifications 테이블에서 최근 2개
        const [notiRows] = await db.query(
            `SELECT message as content, 
                    DATE_FORMAT(created_at, '%m/%d %H:%i') as createdAt 
             FROM notifications 
             WHERE user_id = ? 
             ORDER BY created_at DESC 
             LIMIT 2`,
            [userId]
        );

        // ⭐️ [수정 5] 대학 뉴스 (Naver API 연동) - 내 대학 중 1개 골라서 검색
        const [myUnivs] = await db.query('SELECT universityName FROM user_universities WHERE userId = ?', [userId]);
        
        let newsItems = [];
        
        // 관심 대학이 있으면 그 대학 뉴스를, 없으면 '대입' 뉴스를 보여줌
        const searchKeyword = myUnivs.length > 0 ? myUnivs[0].universityName : "대입";
        
        // searchNaverNews 함수는 이전에 server.js 하단에 만들어둔 것을 사용
        const naverResults = await searchNaverNews(searchKeyword);
        
        // 상위 2개만 추려서 포맷팅
        newsItems = naverResults.slice(0, 2).map((item, index) => ({
            universityName: searchKeyword,
            title: item.title.replace(/<[^>]+>/g, '').replace(/&quot;/g, '"'),
            isNew: index === 0, 
            content: item.description.replace(/<[^>]+>/g, '').replace(/&quot;/g, '"')
        }));

        // 최종 응답 데이터
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
    // 1. JWT 인증
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // 2. DB에서 '내신' 성적의 등급별(grade_level) 개수(count)를 조회
        // grade_level이 NULL이 아닌 것만, grade_level로 그룹화하여 개수를 셈
        const [rows] = await db.query(
            'SELECT grade_level, COUNT(*) as count FROM grades WHERE user_id = ? AND exam_type = "내신" AND grade_level IS NOT NULL GROUP BY grade_level',
            [userId]
        );
        
        // 3. 조회된 데이터를 JSON으로 응답
        // 예: [{"grade_level": "1등급", "count": 2}, {"grade_level": "2등급", "count": 3}]
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

        // 데이터를 시험별로 재가공
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

// [신규] 비교과 탭 전체 데이터 조회 API
app.get('/api/extracurricular', async (req, res) => {
    // 1. JWT 토큰으로 사용자 인증
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // 2. 창의적 체험활동 조회 (유형별 시간 합계)
        const [activityStats] = await db.query(
            'SELECT type, SUM(hours) as totalHours FROM activities WHERE user_id = ? GROUP BY type',
            [userId]
        );
        
        // 3. 독서 활동 통계 조회 (읽은 책, 감상문 개수)
        const [readingStatsResult] = await db.query(
            'SELECT COUNT(*) as totalBooks, COALESCE(SUM(has_report = 1), 0) as totalReports FROM reading_activities WHERE user_id = ?',
            [userId]
        );
        
        // 4. 최근 독서 목록 조회
        const [readingList] = await db.query(
            'SELECT title, author, DATE_FORMAT(read_date, "%Y.%m.%d") as readDate FROM reading_activities WHERE user_id = ? ORDER BY read_date DESC LIMIT 2',
            [userId]
        );

        // --- [⭐️ 핵심 수정 ⭐️] ---
        // 5. 데이터 조합 및 타입 변환
        
        // DB에서 가져온 값이 문자열("0")일 수 있으므로, parseInt를 사용해 숫자로 변환합니다.
        let readingStats = { totalBooks: 0, totalReports: 0 }; // 기본값
        if (readingStatsResult[0]) {
            readingStats = {
                totalBooks: parseInt(readingStatsResult[0].totalBooks, 10),
                totalReports: parseInt(readingStatsResult[0].totalReports, 10)
            };
        }
        
        // totalHours도 문자열일 수 있으므로 숫자로 변환합니다.
        const formattedActivities = activityStats.map(activity => ({
            type: activity.type,
            totalHours: parseInt(activity.totalHours, 10)
        }));

        const responseData = {
            activities: formattedActivities, // 숫자로 변환된 데이터
            readingStats: readingStats,      // 숫자로 변환된 데이터
            readingList: readingList
        };
        // --- [수정 끝] ---
        
        res.json(responseData);

    } catch (error) {
        // 6. 에러 처리
        if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("비교과 데이터 조회 중 DB 오류:", error);
        res.status(500).json({ message: '비교과 데이터 조회 중 서버 오류가 발생했습니다.' });
    }
});

// [신규] 창의적 체험활동 추가 API
app.post('/api/activities', async (req, res) => {
    // 1. JWT 토큰으로 사용자 인증
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        
        // 2. iOS 앱이 보낸 데이터
        const { type, title, hours, activityDate } = req.body;
        
        // 3. DB에 INSERT
        await db.query(
            'INSERT INTO activities (user_id, type, title, hours, activity_date) VALUES (?, ?, ?, ?, ?)',
            [userId, type, title, hours, activityDate] // activityDate는 'YYYY-MM-DD' 형식이어야 함
        );
        res.status(201).json({ message: "활동이 추가되었습니다." });

    } catch (error) {
        // 4. 에러 처리
         if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("활동 추가 중 DB 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

// [신규] 독서 활동 추가 API
app.post('/api/reading', async (req, res) => {
    // 1. JWT 토큰으로 사용자 인증
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        
        // 2. iOS 앱이 보낸 데이터
        const { title, author, readDate, hasReport } = req.body;
        
        // 3. DB에 INSERT
        await db.query(
            'INSERT INTO reading_activities (user_id, title, author, read_date, has_report) VALUES (?, ?, ?, ?, ?)',
            [userId, title, author, readDate, hasReport]
        );
        res.status(201).json({ message: "독서 기록이 추가되었습니다." });

    } catch (error) {
        // 4. 에러 처리
         if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("독서 기록 추가 중 DB 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

// [수정] 사용자의 평균 내신 등급 계산 함수 (NULL 처리 + 등급 사용)
async function getUserAverageGrade(userId) {
    try {
        // 1. exam_type이 '내신'이면서
        // 2. ⭐️ grade_level이 NULL이 아닌 것만 가져옵니다. (SQL에서 미리 거름)
        const [rows] = await db.query(
            `SELECT grade_level FROM grades 
             WHERE user_id = ? 
             AND exam_type = '내신' 
             AND grade_level IS NOT NULL`, 
            [userId]
        );

        // 내신 성적이 하나도 없으면 0 반환
        if (rows.length === 0) return 0;

        // 3. 평균 계산
        // grade_level을 숫자로 변환해서 더함
        const total = rows.reduce((sum, row) => {
            const grade = parseFloat(row.grade_level);
            // 만약 grade가 NaN이면(혹시 모를 에러 방지) 0으로 취급하거나 제외
            return isNaN(grade) ? sum : sum + grade;
        }, 0);

        const average = total / rows.length;
        
        // 소수점 둘째자리까지 반올림 (예: 1.56)
        const result = Math.round(average * 100) / 100;
        
        console.log(`🧮 성적 계산: 총합 ${total} / 과목수 ${rows.length} = 평균 ${result}`);
        return result;

    } catch (error) {
        console.error("내신 평균 계산 실패:", error);
        return 0;
    }
}

app.get('/api/university/schedule', async (req, res) => {
    // 1. JWT 인증
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

        // 4. iOS 앱이 기대하는 JSON 구조로 가공
        
        // 4-1. '주요 입시 일정' 목록 생성
        const mainSchedule = rows.map(row => ({
            id: row.id,
            dateLabel: row.dateLabel,
            title: row.title,
            tag: row.tag,
            color: row.color
        }));

        // 4-2. 'D-Day 알림' 목록 생성 (가장 가까운 2개만 선택)
        const dDayAlerts = rows
            .filter(row => row.dDayNum >= 0) // D-Day가 0일 이상 남은 것만
            .slice(0, 2) // 그 중 상위 2개만
            .map(row => ({
                id: row.id,
                dDay: `D-${row.dDayNum}`,
                title: row.title,
                color: row.color
            }));

        // 5. 최종 데이터 조합하여 응답
        const responseData = {
            mainSchedule: mainSchedule,
            dDayAlerts: dDayAlerts
        };
        
        res.json(responseData);
    } catch (error) {
        // ... (JWT 에러 및 DB 에러 처리) ...
        console.error("입시 일정 조회 중 오류:", error);
        res.status(500).json({ message: '서버 오류가 발생했습니다.' });
    }
});

function loadCsvData() {
    const results = [];
    
    // [수정] 인코딩 변환(.pipe(iconv...))을 제거했습니다.
    // csv-parser는 기본적으로 UTF-8을 지원합니다.
    fs.createReadStream('university_data.csv')
        .pipe(csv()) 
        .on('data', (data) => {
            // 디버깅용 로그 (처음 한 번만 출력)
            if (results.length === 0) {
                console.log("🔍 [UTF-8 확인] 첫 번째 데이터:", data);
                
                // [추가] 혹시 BOM(파일 앞의 특수문자) 때문에 첫 컬럼명이 깨질 경우를 대비
                // 첫 번째 키(Key)가 '조사년도'가 아니라 이상한 특수문자가 붙어있다면?
                const firstKey = Object.keys(data)[0];
                if (firstKey.includes('조사년도') && firstKey !== '조사년도') {
                     console.log("⚠️ BOM 문자 발견. 키 이름을 수정합니다.");
                     data['조사년도'] = data[firstKey]; // 올바른 키로 복사
                }
            }
            results.push(data);
        })
        .on('end', () => {
            allUniversities = results
                .filter(row => {
                    // 데이터가 유효한지 확인
                    return row['학교명'] && row['학과상태'] !== '폐지';
                })
                .map(row => ({
                    univName: row['학교명'],       
                    deptName: row['학부_과(전공)명'], 
                    location: row['지역'],         
                    category: row['학교구분']       
                }));
            
            console.log(`✅ CSV 데이터 로드 완료! 유효한 학과 정보: ${allUniversities.length}개`);
            
            if (allUniversities.length > 0) {
                console.log("✅ 매핑 성공 (첫 번째 데이터):", allUniversities[0]);
            }
        });
}

// 서버 시작 시 데이터 로드 실행
loadCsvData();

function loadAdmissionData() {
    const results = [];
    fs.createReadStream('korea_univ_recommendation.csv')
        .pipe(csv({ headers: false })) 
        .on('data', (data) => results.push(data))
        .on('end', () => {
            results.forEach(row => {
                // index 1: 학과명, index 2: 70% 컷
                let deptName = row['1']; 
                let cut70 = parseFloat(row['2']);

                if (deptName && !isNaN(cut70)) {
                    // ⭐️ [핵심] 공백(띄어쓰기)을 모두 없애서 저장 (매칭 확률 높이기)
                    // 예: "기계 공학과" -> "기계공학과"
                    deptName = deptName.replace(/\s+/g, '').trim();

                    // 50% 컷 추정 (70% 컷 - 0.15)
                    const estimatedCut50 = parseFloat((cut70 - 0.15).toFixed(2));

                    koreaAdmissionData[deptName] = {
                        cut50: estimatedCut50,
                        cut70: cut70
                    };
                }
            });
            console.log(`✅ 고려대 입시 데이터 로드 완료! (${Object.keys(koreaAdmissionData).length}개 학과)`);
            
            // [디버깅] CSV에 있는 학과 이름 5개만 샘플로 출력해보기
            const sampleKeys = Object.keys(koreaAdmissionData).slice(0, 5);
            console.log("👉 CSV 포함 학과(샘플):", sampleKeys);
        });
}

loadAdmissionData();

// --------------------------------------------------------------------------
// 1. 대학 검색 API (CSV 기반) - 최종 수정본
// --------------------------------------------------------------------------
app.get('/api/university/search', (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    const { query } = req.query;
    console.log(`🔍 [CSV 검색] 요청: ${query}`);

    if (!query) {
        return res.json([]);
    }

    try {
        jwt.verify(token, JWT_SECRET);

        // 1. 검색어(query)가 포함된 학교 필터링 (안전하게 u.univName 확인)
        const matched = allUniversities.filter(u => u.univName && u.univName.includes(query));
        
        // 2. 중복 제거 (학교명 기준)
        const uniqueList = []; // 변수명을 uniqueList로 짧게 변경했습니다.
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

        // 3. 결과 반환 (최대 30개)
        // ⭐️ [수정] 위에서 만든 uniqueList 변수를 사용
        res.json(uniqueList.slice(0, 30));

    } catch (error) {
        console.error("검색 중 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});


// --------------------------------------------------------------------------
// 2. 학과 검색 API (CSV 기반)
// --------------------------------------------------------------------------
app.get('/api/university/departments', (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    const { univName } = req.query;
    if (!univName) return res.status(400).json({ message: '대학 이름이 필요합니다.' });

    try {
        jwt.verify(token, JWT_SECRET);

        // 해당 대학의 학과 목록을 필터링합니다.
        const departments = allUniversities
            .filter(u => u.univName === univName)
            .map((u, index) => ({
                schoolName: u.univName,
                majorName: u.deptName,
                majorSeq: String(index) // 고유 ID가 따로 없으니 임시로 인덱스 사용
            }));
        
        // 가나다순 정렬
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

// [신규] 네이버 뉴스 API 호출 헬퍼 함수
async function searchNaverNews(query) {
    const apiUrl = 'https://openapi.naver.com/v1/search/news.json';
    
    // [추가] 1. 서버 콘솔에 어떤 키워드를 검색하는지 출력
    console.log(`[네이버 API] "${query} 입시" 키워드로 검색 시도...`);

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
        
        // [추가] 2. ⭐️ 성공 시, 네이버가 보낸 '원본 데이터'를 서버 콘솔에 출력
        console.log(`[네이버 API] "${query}" 검색 성공:`, response.data);
        
        return response.data.items || [];

    } catch (error) {
        // [수정] 3. ⭐️ 실패 시, 네이버가 보낸 '에러 메시지'를 서버 콘솔에 자세히 출력
        if (error.response) {
            // 네이버 서버가 (401, 400, 500 등) 에러를 응답한 경우
            console.error(`[네이버 API] "${query}" 검색 실패 (HTTP ${error.response.status}):`, error.response.data);
        } else {
            // 요청 자체가 실패한 경우 (예: 인터넷 연결)
            console.error(`[네이버 API] "${query}" 요청 실패:`, error.message);
        }
        return []; // 실패 시 빈 배열 반환
    }
}

app.get('/api/university/my', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // 1. 내신 계산
        const myAvgGrade = await getUserAverageGrade(userId);
        
        // 2. 내 대학 목록 조회
        const [rows] = await db.query('SELECT * FROM user_universities WHERE userId = ?', [userId]);
        
        const myUniversities = rows.map(row => {
            let status = "appropriate"; 
            let requiredScore = 0;
            const univName = row.universityName;
            
            // ⭐️ [핵심] DB에 저장된 학과 이름에서 공백 제거
            const myDeptName = row.department.replace(/\s+/g, '').trim(); 

            // 3. 고려대 매칭 시도
            if (univName.includes("고려대")) {
                // (1) 정확히 일치하는지 찾기
                let data = koreaAdmissionData[myDeptName];

                // (2) 없다면? '비슷한' 이름이 있는지 CSV 전체를 뒤져서 찾기 (유사 검색)
                if (!data) {
                    const foundKey = Object.keys(koreaAdmissionData).find(csvKey => {
                        // DB이름("컴퓨터공학과")이 CSV이름("컴퓨터학과")를 포함하거나, 그 반대인 경우
                        return myDeptName.includes(csvKey) || csvKey.includes(myDeptName);
                    });
                    if (foundKey) {
                        data = koreaAdmissionData[foundKey];
                        console.log(`🔗 [매칭 성공] DB('${myDeptName}') ≈ CSV('${foundKey}')`);
                    }
                }

                if (data) {
                    requiredScore = data.cut70;
                    
                    // 내신 점수 비교 로직
                    if (myAvgGrade > 0) {
                        if (myAvgGrade <= data.cut50) status = "safe";
                        else if (myAvgGrade <= data.cut70) status = "appropriate";
                        else status = "challenging";
                    }
                } else {
                     // 범인 색출용 로그
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
                deadline: row.deadline || "2024-09-13",
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
//
// [신규] '내 대학' 탭 - '관심 대학' 추가 (POST)
// (AddUniversityViewController의 '완료' 버튼이 호출할 API)
//
app.post('/api/university/my', async (req, res) => {
    // 1. JWT 인증
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    // 2. 앱에서 보낸 대학/학과 정보 받기
    // (APIService.swift에서 이 형식으로 body를 보내야 함)
    const { universityName, location, department, majorSeq } = req.body;
    
    if (!universityName || !department) {
        return res.status(400).json({ message: '대학명과 학과명은 필수입니다.' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // 3. DB에 '내 대학' 정보 삽입
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

// --------------------------------------------------------------------------
// 📝 상담(질문) 관련 API
// --------------------------------------------------------------------------

// 1. 질문 등록하기
app.post('/api/counseling/questions', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        const { question, category } = req.body; // 카테고리는 선택 (기본값 설정 가능)

        if (!question) return res.status(400).json({ message: "질문 내용을 입력해주세요." });

        // 질문 저장
        await db.query(
            'INSERT INTO counseling_questions (user_id, question, category) VALUES (?, ?, ?)',
            [userId, question, category || '진학상담']
        );

        // 💡 [확장 포인트] 여기에 AI 챗봇 로직을 추가하면 '즉시 답변'도 가능합니다.
        // 지금은 일단 '대기 중' 상태로 저장만 합니다.

        res.status(201).json({ message: "질문이 등록되었습니다." });

    } catch (error) {
        console.error("질문 등록 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

// 2. 내 질문 목록 조회
app.get('/api/counseling/questions', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // 최신순 정렬
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

// --------------------------------------------------------------------------
// 👑 관리자(Admin) 전용 API
// --------------------------------------------------------------------------

// 1. 관리자용: 모든 질문 목록 조회 (답변 안 달린 것 우선)
app.get('/api/admin/questions', async (req, res) => {
    // (실제 서비스라면 여기서 관리자 권한 체크를 해야 하지만, 지금은 생략합니다)
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

// 관리자용: 답변 등록하기 (수정 버전)
app.put('/api/admin/questions/:id', async (req, res) => {
    const questionId = req.params.id;
    const { answer, counselorName } = req.body;

    try {
        // 1. 답변 업데이트
        await db.query(
            `UPDATE counseling_questions 
             SET answer = ?, counselor_name = ?, status = 'answered', answered_at = NOW()
             WHERE id = ?`,
            [answer, counselorName, questionId]
        );

        // ⭐️ [추가] 2. 질문을 올린 학생의 ID 찾기
        const [rows] = await db.query('SELECT user_id FROM counseling_questions WHERE id = ?', [questionId]);
        
        if (rows.length > 0) {
            const studentId = rows[0].user_id;
            
            // ⭐️ [추가] 3. 그 학생에게 알림 보내기 (DB 저장)
            await db.query(
                `INSERT INTO notifications (user_id, type, title, message) 
                 VALUES (?, 'counseling', '진학 상담 답변이 도착했습니다', '등록하신 질문에 선생님이 답변을 남겼습니다.')`,
                [studentId]
            );
            console.log(`🔔 사용자(${studentId})에게 알림 생성 완료`);
        }

        res.json({ message: "답변 및 알림 등록 완료." });
    } catch (error) {
        console.error("답변 등록 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

// server.js (알림 조회 API 부분 수정)

app.get('/api/notifications', async (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // ⭐️ [로그 추가] 누가 요청했는지 확인
        console.log(`🔔 [Server] User ID ${userId}가 알림 목록을 요청함`);

        const [rows] = await db.query(
            `SELECT id, type, title, message, 
                    DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') as time 
             FROM notifications 
             WHERE user_id = ? 
             ORDER BY created_at DESC`,
            [userId]
        );
        
        // ⭐️ [로그 추가] 몇 개를 찾았는지 확인
        console.log(`   👉 DB 조회 결과: ${rows.length}건 발견`);
        // console.log(rows); // 필요하면 상세 데이터 출력

        res.json(rows);
    } catch (error) {
        console.error("알림 조회 오류:", error);
        res.status(500).json({ message: "서버 오류" });
    }
});

// 2. 관리자용: 답변 등록하기 (PUT Update)
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

// 3. 관리자 웹페이지 접속 라우트
const path = require('path'); // 파일 경로 다루는 모듈
app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'admin.html'));
});

app.listen(port, '0.0.0.0', () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});