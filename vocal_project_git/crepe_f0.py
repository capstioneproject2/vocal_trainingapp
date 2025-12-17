import crepe
import librosa
import numpy as np

AUDIO_FILE = "hanroro_record.wav"

# 1) 오디오 로드 (16kHz)
y, sr = librosa.load(AUDIO_FILE, sr=16000, mono=True)

# 2) CREPE 실행 (10ms step)
time, frequency, confidence, activation = crepe.predict(
    y,
    sr,
    viterbi=True,
    step_size=10,
    model_capacity='full'
)

# 3) 신뢰도 0.6 미만 구간을 0으로 처리
threshold = 0.6
frequency_clean = np.where(confidence >= threshold, frequency, 0.0)

# 🔥 4) time이랑 f0를 같이 저장 (N, 2)
data = np.column_stack([time, frequency_clean])
np.save("hanroro_recordf0.npy", data)

print("전체 F0 + time 저장 완료 → hanroro_recordf0.npy")
print("총 프레임 수:", len(frequency_clean))
