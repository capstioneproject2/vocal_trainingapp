//파이썬 실행 라이브러리
// child_process 사용

const { spawn } = require("child_process");
const path = require("path");
//가상환경 python경로 지정!!!!!!!!!!!
const PYTHON_PATH = "C:/Users/howon/PycharmProjects/vocal_project/.venv/Scripts/python.exe";


// runPython 함수 선언
// script: 실행할 파이썬 파일 이름/경로
// args:   파이썬에 전달할 인자들(list 형태)
// options: { cwd }  → 파이썬이 기준으로 삼을 작업 디렉토리
function runPython(script, args = [], options = {}) {
  return new Promise((resolve, reject) => {
    const spawnOptions = {
      env:{
        ...process.env,
        PYTHONIOENCODING: "utf-8",  //파이썬 stdout/stderr를 utf-8로 강제 변경
      },
    };

    

    // cwd가 넘어오면 spawn 옵션에 추가
    if (options.cwd) {
      spawnOptions.cwd = options.cwd;
    }

    // python: 실행할 프로그램 (윈도우면 python, 리눅스/맥이면 필요시 python3로 변경)
    const py = spawn(PYTHON_PATH, [script, ...args], spawnOptions);

    // 파이썬이 print하는 데이터(JSON)를 받아서 저장할 변수
    let result = "";

    // 파이썬에서 print하는 데이터가 여기로 들어옴
    py.stdout.on("data", (data) => {
      result += data.toString("utf-8"); // 데이터가 여러 번 나눠서 들어오므로 result에 += 누적, utf-8로 인코딩
    });

    // 파이썬의 stderr(에러) 출력 -> 디버깅할 때 사용
    py.stderr.on("data", (data) => {
      console.error("[Python Error]", data.toString("utf-8"));
    });

    // 파이썬 프로세스 종료 시
    py.on("close", () => {
      try {
        // 파이썬이 print한 문자열을 JSON으로 반환
        resolve(JSON.parse(result));
      } catch (error) {
        reject("JSON parse error: " + result);
      }
    });
  });
}

// 모듈 export
module.exports = { runPython };
