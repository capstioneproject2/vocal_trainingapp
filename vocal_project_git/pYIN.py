import librosa
import numpy as np

# 1. 오디오 파일 로드
AUDIO_FILE = 'hanroro_record.wav'
y, sr = librosa.load(AUDIO_FILE, sr=None)

# 2. pYIN으로 F0 추출
f0, voiced_flag, voiced_probs = librosa.pyin(
    y,
    fmin=librosa.note_to_hz('C2'),
    fmax=librosa.note_to_hz('C7'),
    sr=sr
)

# 3. NaN → 0 처리
f0_filled = np.nan_to_num(f0)

# 4. 시간축 생성
times = librosa.frames_to_time(np.arange(len(f0)), sr=sr)

# 🔥 5. time과 f0를 (N,2) 배열로 묶기
data = np.column_stack([times, f0_filled])

# 🔥 6. 한 파일로 저장
np.save("hanroro_record_pYIN.npy", data)

print("✅ hanroro_record_pYIN.npy 저장 완료!")
print("shape:", data.shape)   # (N, 2)


##노이즈 제거(위로 확 튀는 스파크 제거)
# import librosa
# import numpy as np
#
# # 1. 오디오 파일 로드
# AUDIO_FILE = 'hanroro_spleeter_vocal.wav'
# y, sr = librosa.load(AUDIO_FILE, sr=None)
#
# # 🚨 수정: threshold 옵션 제거 및 hop_length 유지
# HOP_LENGTH = 256
#
# # 2. pYIN으로 F0 추출 (threshold 옵션 제거)
# f0, voiced_flag, voiced_probs = librosa.pyin(
#     y,
#     fmin=librosa.note_to_hz('C2'),
#     fmax=librosa.note_to_hz('C7'),
#     sr=sr,
#     hop_length=HOP_LENGTH
# )
#
# # 3. 🚨 개선: voiced_probs를 이용한 수동 필터링
# # 신뢰도(voiced_probs)가 0.1 미만인 모든 F0 값을 NaN으로 처리합니다.
# CONFIDENCE_THRESHOLD = 0.1
# f0[voiced_probs < CONFIDENCE_THRESHOLD] = np.nan
#
# # 4. NaN → 0 처리 (필터링된 노이즈 구간이 이제 0으로 명확하게 처리됨)
# f0_filled = np.nan_to_num(f0)
#
# # 5. 시간축 생성 (변경된 HOP_LENGTH 적용)
# times = librosa.frames_to_time(np.arange(len(f0)), sr=sr, hop_length=HOP_LENGTH)
#
# # 6. time과 f0를 (N,2) 배열로 묶기
# data = np.column_stack([times, f0_filled])
#
# # 7. 한 파일로 저장
# np.save("hanroro_spleeter_pYIN_noiseX.npy", data)
#
# print("✅ hanroro_spleeter_pYIN_noiseX.npy 저장 완료!")
# print("shape:", data.shape)