require('dotenv').config();

const express = require('express');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const app = express();
const port = 3000;

const db = require('./db')

app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET;

// -----------------------------------API라우트------------------------------------------- //

let users = [{ id: 1, name: 'OOO', kakaoId: '12345' }];

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


app.listen(port, '0.0.0.0', () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});