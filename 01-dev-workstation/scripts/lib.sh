#!/usr/bin/env bash
# 공통 헬퍼: 명령어와 출력 결과를 함께 로그 파일에 남긴다.
# 사용법: source lib.sh; start_log 01_terminal; run "pwd"

# Windows Git Bash: docker.exe 인자(/data 등)가 Windows 경로로 바뀌는 것 방지
export MSYS_NO_PATHCONV=1

MISSION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$MISSION_DIR/logs"
mkdir -p "$LOG_DIR"
cd "$MISSION_DIR" || exit 1   # 모든 명령은 미션 폴더 기준 상대경로로 실행

start_log() {
  local name="$1"
  LOG_FILE="$LOG_DIR/${name}.log"
  : > "$LOG_FILE"
  echo "# $(date '+%Y-%m-%d %H:%M:%S') | $name" | tee -a "$LOG_FILE"
}

# 명령어 입력($ ...)과 출력 결과를 같이 기록. 실패해도 스크립트는 계속 진행.
run() {
  echo "\$ $*" | mask | tee -a "$LOG_FILE"
  bash -c "$*" 2>&1 | mask | tee -a "$LOG_FILE"
  echo | tee -a "$LOG_FILE"
}

# 섹션 구분 주석
note() {
  echo "# --- $* ---" | tee -a "$LOG_FILE"
}

# 민감정보 마스킹: 토큰/비밀번호 형태 문자열, 홈 디렉토리 사용자명
mask() {
  # macOS 기본 sed(BSD)는 대소문자 무시 플래그가 없어 perl 사용 (macOS/Linux 기본 탑재)
  perl -pe '
    s/(gh[pousr]_)[A-Za-z0-9]{10,}/$1****MASKED****/g;
    s/\b((?:token|password|passwd|secret)\b\s*[=:]\s*)\S+/$1****MASKED****/gi;
    s#/Users/[^/\s]+#/Users/<user>#g;
    s#/home/[^/\s]+#/home/<user>#g;
  '
}

require_docker() {
  if ! docker info >/dev/null 2>&1; then
    echo "[!] Docker 데몬에 연결할 수 없습니다. OrbStack 앱을 먼저 실행하세요." >&2
    exit 1
  fi
}
