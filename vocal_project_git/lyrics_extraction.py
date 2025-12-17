# # #midi 파일, 가사 text, 원곡 spleeter 세가지 사용해서 가사 정보 추출
# import pretty_midi
# import os
#
# # --------------------------
# # 🚨 사용자 설정: MIDI 파일 경로
# # --------------------------
# MIDI_FILE_PATH = "C:/Users/howon/PycharmProjects/vocal_project/사랑하게 될 거야_멜로디악보_MIDI.mid"
#
#
# # --------------------------
# # 1. pretty_midi 가사 추출 및 모든 인코딩 대입 시도
# # --------------------------
# def extract_midi_data_final(midi_file_path):
#     if not os.path.exists(midi_file_path):
#         return None, None
#
#     try:
#         midi_data = pretty_midi.PrettyMIDI(midi_file_path)
#     except Exception as e:
#         print(f"🚨 MIDI 파일 로드 중 오류 발생: {e}")
#         return None, None
#
#     # --- 음표 데이터 추출 (전체 길이 계산용) ---
#     all_notes = []
#     for instrument in midi_data.instruments:
#         if not instrument.is_drum:
#             for note in instrument.notes:
#                 all_notes.append({"start_time": note.start, "end_time": note.end})
#     all_notes.sort(key=lambda x: x['start_time'])
#
#     # --- 🚨 인코딩 리스트: 모든 가능성 대입 🚨 ---
#     ENCODINGS = ['utf-8', 'euc-kr', 'latin-1', 'cp949', 'iso-8859-1']
#
#     lyric_data = []
#
#     if not midi_data.lyrics:
#         print("🔍 MIDI 파일에 가사 정보가 없습니다.")
#         return all_notes, []
#
#     for lyric_event in midi_data.lyrics:
#         original_text = lyric_event.text
#         decoded_text = None
#
#         # 1. pretty_midi가 읽어온 텍스트를 Latin-1 바이트로 역변환
#         try:
#             byte_data = original_text.encode('latin-1', errors='ignore')
#         except:
#             continue
#
#         # 2. 모든 인코딩을 대입하여 시도
#         for encoding in ENCODINGS:
#             try:
#                 decoded_text = byte_data.decode(encoding, errors='strict').strip()
#                 # 텍스트가 실제로 한글을 포함하는 유효한 문자열인지 확인 (깨짐 문자 제거)
#                 if any('\uac00' <= char <= '\ud7a3' for char in decoded_text):
#                     break  # 성공적으로 한글이 복원된 것으로 판단하고 루프 종료
#             except:
#                 continue
#
#         if decoded_text:
#             lyric_data.append({"time": lyric_event.time, "text": decoded_text})
#
#     print(f"🔍 총 {len(lyric_data)}개의 유효한 가사 이벤트 추출.")
#     return all_notes, lyric_data
#
#
# # --------------------------
# # 2. 메인 실행 블록 (튜플 변환 함수 포함)
# # --------------------------
# def transform_midi_lyrics_to_intervals(midi_lyric_data, total_duration_sec):
#     # ... (이전과 동일한 튜플 변환 로직) ...
#     if not midi_lyric_data:
#         return []
#     lyrics_intervals = []
#     num_lyrics = len(midi_lyric_data)
#     for i in range(num_lyrics):
#         lyric_event = midi_lyric_data[i]
#         start_time = lyric_event['time']
#         text = lyric_event['text']
#         end_time = midi_lyric_data[i + 1]['time'] if i < num_lyrics - 1 else total_duration_sec
#         lyrics_intervals.append((start_time, end_time, text))
#     return lyrics_intervals
#
#
# if __name__ == "__main__":
#     print("🚀 MIDI 파일 파싱 시작...")
#
#     # 🚨 pretty_midi만 사용하여 추출 시도
#     midi_note_data, midi_lyric_data = extract_midi_data_final(MIDI_FILE_PATH)
#
#     if midi_note_data and midi_lyric_data:
#         total_duration = midi_note_data[-1]['end_time'] if midi_note_data else 0
#         lyrics_for_dtw_plot = transform_midi_lyrics_to_intervals(midi_lyric_data, total_duration)
#
#         print(f"\n✅ 가사 튜플 변환 완료. 총 {len(lyrics_for_dtw_plot)}개의 구간 추출.")
#         print("\n--- 추출된 가사 ---")
#         for interval in lyrics_for_dtw_plot[:10]:
#             print(f"T: {interval[0]:.2f}s | Text: '{interval[2]}'")
#     else:
#         print("\n❌ MIDI 음표 또는 가사 데이터 추출에 최종 실패했습니다. 파일 자체를 확인해 보세요.")

import pretty_midi
import os
import csv  # 🚨 CSV 저장을 위한 모듈 추가

# --------------------------
# 🚨 사용자 설정: MIDI 파일 경로
# --------------------------
MIDI_FILE_PATH = "C:/Users/howon/PycharmProjects/vocal_project/사랑하게 될 거야_멜로디악보_MIDI.mid"

# --------------------------
# 🚨 사용자 설정: 저장될 CSV 파일 경로
# --------------------------
OUTPUT_CSV_PATH = "C:/Users/howon/PycharmProjects/vocal_project/hanroro_lyrics.csv"


# --------------------------
# 1. pretty_midi 가사 추출 및 모든 인코딩 대입 시도
# --------------------------
def extract_midi_data_final(midi_file_path):
    if not os.path.exists(midi_file_path):
        return None, None

    try:
        midi_data = pretty_midi.PrettyMIDI(midi_file_path)
    except Exception as e:
        print(f"🚨 MIDI 파일 로드 중 오류 발생: {e}")
        return None, None

    # --- 음표 데이터 추출 (전체 길이 계산용) ---
    all_notes = []
    for instrument in midi_data.instruments:
        if not instrument.is_drum:
            for note in instrument.notes:
                all_notes.append({"start_time": note.start, "end_time": note.end})
    all_notes.sort(key=lambda x: x['start_time'])

    # --- 🚨 인코딩 리스트: 모든 가능성 대입 🚨 ---
    ENCODINGS = ['utf-8', 'euc-kr', 'latin-1', 'cp949', 'iso-8859-1']

    lyric_data = []

    if not midi_data.lyrics:
        print("🔍 MIDI 파일에 가사 정보가 없습니다.")
        return all_notes, []

    for lyric_event in midi_data.lyrics:
        original_text = lyric_event.text
        decoded_text = None

        # 1. pretty_midi가 읽어온 텍스트를 Latin-1 바이트로 역변환
        try:
            byte_data = original_text.encode('latin-1', errors='ignore')
        except:
            continue

        # 2. 모든 인코딩을 대입하여 시도
        for encoding in ENCODINGS:
            try:
                decoded_text = byte_data.decode(encoding, errors='strict').strip()
                # 텍스트가 실제로 한글을 포함하는 유효한 문자열인지 확인 (깨짐 문자 제거)
                if any('\uac00' <= char <= '\ud7a3' for char in decoded_text):
                    break  # 성공적으로 한글이 복원된 것으로 판단하고 루프 종료
            except:
                continue

        if decoded_text:
            lyric_data.append({"time": lyric_event.time, "text": decoded_text})

    print(f"🔍 총 {len(lyric_data)}개의 유효한 가사 이벤트 추출.")
    return all_notes, lyric_data


# --------------------------
# 2. 튜플 변환 함수
# --------------------------
def transform_midi_lyrics_to_intervals(midi_lyric_data, total_duration_sec):
    if not midi_lyric_data:
        return []
    lyrics_intervals = []
    num_lyrics = len(midi_lyric_data)
    for i in range(num_lyrics):
        lyric_event = midi_lyric_data[i]
        start_time = lyric_event['time']
        text = lyric_event['text']
        end_time = midi_lyric_data[i + 1]['time'] if i < num_lyrics - 1 else total_duration_sec
        # 튜플 형식: (start_time, end_time, text)
        lyrics_intervals.append((start_time, end_time, text))
    return lyrics_intervals


# --------------------------
# 3. 💾 CSV 파일 저장 함수 (새로 추가)
# --------------------------
def save_lyrics_to_csv(lyrics_intervals, file_path):
    """
    (start_time, end_time, text) 튜플 리스트를 CSV 파일로 저장합니다.
    """
    try:
        # 'w' 모드로 파일을 열고 newline='' 설정으로 빈 줄 생성을 방지합니다.
        # encoding='utf-8-sig'는 한글 깨짐을 방지하고 엑셀에서 바로 열리도록 BOM을 추가합니다.
        with open(file_path, 'w', newline='', encoding='utf-8-sig') as f:
            writer = csv.writer(f)

            # 헤더(Header) 작성
            writer.writerow(['start_time', 'end_time', 'lyric_text'])

            # 데이터 작성
            writer.writerows(lyrics_intervals)

        print(f"✅ 가사 구간 정보가 다음 경로에 저장되었습니다: {file_path}")
    except Exception as e:
        print(f"🚨 CSV 파일 저장 중 오류 발생: {e}")


# --------------------------
# 4. 메인 실행 블록 (저장 함수 호출 추가)
# --------------------------
if __name__ == "__main__":
    print("🚀 MIDI 파일 파싱 시작...")

    midi_note_data, midi_lyric_data = extract_midi_data_final(MIDI_FILE_PATH)

    if midi_note_data and midi_lyric_data:
        total_duration = midi_note_data[-1]['end_time'] if midi_note_data else 0
        lyrics_for_dtw_plot = transform_midi_lyrics_to_intervals(midi_lyric_data, total_duration)

        print(f"\n✅ 가사 튜플 변환 완료. 총 {len(lyrics_for_dtw_plot)}개의 구간 추출.")

        # 🚨 파일 저장 함수 호출 🚨
        save_lyrics_to_csv(lyrics_for_dtw_plot, OUTPUT_CSV_PATH)

        print("\n--- 추출된 가사 (미리보기) ---")
        for interval in lyrics_for_dtw_plot[:10]:
            print(f"Start: {interval[0]:.2f}s | End: {interval[1]:.2f}s | Text: '{interval[2]}'")

    else:
        print("\n❌ MIDI 음표 또는 가사 데이터 추출에 최종 실패했습니다. 파일 자체를 확인해 보세요.")