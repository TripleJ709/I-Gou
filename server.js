const express = require('express');
const app = express();
const port = 3000; // 서버가 3000번 포트에서 실행됩니다.

// GET /api/home 주소로 요청이 들어왔을 때 실행될 코드
app.get('/api/home', (req, res) => {
  console.log("iOS 앱에서 홈 데이터 요청이 들어왔습니다!");

  // 지금은 데이터베이스 대신 '가짜 데이터(Dummy Data)'를 JSON 형태로 직접 만들어 보냅니다.
  const homeData = {
    user: {
      name: "김학생"
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
    ]
  };

  // iOS 앱에게 JSON 데이터를 응답으로 보냅니다.
  res.json(homeData);
});

// 서버를 3000번 포트에서 실행합니다.
app.listen(port, () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});