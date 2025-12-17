import sys
import os
import json
import scipy.signal
import csv
import numpy as np
import crepe
import librosa

# ============================================================
# [설정] 유틸리티 및 전역 변수
# ============================================================
HOP_LENGTH = 0.01  # 10ms

def log(msg):
    """Node.js가 JSON 파싱을 방해받지 않도록 로그는 stderr로 출력"""
    print(f"[PY-LOG] {msg}", file=sys.stderr)

def error_exit(msg):
    """에러 발생 시 JSON 형식으로 에러 출력 후 종료"""
    err_data = {"status": "error", "message": msg}
    print(json.dumps(err_data, ensure_ascii=False))
    sys.exit(1)

# ============================================================
# [PART 1] 데이터 로드 및 CREPE 추출
# ============================================================
def extract_pitch_with_crepe(audio_path, save_path):
    log(f"CREPE 피치 추출 시작: {audio_path}")

    try:
        # CREPE는 16kHz 권장
        y, sr = librosa.load(audio_path, sr=16000, mono=True)

        # verbose=0으로 설정하여 불필요한 콘솔 출력 방지
        time, frequency, confidence, activation = crepe.predict(
            y, sr, viterbi=True, step_size=10, model_capacity='full', verbose=0
        )

        # 신뢰도 필터링
        threshold = 0.6
        frequency_clean = np.where(confidence >= threshold, frequency, 0.0)

        # 저장
        data = np.column_stack([time, frequency_clean])
        np.save(save_path, data)
        return True
    except Exception as e:
        log(f"CREPE 추출 중 오류 발생: {e}")
        return False

def load_f0_npy(path):
    if not os.path.exists(path): return None, None
    data = np.load(path)
    # 1차원 데이터일 경우 시간축 생성
    if data.ndim == 1:
        return np.arange(len(data)) * HOP_LENGTH, data
    return data[:, 0], data[:, 1]

def load_lyrics_from_csv(path):
    lyrics = []
    if not os.path.exists(path): return []
    with open(path, 'r', encoding='utf-8-sig') as f:
        reader = csv.reader(f)
        next(reader, None) # 헤더 스킵
        for row in reader:
            if len(row) >= 3:
                try: lyrics.append((float(row[0]), float(row[1]), row[2].strip()))
                except: continue
    return lyrics

# ============================================================
# [PART 2] 전처리 및 알고리즘 (Sync, DTW, Score)
# ============================================================
def clean_f0_data(f0, min_freq=50):
    cleaned = np.copy(f0)
    cleaned[cleaned < min_freq] = 0
    # 스파이크 제거
    for i in range(2, len(cleaned) - 2):
        if cleaned[i] > 0 and np.median(cleaned[i - 2:i + 3]) == 0:
            cleaned[i] = 0
    return cleaned

def sync_and_trim_audio(ref_f0, rec_f0):
    ref = np.nan_to_num(ref_f0)
    rec = np.nan_to_num(rec_f0)

    # Cross-Correlation
    n = min(len(ref), len(rec))
    corr = scipy.signal.correlate(ref[:n], rec[:n], mode='full')
    lags = scipy.signal.correlation_lags(len(ref[:n]), len(rec[:n]), mode='full')
    lag = lags[np.argmax(corr)]

    ref_offset = 0
    if lag < 0: # 녹음이 늦음
        rec_s = rec[abs(lag):]
        ref_s = ref
    else: # 녹음이 빠름
        rec_s = rec
        ref_s = ref[abs(lag):]
        ref_offset += abs(lag)

    min_l = min(len(ref_s), len(rec_s))
    ref_s, rec_s = ref_s[:min_l], rec_s[:min_l]

    active = np.where((ref_s > 0) | (rec_s > 0))[0]
    if len(active) == 0: return ref_s, rec_s, 0

    start, end = active[0], active[-1]
    ref_offset += start

    return ref_s[start:end+1], rec_s[start:end+1], ref_offset

def run_dtw_align(ref, rec):
    ref_log, rec_log = np.zeros_like(ref), np.zeros_like(rec)
    ref_log[ref > 0] = np.log2(ref[ref > 0])
    rec_log[rec > 0] = np.log2(rec[rec > 0])

    D, wp = librosa.sequence.dtw(X=ref_log.reshape(1, -1), Y=rec_log.reshape(1, -1), metric='euclidean')
    wp = wp[::-1]

    ref_a = ref[wp[:, 0]]
    rec_a = rec[wp[:, 1]]

    mask = (ref_a > 0) & (rec_a > 0)
    dist = np.mean(np.abs(ref_a[mask] - rec_a[mask])) if np.sum(mask) > 0 else 0

    return dist, wp, ref_a, rec_a

def calculate_rhythm_score(wp, ref_aligned, rec_aligned):
    ref_idx = wp[:, 0]
    rec_idx = wp[:, 1]
    mask = (ref_aligned > 0) & (rec_aligned > 0)

    if np.sum(mask) == 0: return 0, 0

    diff = np.abs(ref_idx[mask] - rec_idx[mask])
    mean_distortion = np.mean(diff)

    # 4프레임(0.04초) 밀림당 1점 감점 (가중치 0.25)
    score = max(0, 100 - (mean_distortion * 0.25))
    return mean_distortion, score

# ============================================================
# [PART 3] JSON 데이터 생성
# ============================================================
def generate_result_json(p_dist, r_dist, r_score, ref_arr, rec_arr, lyrics, wp, ref_offset):
    mapped_lyrics = []

    for start, end, text in lyrics:
        center_time = (start + end) / 2
        original_frame = int(center_time / HOP_LENGTH)
        trimmed_frame = original_frame - ref_offset

        if 0 <= trimmed_frame:
            # wp[:, 0] == Reference Index
            # Reference Index가 trimmed_frame과 가장 가까운 지점 찾기
            idx_matches = np.where(wp[:, 0] == trimmed_frame)[0]

            if len(idx_matches) == 0:
                # 정확히 일치하지 않을 경우 가장 가까운 값 찾기
                idx_match = np.argmin(np.abs(wp[:, 0] - trimmed_frame))
                if np.abs(wp[idx_match, 0] - trimmed_frame) < 10:
                    x_pos = int(idx_match)
                else:
                    x_pos = -1
            else:
                x_pos = int(idx_matches[0])

            if x_pos != -1 and x_pos < len(ref_arr):
                mapped_lyrics.append({
                    "text": text,
                    "time_sec": center_time,
                    "graph_index": x_pos
                })

    output_data = {
        "status": "success", # 성공 여부 플래그
        "meta": {
            "hop_length": HOP_LENGTH,
            "total_frames": len(ref_arr),
            "total_duration_sec": len(ref_arr) * HOP_LENGTH
        },
        "scores": {
            "pitch_error": round(float(p_dist), 2),
            "rhythm_error_frames": round(float(r_dist), 2),
            "rhythm_error_sec": round(float(r_dist * HOP_LENGTH), 2),
            "final_score": round(float(r_score), 2)
        },
        "graph_data": {
            # 소수점 1자리까지 반올림하여 전송량 감소
            "ref_pitch": np.round(ref_arr, 1).tolist(),
            "rec_pitch": np.round(rec_arr, 1).tolist()
        },
        "lyrics": mapped_lyrics
    }
    return output_data

# ============================================================
# [MAIN] Node.js 연동 메인 루프
# ============================================================
if __name__ == "__main__":
    # 1. 인자 확인
    if len(sys.argv) < 4:
        error_exit("Usage: python analyze.py <rec_wav> <ref_npy> <lyrics_csv>")

    # Node에서 받은 경로들
    REC_AUDIO_FILE = sys.argv[1]
    REF_F0_FILE = sys.argv[2]
    LYRICS_FILE = sys.argv[3]

    # CREPE 결과를 임시로 저장할 경로 생성 (파일명_temp.npy)
    # 분석 후 삭제하고 싶다면 나중에 os.remove 추가 가능
    REC_F0_TEMP_FILE = os.path.splitext(REC_AUDIO_FILE)[0] + "_temp_f0.npy"

    # 파일 존재 확인
    if not os.path.exists(REC_AUDIO_FILE): error_exit(f"File not found: {REC_AUDIO_FILE}")
    if not os.path.exists(REF_F0_FILE): error_exit(f"File not found: {REF_F0_FILE}")
    if not os.path.exists(LYRICS_FILE): error_exit(f"File not found: {LYRICS_FILE}")

    try:
        # 2. CREPE 실행 (오디오 -> F0 NPY)
        log("CREPE 분석 시작...")
        if not extract_pitch_with_crepe(REC_AUDIO_FILE, REC_F0_TEMP_FILE):
            error_exit("CREPE analysis failed")

        # 3. 데이터 로드
        t_ref, f0_ref = load_f0_npy(REF_F0_FILE)
        t_rec, f0_rec = load_f0_npy(REC_F0_TEMP_FILE)
        lyrics = load_lyrics_from_csv(LYRICS_FILE)

        if f0_ref is None or f0_rec is None:
            error_exit("Failed to load F0 data")

        # 4. 전처리 및 싱크
        f0_ref = clean_f0_data(f0_ref)
        f0_rec = clean_f0_data(f0_rec)
        ref_fin, rec_fin, offset = sync_and_trim_audio(f0_ref, f0_rec)

        # 5. DTW 정렬
        p_dist, wp, r_align, t_align = run_dtw_align(ref_fin, rec_fin)

        # 6. 점수 계산
        r_dist, r_score = calculate_rhythm_score(wp, r_align, t_align)

        # 7. JSON 결과 생성
        final_json = generate_result_json(
            p_dist, r_dist, r_score,
            r_align, t_align,
            lyrics, wp, offset
        )

        # [중요] 최종 JSON을 stdout으로 출력 (Node.js가 받아감)
        print(json.dumps(final_json, ensure_ascii=False))

        # (선택) 임시 파일 삭제
        if os.path.exists(REC_F0_TEMP_FILE):
            os.remove(REC_F0_TEMP_FILE)

    except Exception as e:
        error_exit(str(e))