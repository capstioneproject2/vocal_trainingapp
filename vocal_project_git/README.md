# vocal training app

이 프로젝트는 딥러닝과 오디오 신호 처리를 활용한 AI 프로젝트입니다. TensorFlow, Spleeter, Librosa 등을 활용하여 오디오 분석, 분리 및 처리 작업을 수행합니다.

# 🛠 주요 기능 (Features)

* 음원 분리 (Source Separation): Spleeter를 활용한 보컬/반주 분리
* 오디오 분석 (Audio Analysis): Librosa를 이용한 파형 분석 및 특징 추출
* 피치 감지 (Pitch Detection): Crepe 알고리즘 활용
* 데이터 처리: Pandas와 NumPy를 활용한 데이터 전처리

# 📋 요구 사항 (Prerequisites)

이 프로젝트를 실행하기 위해서는 다음 사항들이 필요합니다.

* Python 3.8 이상 (권장)
* FFmpeg (오디오 처리를 위해 필수 설치 필요)

# 📦 설치 방법 (Installation)

1. 저장소를 클론합니다.
   ```bash
   git clone [https://github.com/capstioneproject2/vocal_trainingapp.git](https://github.com/capstioneproject2/vocal_trainingapp.git)
   
2. 필요한 라이브러리 설치(파이썬)
pip install -r requirements.txt

(node)
cd vocal_node
npm install 
cd ..

3. 폴더 구조
vocal_project_git/
├── vocal_node/          # Node.js 서버 파일
├── songs/               # 원곡 데이터 폴더 (하위에 곡 제목 폴더 위치)
├── .env                 # 환경 변수 파일
└── (Python 스크립트들)

4. 환경변수 설정(.env)
MONGO_URI=mongodb://localhost:27017/vocal_node (또는 본인의 MongoDB 주소)

3. 실행 방법
1) 폴더 경로명을 vocal_project가 아닌 vocal_project_git으로 변환
2) vocal_project 하위에 vocal_node폴더(node.js파일), songs폴더 (원곡 데이터) 있도록 확인
3) py파일과 동일한 폴더에 hanroro_original.wav를 넣고 spleeter, pYIN, pYIN_highpitch(MIDI로 노이즈 전환) 돌린다. -> 결과값이 hanroro_pYIN_threshold.npy
4) py파일과 동일한 폴더에 MIDI파일을 넣고, MIDI파일을 사용하여 extractlyrics 실행 (가사 csv추출) -> hanroro_lyrics.csv 있음
5) vocal_project_git 하위 폴더인 songs폴더의 하위인 '사랑하게 될 거야' 폴더에 hanroro.wav(원곡), hanroro_lyrics.csv(가사), hanroro_pYIN_threshold.npy(원곡F0), 사랑하게 될 거야_멜로디악보_MIDI 파일을 넣는다.
6) db_put_songs.js 실행(MIDI, 원곡wav, pYIN) -> 원곡 비교 데이터 넣기
7) 클라이언트를 켜고(node server.js) 플러터에 hanroro_record.wav/hanroro_pitch/hanroro_rhythm 파일(녹음본 - 일반 - 음치 - 박치)을 넣고 돌린다.