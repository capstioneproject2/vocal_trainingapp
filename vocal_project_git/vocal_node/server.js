// 📁 server.js

// 1. 필요한 모듈 불러오기
require("dotenv").config();  //mongodb연결
const express = require("express");
const mongoose = require("mongoose");  //mongodb
const cors = require("cors");
const User = require("./routes/userDB");
const path = require("path"); //path모듈-> runPython.js에서 파이썬 경로 담당
const { runPython } = require("./runPython")  //runPython.js 가져오기
const fs = require("fs/promises"); 
const multer = require("multer");  //파일 업로드 처리해주는 라이브러리 -> mutler가 파일을 받아서 서버(백)에 저장해주는 역할
const { findSongByMeta } = require("./routes/findSong");
const PYTHON_WORK_DIR = path.join(__dirname,"..");  //파이썬 작업 디렉토리 위치(analyze.py있는 vocal_project폴더)
const {saveResultToDB} = require("./routes/db_put_score"); //score_records DB에 저장
const ScoreRecord = require("./routes/recordDB.js");

//wav임시 저장 경로
const upload = multer({
  dest : path.join(__dirname, "..",),  
});

// 2. 앱 생성
const app = express();

// 3. 포트 번호 설정 (원하면 4000, 5000으로 바꿔도 됨)
const PORT = 3000;

// 4. 미들웨어 설정
app.use(cors());           // 다른 포트에서 오는 요청 허용 (예: 프론트 5173, 3000 등)
app.use(express.json());   // JSON 바디 파싱 (req.body 쓰려면 필수)

// 5. 기본 테스트용 라우트 (선택)
// 브라우저에서 http://localhost:3000 들어가면 확인 가능
app.get("/", (req, res) => {
  res.send("✅ 서버 잘 돌아가는 중!");
});



//mongodb연결
async function connectDB() {
    try {
        await mongoose.connect(process.env.MONGO_URI, {
            dbName: "vocal_project"  //연결할 db폴더 이름
        });

        console.log("mongodb connected");
    }   catch (err) {
        console.error("mongodb connection failed", err);
    }
}

connectDB();

app.post("/login", async (req, res) => {
  console.log("\login 요청 body:", req.body);  //프론트에서 로그인 시도 시, 들어오는 아이디, 비번 내용
  const { userId, password } = req.body;

  if (!userId || !password) {
    return res.status(400).json({
      ok: false,
      message: "userId와 password가 필요합니다.",
    });
  }

  console.log("🔐 로그인 요청 들어옴");
  console.log("➡ userId:", userId);
  console.log("➡ password:", password);

  try {
    // 1) 이미 이 userId가 있는지 먼저 확인
    let user = await User.findOne({ userId });

    if (!user) {
      // 2) 없으면 새로 생성
      user = await User.create({ userId, password });
      console.log("🆕 신규 유저 생성:", user);
    } else {
      // 3) 있으면 비밀번호만 업데이트 하고 싶으면 여기서 처리 (선택)
      // user.password = password;
      // await user.save();
      console.log("📌 기존 유저 로그인:", user.userId);
    }

    return res.json({
      ok: true,
      message: "로그인/저장 처리 완료",
      userId: user.userId,
    });
  } catch (err) {
    console.error("사용자 정보 저장 에러:", err);
    return res.status(500).json({ ok: false, message: "서버 에러" });
  }
});


// 7. 서버 실행
app.listen(PORT, "0.0.0.0",() => {
  console.log(` Server is running on http://localhost:${PORT}`);
  console.log(` Network access: http://10.50.110.96:${PORT}`);
});


// 🎵 프론트에서 singer/title + wav 업로드 → 분석
// 요청 형식: multipart/form-data
//  - field:  meta   → JSON 문자열: {"singer":"...", "title":"..."}
//  - file:   record → 사용자 녹음 wav
app.post("/analyze", upload.single("record"), async (req, res) => {
  let userWavPath = null;  // finally에서 지우기 위해 미리 선언

  try {
    // 1) meta 파싱
    if (!req.body.meta) {
      return res.status(400).json({
        ok: false,
        message: "meta(JSON: singer, title)가 필요합니다.",
      });
    }

    let meta;
    try {
      meta = JSON.parse(req.body.meta);
    } catch (e) {
      return res.status(400).json({
        ok: false,
        message: "meta가 올바른 JSON 형식이 아닙니다.",
      });
    }

    const { singer, title, userId } = meta;

    if (!singer || !title) {
      return res.status(400).json({
        ok: false,
        message: "singer와 title이 필요합니다.",
      });
    }

    // 2) 녹음 파일 확인
    if (!req.file) {
      return res.status(400).json({
        ok: false,
        message: "녹음본(wav) 파일(record)이 필요합니다.",
      });
    }

    userWavPath = req.file.path; // 예: vocal_project/abcd1234.wav
    console.log("\n🎵 /analyze 요청");
    console.log("➡ userId:", userId);
    console.log("➡ singer:", singer);
    console.log("➡ title:", title);
    console.log("➡ user wav:", userWavPath);

    // 3) DB에서 곡 데이터 가져오기 -> routes폴더 findSong.js사용
    const song = await findSongByMeta(singer, title);

    if (!song) {
      return res.status(404).json({
        ok: false,
        message: "해당 곡을 DB에서 찾을 수 없습니다.",
      });
    }

    const { refF0Path, lyricsCsvPath } = song;
    console.log("➡ refF0Path:", refF0Path);
    console.log("➡ lyricsCsvPath:", lyricsCsvPath);

    // 4) Python analyze.py 실행
    const scriptName = "analyze.py";

    const result = await runPython(
      scriptName,
      [userWavPath, refF0Path, lyricsCsvPath],
      { cwd: PYTHON_WORK_DIR }
    );

    //🔥파이썬이 넘긴 JSON일부 콘솔에 찍기(성공하면 나중에 삭제 하셈🔥)
    console.log(
      "analyze.py result(JSON) 일부:",
      typeof result === "string"
      ? result.slice(0,300)
      : JSON.stringify(result).slice(0,300)
    );

    //로그 출력(점수 확인용)
    console.log("분석 완료. 점수: ", result.scores?.final_score);

    if (userId){
      //result 변수를 인자로 넘겨줌.
      await saveResultToDB(userId, singer, title, result);
    }


    // 5) Python에서 온 JSON 결과 프론트로 전송
    return res.json({
      ok: true,
      data: result,
    });

  } catch (err) {
    console.error("🎵 /analyze 실행 에러:", err);
    return res.status(500).json({
      ok: false,
      message: "서버/Python 실행 중 오류 발생",
      error: String(err),
    });

  } finally {
    // 🔥🔥🔥 6) 임시 파일 무조건 삭제 (성공/실패 관계없이)
    if (userWavPath) {
      try {
        await fs.unlink(userWavPath);
        console.log("🧹 임시 wav 파일 삭제 완료:", userWavPath);
      } catch (cleanupErr) {
        console.error("⚠ 임시 파일 삭제 중 오류:", cleanupErr);
      }
    }
  }
});


// 📜 히스토리 조회 API
// 프론트에서 GET http://localhost:3000/history?userId=아이디 형식으로 요청
app.get("/history", async (req, res) => {
  try {
    // 1. 프론트가 보낸 userId 받기 (GET 요청은 주소창 파라미터로 옵니다)
    const { userId } = req.query; 

    console.log(`📂 히스토리 조회 요청: ${userId}`);

    if (!userId) {
      return res.status(400).json({ ok: false, message: "userId가 필요합니다." });
    }

    // 2. DB에서 찾기
    // - .find({ userId }): 해당 유저의 모든 기록 찾기
    // - .sort({ date: -1 }): 최신순 정렬 (date 기준 내림차순)
    // - .select("-resultData"): 결과값 빼고 가져와라
    const history = await ScoreRecord.find({ userId }).select("-resultData").sort({ date: -1 });

    console.log(`📄 발견된 기록 수: ${history.length}개`);

    // 3. 결과 보내주기
    return res.json({
      ok: true,
      data: history, // 리스트가 그대로 넘어갑니다
    });

  } catch (err) {
    console.error("히스토리 조회 실패:", err);
    return res.status(500).json({ ok: false, message: "DB 조회 오류" });
  }
});

// 📜 [추가] 상세 결과 조회 API
// 클라이언트에서 POST http://.../history/detail 로 요청 시 작동
app.post("/history/detail", async (req, res) => {
  try {
    // 1. 클라이언트가 body에 담아 보낸 정보 꺼내기
    // (Flutter 코드에서 userId, title, date를 보냈으므로 똑같이 받습니다)
    const { id } = req.body;

    console.log(`🔎 상세 조회 요청 들어옴: recordId = ${id}`);

    // 필수 값이 없으면 튕겨내기
    if (!id) {
      return res.status(400).json({ ok: false, message: "recordId가 누락되었습니다." });
    }

    // 2. DB에서 찾기
    // findOne: 조건에 맞는 거 딱 하나만 찾기
    // 주의: .select("-resultData")를 뺐으므로, 이제 'resultData'를 포함한 모든 정보가 다 나옵니다.
    const record = await ScoreRecord.findById(id);

    if (!record) {
      console.log("❌ 기록을 찾을 수 없음");
      console.log('Id = ${id}');
      return res.status(404).json({ ok: false, message: "해당 기록을 찾을 수 없습니다." });
    }

    console.log("✅ 상세 기록 발견! 데이터 전송함.");

    // 3. 결과 보내주기
    // 클라이언트가 if (decoded.containsKey('resultData'))를 검사하고 있으므로
    // 키 이름을 'resultData'로 맞춰서 보내줍니다.
    return res.json({
      ok: true,
      resultData: record, // 여기에 알맹이(전체 데이터)를 넣음
    });

  } catch (err) {
    console.error("상세 조회 에러:", err);
    return res.status(500).json({ ok: false, message: "서버 내부 오류" });
  }
});