//프론트 로그인 창에서 받으면 몽고디비 users에 userId랑 password 저장하기
//users DB에는 이런 형식으러 넣어야함.

const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    userId: { type: String, required: true, unique: true },
    password: { type: String, required: true }
  },
  { collection: "users" }
);

const User = mongoose.model("User", userSchema);  //User라는 클래스 생성

module.exports = User;
