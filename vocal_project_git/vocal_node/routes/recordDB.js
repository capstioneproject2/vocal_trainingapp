// 📁 routes/recordDB.js
//score_records의 형식

const mongoose = require("mongoose");

const scoreSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true }, // 누구 점수인지 알기 위해 userId 저장
    singer: { type: String, required: true },
    songTitle: { type: String, required: true },
    score: { type: Number, required: true },  // 점수
    resultData: { type: Object },             // 분석 결과 전체 (JSON)
    date: { type: Date, default: Date.now }   // 언제 불렀는지
  },
  { collection: "score_records" } // 🔥 여기가 핵심! 저장될 DB 이름 지정
);

const ScoreRecord = mongoose.model("ScoreRecord", scoreSchema);

module.exports = ScoreRecord;