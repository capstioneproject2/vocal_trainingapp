# #pYIN의 단점인 높이 치솟는 피치 줄이기
# # MIDI의 멜로디값과 차이가 많이 날 경우, MIDI의 값으로 바꿈
# #f0이 0(없거나)이면 그대로 놔둠
#
# import numpy as np
# import matplotlib.pyplot as plt
# import os
# import librosa
# import math
#
# # --------------------------
# # 🚨 사용자 설정: NPY 파일 경로 (noise 제거 안 한 pYIN 사용)
# # --------------------------
# NPY_FILE_PATHS = {
#     "MIDI F0 (Ideal)": "C:/Users/howon/PycharmProjects/vocal_project/midi_melody_f0.npy",
#     "pYIN F0 (Audio)": "C:/Users/howon/PycharmProjects/vocal_project/hanroro_spleeter_pYIN.npy"
#     # pYIN_noise F0 경로는 제거하고, pYIN F0 하나만 사용합니다.
# }
#
# # DTW 정렬 임계값 (예: 75 cents는 약 1/4 음)
# MAX_SNAPPING_ERROR_CENTS = 75
#
#
# # --------------------------
# # 1. F0 DTW 정렬 함수 (기존 코드와 동일)
# # --------------------------
# def apply_dtw_alignment(ref_data, target_data):
#     """
#     DTW를 사용하여 target_data (Audio F0)를 ref_data (MIDI F0)에 정렬하고,
#     정렬된 F0 시퀀스(Hz)를 반환합니다.
#     """
#     # 데이터 준비 및 Log 변환
#     ref_f0 = np.log2(ref_data[:, 1] + 1)
#     target_f0 = np.log2(target_data[:, 1] + 1)
#
#     # DTW 실행: Audio(X)를 MIDI(Y)에 정렬
#     X_dtw = target_f0.reshape(1, -1)
#     Y_dtw = ref_f0.reshape(1, -1)
#     cost, path = librosa.sequence.dtw(
#         X=X_dtw,
#         Y=Y_dtw,
#         metric='euclidean'
#     )
#
#     # 정렬된 F0 값 계산 (중복 매핑 평균 처리)
#     aligned_f0_lists = [[] for _ in range(len(ref_f0))]
#
#     for audio_idx, midi_idx in path:  # path.T는 (audio_idx, midi_idx) 순서
#         if midi_idx < len(aligned_f0_lists):
#             aligned_f0_lists[midi_idx].append(target_f0[audio_idx])
#
#     aligned_f0_log = np.zeros_like(ref_f0)
#
#     for i in range(len(aligned_f0_log)):
#         if aligned_f0_lists[i]:
#             aligned_f0_log[i] = np.mean(aligned_f0_lists[i])
#
#     # 최종 출력은 Hz 스케일로 되돌립니다.
#     return (2 ** aligned_f0_log) - 1
#
#
# # --------------------------
# # 2. F0 스내핑 보정 함수
# # --------------------------
# def snap_f0_to_midi(aligned_pyin_f0, ref_midi_f0, max_error_cents):
#     """
#     DTW 정렬된 pYIN F0 값을 MIDI F0와 비교하여 오차가 임계값을 초과하면 MIDI 값으로 대체합니다.
#
#     """
#     corrected_f0 = np.copy(aligned_pyin_f0)
#
#     # F0 > 0 인 유효한 프레임 마스크 생성 (무음 제외)
#     valid_mask = (ref_midi_f0 > 0) & (aligned_pyin_f0 > 0)
#
#     pyin_valid = aligned_pyin_f0[valid_mask]
#     midi_valid = ref_midi_f0[valid_mask]
#
#     # 1. 오차 계산 (센트 단위)
#     cent_error = 1200 * np.abs(np.log2(pyin_valid / midi_valid))
#
#     # 2. 스내핑 조건 판단 (오차가 임계값보다 크면 True)
#     snapping_mask_local = cent_error >= max_error_cents
#
#     # 3. 전체 배열에 적용할 마스크를 생성하고 스내핑 위치 표시
#     snapping_mask_global = np.zeros_like(corrected_f0, dtype=bool)
#     snapping_mask_global[valid_mask] = snapping_mask_local
#
#     # 4. MIDI 값으로 대체 (스내핑)
#     corrected_f0[snapping_mask_global] = ref_midi_f0[snapping_mask_global]
#
#     return corrected_f0
#
#
# # --------------------------
# # 3. 시각화 함수
# # --------------------------
# def visualize_f0_snapping_comparison(file_paths, max_snapping_error):
#     """
#     MIDI F0, Raw pYIN F0, Corrected pYIN F0 세 가지를 비교 시각화합니다.
#     """
#     all_data = {}
#
#     # 1. MIDI F0 (기준) 로드
#     midi_path = file_paths["MIDI F0 (Ideal)"]
#     if not os.path.exists(midi_path):
#         print(f"🚨 오류: MIDI F0 파일 없음: {midi_path}")
#         return
#
#     midi_data = np.load(midi_path)
#     midi_f0 = midi_data[:, 1]
#     midi_time_axis = midi_data[:, 0]
#
#     all_data["MIDI F0 (Ideal)"] = midi_f0
#     min_len = len(midi_f0)
#
#     # 2. pYIN F0 로드, DTW 정렬 및 스내핑 보정
#     pYIN_label = "pYIN F0 (Audio)"
#     pyin_path = file_paths.get(pYIN_label)
#
#     if os.path.exists(pyin_path):
#         target_data = np.load(pyin_path)
#
#         print(f"🔄 {pYIN_label} 데이터를 MIDI F0에 DTW 정렬 중...")
#         aligned_pyin_f0_hz = apply_dtw_alignment(midi_data, target_data)
#
#         # 보정 전 데이터 추가
#         all_data[pYIN_label + " (Raw)"] = aligned_pyin_f0_hz
#
#         # 스내핑 보정 적용
#         print(f"🛠️ {pYIN_label} 데이터를 {max_snapping_error} cents 임계값으로 보정 중...")
#         corrected_pyin_f0 = snap_f0_to_midi(
#             aligned_pyin_f0_hz,
#             midi_f0,
#             max_error_cents=max_snapping_error
#         )
#
#         # 보정 후 데이터 추가
#         all_data[pYIN_label + " (Corrected)"] = corrected_pyin_f0
#
#         min_len = min(min_len, len(corrected_pyin_f0))  # 정렬되었으므로 길이는 MIDI 길이와 같을 것임.
#
#     if len(all_data) < 2:
#         print("🚨 오류: 비교할 pYIN F0 데이터 파일이 로드되지 않았습니다.")
#         return
#
#     # 3. 데이터 시각화
#     plt.figure(figsize=(18, 8))
#
#     styles = {
#         "MIDI F0 (Ideal)": {'color': 'black', 'linewidth': 3, 'linestyle': '-', 'alpha': 0.8},
#         "pYIN F0 (Audio) (Raw)": {'color': 'red', 'linewidth': 1.5, 'linestyle': ':', 'alpha': 0.7},
#         "pYIN F0 (Audio) (Corrected)": {'color': 'green', 'linewidth': 2, 'linestyle': '--', 'alpha': 0.9}
#     }
#
#     time_axis = midi_time_axis[:min_len]
#
#     for label, f0_values in all_data.items():
#         style = styles.get(label, {})
#         plt.plot(time_axis, f0_values[:min_len], label=label, **style)
#
#     plt.title(f"F0 Comparison: Raw vs. Snapped pYIN F0 (Snapping Threshold: {max_snapping_error} cents)")
#     plt.xlabel("Time (seconds)")
#     plt.ylabel("Frequency (Hz)")
#     plt.legend()
#     plt.ylim(50, 600)
#     plt.grid(True)
#
#     # 전체를 보여주기 위해 xlim을 주석 처리하거나 넓게 설정
#     # plt.xlim(0, 60)
#
#     plt.show()
#
#
# # --------------------------
# # 4. 메인 실행 블록
# # --------------------------
# if __name__ == "__main__":
#     print("🚀 F0 스내핑 보정 및 시각화 스크립트 시작")
#
#     visualize_f0_snapping_comparison(
#         NPY_FILE_PATHS,
#         max_snapping_error=MAX_SNAPPING_ERROR_CENTS
#     )
#
#     print("✅ 시각화 완료. 그래프 창을 닫으면 스크립트가 종료됩니다.")

import numpy as np
import matplotlib.pyplot as plt
import os
import librosa
import math

# --------------------------
# 🚨 사용자 설정: NPY 파일 경로 (noise 제거 안 한 pYIN 사용)
# --------------------------
NPY_FILE_PATHS = {
    "MIDI F0 (Ideal)": "C:/Users/howon/PycharmProjects/vocal_project/midi_melody_f0.npy",
    "pYIN F0 (Audio)": "C:/Users/howon/PycharmProjects/vocal_project/hanroro_spleeter_pYIN.npy"
}

# DTW 정렬 임계값 (예: 75 cents는 약 1/4 음)
MAX_SNAPPING_ERROR_CENTS = 75

# --------------------------
# 🚨 사용자 설정: 보정 F0 저장 경로 (새로 추가)
# --------------------------
OUTPUT_NPY_PATH = "C:/Users/howon/PycharmProjects/vocal_project/hanroro_pYIN_threshold.npy"


# --------------------------
# 1. F0 DTW 정렬 함수 (기존 코드와 동일)
# --------------------------
def apply_dtw_alignment(ref_data, target_data):
    # ... (기존 코드와 동일) ...
    # ... (생략) ...
    ref_f0 = np.log2(ref_data[:, 1] + 1)
    target_f0 = np.log2(target_data[:, 1] + 1)

    # DTW 실행: Audio(X)를 MIDI(Y)에 정렬
    X_dtw = target_f0.reshape(1, -1)
    Y_dtw = ref_f0.reshape(1, -1)
    cost, path = librosa.sequence.dtw(
        X=X_dtw,
        Y=Y_dtw,
        metric='euclidean'
    )

    aligned_f0_lists = [[] for _ in range(len(ref_f0))]

    for audio_idx, midi_idx in path:  # path.T는 (audio_idx, midi_idx) 순서로 가정 (librosa path는 (Y_idx, X_idx)를 반환)
        if midi_idx < len(aligned_f0_lists):
            aligned_f0_lists[midi_idx].append(target_f0[audio_idx])

    aligned_f0_log = np.zeros_like(ref_f0)

    for i in range(len(aligned_f0_log)):
        if aligned_f0_lists[i]:
            aligned_f0_log[i] = np.mean(aligned_f0_lists[i])

    return (2 ** aligned_f0_log) - 1


# --------------------------
# 2. F0 스내핑 보정 함수 (기존 코드와 동일)
# --------------------------
def snap_f0_to_midi(aligned_pyin_f0, ref_midi_f0, max_error_cents):
    # ... (기존 코드와 동일) ...
    # ... (생략) ...
    corrected_f0 = np.copy(aligned_pyin_f0)

    # F0 > 0 인 유효한 프레임 마스크 생성 (무음 제외)
    valid_mask = (ref_midi_f0 > 0) & (aligned_pyin_f0 > 0)

    pyin_valid = aligned_pyin_f0[valid_mask]
    midi_valid = ref_midi_f0[valid_mask]

    # 1. 오차 계산 (센트 단위)
    cent_error = 1200 * np.abs(np.log2(pyin_valid / midi_valid))

    # 2. 스내핑 조건 판단 (오차가 임계값보다 크면 True)
    snapping_mask_local = cent_error >= max_error_cents

    # 3. 전체 배열에 적용할 마스크를 생성하고 스내핑 위치 표시
    snapping_mask_global = np.zeros_like(corrected_f0, dtype=bool)
    snapping_mask_global[valid_mask] = snapping_mask_local

    # 4. MIDI 값으로 대체 (스내핑)
    corrected_f0[snapping_mask_global] = ref_midi_f0[snapping_mask_global]

    return corrected_f0


# --------------------------
# 3. 시각화 및 저장 함수 (수정)
# --------------------------
def visualize_f0_snapping_comparison(file_paths, max_snapping_error, output_path):
    """
    MIDI F0, Raw pYIN F0, Corrected pYIN F0 세 가지를 비교 시각화하고 보정 F0를 저장합니다.
    """
    all_data = {}

    # 1. MIDI F0 (기준) 로드
    midi_path = file_paths["MIDI F0 (Ideal)"]
    if not os.path.exists(midi_path):
        print(f"🚨 오류: MIDI F0 파일 없음: {midi_path}")
        return

    midi_data = np.load(midi_path)
    midi_f0 = midi_data[:, 1]
    midi_time_axis = midi_data[:, 0]

    all_data["MIDI F0 (Ideal)"] = midi_f0
    min_len = len(midi_f0)

    # 2. pYIN F0 로드, DTW 정렬 및 스내핑 보정
    pYIN_label = "pYIN F0 (Audio)"
    pyin_path = file_paths.get(pYIN_label)

    if os.path.exists(pyin_path):
        target_data = np.load(pyin_path)

        print(f"🔄 {pYIN_label} 데이터를 MIDI F0에 DTW 정렬 중...")
        aligned_pyin_f0_hz = apply_dtw_alignment(midi_data, target_data)

        # 보정 전 데이터 추가
        all_data[pYIN_label + " (Raw)"] = aligned_pyin_f0_hz

        # 스내핑 보정 적용
        print(f"🛠️ {pYIN_label} 데이터를 {max_snapping_error} cents 임계값으로 보정 중...")
        corrected_pyin_f0 = snap_f0_to_midi(
            aligned_pyin_f0_hz,
            midi_f0,
            max_error_cents=max_snapping_error
        )

        # 보정 후 데이터 추가
        all_data[pYIN_label + " (Corrected)"] = corrected_pyin_f0

        # --- 🚨 NPY 파일 저장 로직 추가 🚨 ---
        # 시간 축과 보정된 F0 값을 결합하여 2열 데이터로 만듭니다.
        output_data = np.column_stack((midi_time_axis[:len(corrected_pyin_f0)], corrected_pyin_f0))

        try:
            np.save(output_path, output_data)
            print(f"✅ 보정된 F0 데이터가 NPY 파일로 저장되었습니다: {output_path}")
        except Exception as e:
            print(f"🚨 NPY 파일 저장 중 오류 발생: {e}")

    if len(all_data) < 2:
        print("🚨 오류: 비교할 pYIN F0 데이터 파일이 로드되지 않았습니다.")
        return

    # 4. 데이터 시각화 (기존 코드와 동일)
    plt.figure(figsize=(18, 8))

    styles = {
        "MIDI F0 (Ideal)": {'color': 'black', 'linewidth': 3, 'linestyle': '-', 'alpha': 0.8},
        "pYIN F0 (Audio) (Raw)": {'color': 'red', 'linewidth': 1.5, 'linestyle': ':', 'alpha': 0.7},
        "pYIN F0 (Audio) (Corrected)": {'color': 'green', 'linewidth': 2, 'linestyle': '--', 'alpha': 0.9}
    }

    time_axis = midi_time_axis[:min_len]

    for label, f0_values in all_data.items():
        style = styles.get(label, {})
        plt.plot(time_axis, f0_values[:min_len], label=label, **style)

    plt.title(f"F0 Comparison: Raw vs. Snapped pYIN F0 (Snapping Threshold: {max_snapping_error} cents)")
    plt.xlabel("Time (seconds)")
    plt.ylabel("Frequency (Hz)")
    plt.legend()
    plt.ylim(50, 600)
    plt.grid(True)

    # 5. 그래프 출력
    plt.show()


# --------------------------
# 4. 메인 실행 블록
# --------------------------
if __name__ == "__main__":
    print("🚀 F0 스내핑 보정 및 시각화 스크립트 시작")

    visualize_f0_snapping_comparison(
        NPY_FILE_PATHS,
        max_snapping_error=MAX_SNAPPING_ERROR_CENTS,
        output_path=OUTPUT_NPY_PATH  # 저장 경로 전달
    )

    print("✅ 시각화 완료 및 보정 파일 저장 완료. 그래프 창을 닫으면 스크립트가 종료됩니다.")