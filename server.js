require('dotenv').config();

const express = require('express');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const app = express();
const port = 3000;

const db = require('./db')

app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET;
const CAREERNET_API_KEY = process.env.CAREERNET_API_KEY;
const DATA_GO_KR_API_KEY = process.env.DATA_GO_KR_API_KEY;
const NAVER_CLIENT_ID = process.env.NAVER_CLIENT_ID;
const NAVER_CLIENT_SECRET = process.env.NAVER_CLIENT_SECRET;

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

        const appToken = jwt.sign({ userId: user.user_id }, JWT_SECRET, { expiresIn: '1h' });
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

app.get('/api/university/search', async (req, res) => {

    // 1. JWT 인증 (공통)
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    // 2. iOS 앱에서 보낸 검색어(query)를 받습니다.
    const { query } = req.query;
    if (!query) {
        return res.status(400).json({ message: '검색어(query)가 필요합니다.' });
    }

    // 3. data.go.kr '대학정보' API 호출 URL 및 파라미터 설정
    
    // ⚠️ [필수] 이 URL은 API 명세서의 '요청 URL' 또는 '엔드포인트'로 변경해야 합니다.
    const apiUrl = 'http://openapi.academyinfo.go.kr/openapi/service/rest/SchoolInfoService/getSchoolInfo';
    
    const params = {
        serviceKey: DATA_GO_KR_API_KEY, // 서비스키
        pageNo: 1,
        numOfRows: 20,                  // 20개 정도만
        svyYr: '2023',                  // [수정] 명세서의 '조사년도' (필수)
        sch1KrNm: query,                // [수정] 명세서의 '학교명' 검색어
        type: 'json'                    // [가정] JSON 응답 요청
    };

    try {
        jwt.verify(token, JWT_SECRET); // 토큰 유효성 검사

        // 4. axios로 data.go.kr API를 호출합니다.
        const response = await axios.get(apiUrl, { params });

        // 5. 응답 데이터 가공
        // (data.go.kr의 JSON 응답 구조는 복잡할 수 있습니다.)
        // (가정: response.data.response.body.items.item)
        const items = response.data.response.body.items.item || []; 
        
        const universities = items.map(item => {
            return {
                name: item.schNm,         // [수정] '학교명' (schNm)
                location: item.postNoAdrs // [수정] '소재지도로명주소' (postNoAdrs)
            };
        });

        // 6. 가공된 대학 목록을 iOS 앱에 전송
        res.json(universities);

    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
                    return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
                }
                console.error("data.go.kr API 호출 중 오류:", error.message);
                res.status(500).json({ message: '대학 정보 조회 중 서버 오류가 발생했습니다.' });
    }
});

app.get('/api/university/departments', async (req, res) => {
    
    // 1. JWT 인증 (공통)
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    // 2. iOS 앱에서 보낸 검색어(대학 이름)를 받습니다.
    const { univName } = req.query; 
    if (!univName) {
        return res.status(400).json({ message: '대학 이름(univName)이 필요합니다.' });
    }

    // 3. 커리어넷 API 호출 URL을 만듭니다.
    const apiUrl = 'http://www.career.go.kr/cnet/openapi/getOpenApi.json';
    const params = {
        apiKey: CAREERNET_API_KEY,
        svcType: 'api',      // API 타입 (고정)
        svcCode: 'MAJOR',    // 서비스 코드 (학과정보)
        contentType: 'json', // JSON 요청
        gubun: 'univ_list',  // 'univ_list' (대학별 학과)
        searchTitle: univName // iOS 앱에서 받은 대학 이름으로 검색
    };

    try {
        jwt.verify(token, JWT_SECRET); // 토큰 유효성 검사

        // 4. axios로 커리어넷 API를 호출합니다.
        const response = await axios.get(apiUrl, { params });
        
        // 5. 응답 데이터 가공
        // (커리어넷 응답 구조: response.data.dataSearch.content)
        const departments = response.data.dataSearch.content.map(item => {
            return {
                schoolName: item.schoolName, // 대학명
                majorName: item.majorName, // 학과명
                majorSeq: item.majorSeq    // 학과 고유번호
            };
        });
        
        // 6. 가공된 학과 목록을 iOS 앱에 전송
        res.json(departments);

    } catch (error) {
        if (error.name === 'JsonWebTokenError') {
            return res.status(403).json({ message: '유효하지 않은 토큰입니다.' });
        }
        console.error("커리어넷 API 호출 중 오류:", error.message);
        res.status(500).json({ message: '학과 정보 조회 중 서버 오류가 발생했습니다.' });
    }
});

app.get('/api/university/news', async (req, res) => {

    // 1. JWT 인증으로 사용자 ID 가져오기
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    let userId;
    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        userId = decoded.userId; // 3. JWT에 userId가 있다고 가정
    } catch (error) {
        return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
    }

    try {
        // 4. DB에서 '내 대학' 목록 가져오기
        // (DB 테이블과 컬럼명은 실제에 맞게 수정 필요)
        const [myUniversities] = await db.query(
            'SELECT universityName FROM user_universities WHERE userId = ?', 
            [userId]
        );
        
        // 5. '내 대학' + '공통 키워드'로 전체 검색 목록 생성
        const commonKeywords = ['입시', '수능', '대입'];
        const userKeywords = myUniversities.map(uni => uni.universityName);
        
        // (예: ['서울대학교', '연세대학교', '입시', '수능', '대입'])
        const allKeywords = [...userKeywords, ...commonKeywords];

        // 6. 모든 키워드로 네이버 뉴스 API를 '병렬' 호출
        const searchPromises = allKeywords.map(keyword => 
            searchNaverNews(keyword)
        );
        const allResults = await Promise.all(searchPromises);

        // 7. 모든 결과(2D 배열)를 1개의 배열로 합치기
        const allItems = allResults.flat();

        // 8. 'link' 기준으로 중복 제거 (중요)
        const uniqueItems = Array.from(
            new Map(allItems.map(item => [item.link, item])).values()
        );

        // 9. 최종 목록을 앱에 응답
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