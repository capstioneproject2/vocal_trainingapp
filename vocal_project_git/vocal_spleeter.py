import os
from spleeter.separator import Separator
# 파일: vocal_spleeter.py


# 여기서부터가 중요합니다!
if __name__ == '__main__':


    # 1. 분리 모델 설정 (2stems: 보컬/반주)
    separator = Separator('spleeter:2stems')

    # 2. 입력 파일 경로 및 출력 폴더 설정
    audio_file_path = 'C:/Users/howon/PycharmProjects/vocal_project/hanroro_original.wav'
    output_folder = 'C:/Users/howon/PycharmProjects/vocal_project'

    # 출력 폴더가 없으면 생성
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    print(f"'{audio_file_path}' 분리 시작...")

    # 3. 분리 실행
    # 'output_folder'에 결과가 저장됩니다.
    separator.separate_to_file(
        audio_file_path,
        output_folder,
        # 'wav' 형태로 저장하여 CREPE 입력으로 사용하기 용이하게 설정
        codec='wav'
    )

    print(f"분리 완료. 결과는 '{output_folder}' 폴더에 저장되었습니다.")

    # 분리된 보컬 파일 경로 예시 (파일 이름은 입력 파일명 기반으로 결정됨)
    input_filename = os.path.basename(audio_file_path).split('.')[0]
    vocal_file_path = os.path.join(output_folder, input_filename, 'hanroro_spleeter_output.wav')
    print(f"보컬 트랙: {vocal_file_path}")