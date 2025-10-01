const express = require('express');
const app = express();
const port = 3000;

app.use(express.json());

app.get('/api/home', (req, res) => {
  console.log("iOS 앱에서 홈 데이터 요청이 들어왔습니다");

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
  res.json(homeData);
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

app.listen(port, () => {
  console.log(`I-Gou 서버가 http://localhost:${port} 에서 실행 중입니다.`);
});