const express = require('express');
const app = express();
const port = 3000; // 서버가 3000번 포트에서 실행됩니다.

// GET /api/home 주소로 요청이 들어왔을 때 실행될 코드
app.get('/api/home', (req, res) => {
  console.log("iOS 앱에서 홈 데이터 요청이 들어왔습니다");

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
    ],
    universityNews: [
      {
        universityName: "서울대학교",
        title: "2025학년도 수시모집 합격자 발표",
        isNew: true,
        content: "서울대학교 2025학년도 수시모집 합격자 발표는 11월 15일 오후 2시에 본교 입학처 홈페이지를 통해 확인할 수 있습니다. 수험생 여러분의 좋은 결과를 기원합니다."
      },
      {
        universityName: "연세대학교",
        title: "정시모집 전형계획 발표",
        isNew: false,
        content: "연세대학교는 2025학년도 정시모집에서 융합과학공학부(ISE)의 선발 인원을 소폭 늘리고, 일부 학과의 수능 반영 비율을 조정했습니다. 자세한 내용은 모집 요강을 참고하시기 바랍니다."
      }
    ]
  };

  // iOS 앱에게 JSON 데이터를 응답으로 보냅니다.
  res.json(homeData);
});

// 서버를 3000번 포트에서 실행합니다.
app.listen(port, () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});