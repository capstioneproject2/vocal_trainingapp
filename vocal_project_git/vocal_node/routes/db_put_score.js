// 📁 routes/recordDB.js (파일 이름 확인 필요)

// ❌ 기존: const User = require("./userDB");  <-- 이거 지우세요!
// ✅ 변경: 방금 만든 recordDB을 불러옵니다.
const ScoreRecord = require("./recordDB"); 

async function saveResultToDB(userId, singer, title, result) {
    try {
        console.log(`💾 ${userId}님의 분석 결과 score_records에 저장 시도...`);

        // ✅ User.updateOne 대신 ScoreRecord.create 사용
        await ScoreRecord.create({
            userId: userId,
            singer: singer,
            songTitle: title,
            score: result.scores.final_score, // 점수만 따로 뺌
            resultData: result // 전체 데이터도 저장
        });

        console.log("✅ DB(score_records) 저장 완료!");
        return true;

    } catch (dbErr) {
        console.error("❌ DB 저장 실패:", dbErr);
        return false;
    }
}

module.exports = { saveResultToDB };