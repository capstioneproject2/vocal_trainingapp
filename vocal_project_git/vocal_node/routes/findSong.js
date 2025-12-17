const Song = require("./songDB");

async function findSongByMeta(singer, title) {
  // DB에서 해당 가수와 제목의 곡을 찾습니다.
  const song = await Song.findOne({ singer, title });

  // 곡이 없으면 null 반환
  if (!song) return null;

  // 🔥 [수정] 굳이 뽑아서 주지 말고, song 객체 전체를 반환하세요.
  // server.js에서 필요한 변수(refF0Path, lyricsCsvPath)를 알아서 꺼내 쓸 겁니다.
  return song;
}

module.exports = { findSongByMeta };