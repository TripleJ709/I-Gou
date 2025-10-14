require('dotenv').config();

const express = require('express');
const jwt = require('jsonwebtoken');
const axios = require('axios');
const app = express();
const port = 3000;

const db = require('./db')

app.use(express.json());

const JWT_SECRET = process.env.JWT_SECRET;

let users = [{ id: 1, name: '김학생12345', kakaoId: '12345' }];

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


let plannerData = {
  todaySchedules: [
    { id: 1, time: "09:00", title: "수학 문제집 풀이", subtitle: "미적분 연습문제 10문제", tag: "학습", color: "blue" },
    { id: 2, time: "14:00", title: "영어 단어 암기", subtitle: "고등어휘 50개", tag: "학습", color: "blue" }
  ],
  deadlines: [
    { id: 1, title: "수학 과제 제출", date: "2025-10-15", priority: "높음", color: "red" },
    { id: 2, title: "영어 발표 준비", date: "2025-10-18", priority: "보통", color: "yellow" }
  ]
};

app.get('/api/planner', (req, res) => {
  console.log("iOS 앱에서 플래너 데이터 요청이 들어왔습니다!");
  res.json(plannerData);
});

app.post('/api/schedules', (req, res) => {
  const newSchedule = req.body;
  console.log("새로운 일정 추가됨:", newSchedule);
  plannerData.todaySchedules.push({ id: Date.now(), ...newSchedule });
  res.status(201).json({ message: "일정이 성공적으로 추가되었습니다." });
});

app.listen(port, '0.0.0.0', () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});