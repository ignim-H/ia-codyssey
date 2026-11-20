#!/usr/bin/env bash
# 실행 환경 정보 수집 (OS / 쉘 / 터미널 / Docker / Git)
source "$(dirname "$0")/lib.sh"
start_log 00_env

if command -v sw_vers >/dev/null 2>&1; then
  run "sw_vers"
elif command -v cmd >/dev/null 2>&1; then
  run "cmd /c ver"
else
  run "cat /etc/os-release | head -3"
fi
run "uname -sm"
run "echo \"SHELL=\$SHELL\"; \$SHELL --version 2>/dev/null | head -1"
run "echo \"TERMINAL=\${TERM_PROGRAM:-unknown} \${TERM_PROGRAM_VERSION:-}\""
run "docker --version"
run "docker compose version"
run "git --version"
run "docker info --format 'Engine: {{.ServerVersion}} | {{.OperatingSystem}}'"
