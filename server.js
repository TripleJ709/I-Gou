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

// [수정] 홈 데이터 조회 API (DB 연동)
app.get('/api/home', async (req, res) => { // async 키워드 추가
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.sendStatus(401);

    try {
        // 토큰 검증
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // --- 여기서부터 DB 조회 ---

        // 1. 사용자 이름 조회 (DB 사용)
        const [userRows] = await db.query('SELECT name FROM users WHERE user_id = ?', [userId]);
        if (userRows.length === 0) {
            return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });
        }
        const user = userRows[0];

        // 2. 오늘의 일정 조회 (DB 사용)
        const [scheduleRows] = await db.query(
            'SELECT DATE_FORMAT(start_time, "%H:%i") as startTime, title, type FROM schedules WHERE user_id = ? AND DATE(start_time) = CURDATE() ORDER BY start_time ASC',
            [userId]
        );

        // 3. 최근 성적 조회 (DB 사용 - 내신/모의고사 구분 없이 최근 2개)
        const [gradeRows] = await db.query(
            'SELECT subject_name as subjectName, score, grade_level as gradeLevel FROM grades WHERE user_id = ? ORDER BY exam_date DESC LIMIT 2',
            [userId]
        );
        
        // 4. 알림 및 대학 소식 (아직 DB 연동 전 - 임시 하드코딩)
        // TODO: 이 부분도 나중에 DB에서 가져오도록 수정해야 합니다.
        const notifications = [
            { content: "2025학년도 수시모집 원서접수 시작", createdAt: "2시간 전" },
            { content: "11월 모의고사 성적 확인 가능", createdAt: "1일 전" }
        ];
        const universityNews = [
            { universityName: "서울대학교", title: "2025학년도 수시모집 합격자 발표", isNew: true, content: "..." },
            { universityName: "연세대학교", title: "정시모집 전형계획 발표", isNew: false, content: "..." }
        ];

        // --- DB 조회 끝 ---
        
        // 조회된 실제 데이터로 homeData 객체 구성
        const homeData = {
            user: { name: user.name },
            todaySchedules: scheduleRows,
            recentGrades: gradeRows,
            notifications: notifications, 
            universityNews: universityNews  
        };
        
        res.json(homeData);

    } catch (error) {
        // JWT 에러 처리
        if (error.name === 'JsonWebTokenError' || error.name === 'TokenExpiredError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("홈 데이터 조회 중 DB 오류:", error);
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
    // 1. JWT 인증
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId; // JWT에 userId가 있다고 가정

        // 2. DB에서 이 사용자의 대학 목록 조회
        const [rows] = await db.query(
            'SELECT * FROM user_universities WHERE userId = ?',
            [userId]
        );
        
        // 3. iOS 앱의 'UniversityItem' 모델 형식에 맞게 키 이름을 변경
        const myUniversities = rows.map(row => ({
            id: row.id,
            universityName: row.universityName,
            department: row.department,
            major: row.major || "",
            myScore: row.myScore || 0,
            requiredScore: row.requiredScore || 0,
            deadline: row.deadline || "N/A",
            status: row.status || "appropriate",
            location: row.location || "",
            competitionRate: row.competitionRate || ""
        }));

        res.json(myUniversities);

    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("'내 대학' 조회 중 DB 오류:", error);
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

app.listen(port, '0.0.0.0', () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});