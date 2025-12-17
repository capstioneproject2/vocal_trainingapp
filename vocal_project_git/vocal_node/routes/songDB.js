// Node.js 설정 파일 (서버 환경 변수)
const SONGS_ROOT_DIR = 'C:/Users/howon/PycharmProjects/vocal_project'; 
// (실제 배포 시 이 경로만 클라우드 경로로 변경하면 됨)

const mongoose = require('mongoose');

const SongSchema = new mongoose.Schema({
    // 1. 필수 메타데이터
    songId: { 
        type: String, 
        required: true, 
        unique: true // songId는 중복되지 않아야 함
    },
    title: { 
        type: String, 
        required: true 
    },
    singer: { 
        type: String, 
        required: true 
    },
    
    // 2. 분석 파일 경로 (Node.js 서버의 로컬 파일 시스템 경로)
    wavPath: { 
        type: String, 
        required: true 
    },
    lyricsCsvPath: { 
        type: String, 
        required: true 
    },
    refF0Path: { 
        type: String, 
        required: true 
    },
    
    MIDIPath: {
        type: String,
        required: true
    }
}, { 
    timestamps: true // 생성/수정 시간을 자동 기록
});

module.exports = mongoose.model('Song', SongSchema);