require('dotenv').config();

const express = require('express');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const app = express();
const port = 3000;

const db = require('./db')

app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET;

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
        const email = kakaoResponse.data.kakao_account.email;
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
        console.error("카카오 인증 또는 DB 오류:", error);
        res.status(500).json({ message: '인증 처리 중 서버에서 오류가 발생했습니다.' });
    }
});

app.get('/api/home', (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) return res.sendStatus(401);

    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            console.error("JWT 검증 실패:", err);
            return res.sendStatus(403);
        }

        const user = users.find(u => u.id === decoded.userId);
        if (!user) return res.sendStatus(404);

        const homeData = {
            user: {
                name: user.name
            },
            todaySchedules: [
                { startTime: "09:00", title: "국어", type: "수업" },
                { startTime: "10:00", title: "수학", type: "수업" }
            ],
            recentGrades: [
                { subjectName: "수학", score: 92, gradeLevel: "1등급" },
                { subjectName: "영어", score: 85, gradeLevel: "2등급" }
            ],
            notifications: [
                { content: "2025학년도 수시모집 원서접수 시작", createdAt: "2시간 전" },
                { content: "11월 모의고사 성적 확인 가능", createdAt: "1일 전" }
            ],
            universityNews: [
                {
                    universityName: "서울대학교",
                    title: "2025학년도 수시모집 합격자 발표",
                    isNew: true,
                    content: "서울대학교 2025학년도 수시모집 합격자 발표는 11월 15일 오후 2시에 본교 입학처 홈페이지를 통해 확인할 수 있습니다."
                },
                {
                    universityName: "연세대학교",
                    title: "정시모집 전형계획 발표",
                    isNew: false,
                    content: "연세대학교는 2025학년도 정시모집에서 융합과학공학부(ISE)의 선발 인원을 소폭 늘렸습니다."
                }
            ]
        };
        
        res.json(homeData);
    });
});

app.get('/api/planner', async (req, res) => {
// 1. JWT 토큰으로 사용자 인증 (홈 탭과 동일)
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;

        // 2. DB에서 해당 사용자의 일정 데이터 조회
        // '오늘의 일정'과 '다가오는 마감일'을 구분하기 위해 쿼리를 나눕니다.
        // (참고: UI에 있던 '마감일'은 별도 테이블 대신, 일종의 '일정'으로 간주하여 schedules 테이블에 함께 저장합니다.)
        
        const [todaySchedules] = await db.query(
            'SELECT schedule_id as id, DATE_FORMAT(start_time, "%H:%i") as time, title, "새로 추가된 일정" as subtitle, type as tag, "blue" as color FROM schedules WHERE user_id = ? AND DATE(start_time) = CURDATE() ORDER BY start_time ASC',
            [userId]
        );

        const [deadlines] = await db.query(
            'SELECT schedule_id as id, title, DATE_FORMAT(start_time, "%Y-%m-%d") as date, "높음" as priority, "red" as color FROM schedules WHERE user_id = ? AND DATE(start_time) > CURDATE() ORDER BY start_time ASC LIMIT 5',
            [userId]
        );
        
        // 3. 조회된 데이터를 JSON 형식으로 조합하여 응답
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


// server.js

// [수정] 새 일정 추가 API
app.post('/api/schedules', async (req, res) => {
    // 1. JWT 토큰으로 사용자 인증
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) return res.sendStatus(401);

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const userId = decoded.userId;
        
        // 2. iOS 앱이 보낸 새로운 일정 데이터
        const { title, date, type, priority } = req.body;
        
        // 3. DB에 새로운 일정 INSERT
        // 클라이언트가 보낸 데이터를 기반으로 쿼리를 실행합니다.
        // end_time은 사용하지 않으므로 쿼리에서 제외합니다.
        await db.query(
            'INSERT INTO schedules (user_id, title, start_time, type, priority) VALUES (?, ?, ?, ?, ?)',
            [userId, title, date, type, priority] // priority는 '일일 일정'일 경우 null로 들어옵니다.
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


app.listen(port, '0.0.0.0', () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});