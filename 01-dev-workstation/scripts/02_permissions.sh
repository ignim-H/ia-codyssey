#!/usr/bin/env bash
# 권한 실습: 파일 1개 + 디렉토리 1개, 변경 전/후 비교
source "$(dirname "$0")/lib.sh"
start_log 02_permissions

P="practice/perm"
rm -rf "$P"; mkdir -p "$P/secret_dir"
echo 'echo "script executed"' > "$P/run.sh"
echo "hello" > "$P/secret_dir/inside.txt"

note "[파일] 변경 전"
run "ls -l '$P/run.sh'"
run "./$P/run.sh"

note "[파일] chmod 755 (rwxr-xr-x) → 실행 가능"
run "chmod 755 '$P/run.sh' && ls -l '$P/run.sh'"
run "./$P/run.sh"

note "[파일] chmod 644 (rw-r--r--) → 실행 불가"
run "chmod 644 '$P/run.sh' && ls -l '$P/run.sh'"
run "./$P/run.sh"

note "[파일] 심볼릭 모드: u+x"
run "chmod u+x '$P/run.sh' && ls -l '$P/run.sh'"

note "[디렉토리] 변경 전"
run "ls -ld '$P/secret_dir' && ls '$P/secret_dir'"

note "[디렉토리] chmod 700 → 소유자만 접근"
run "chmod 700 '$P/secret_dir' && ls -ld '$P/secret_dir'"

note "[디렉토리] chmod 300 (r 제거) → 목록 조회 불가, x 있으므로 파일 직접 접근은 가능"
run "chmod 300 '$P/secret_dir' && ls -ld '$P/secret_dir' && ls '$P/secret_dir'"
run "cat '$P/secret_dir/inside.txt'"

note "[디렉토리] chmod 600 (x 제거) → 내부 진입/접근 불가"
run "chmod 600 '$P/secret_dir' && ls -ld '$P/secret_dir' && cat '$P/secret_dir/inside.txt'"

note "[디렉토리] chmod 755 로 복구"
run "chmod 755 '$P/secret_dir' && ls -ld '$P/secret_dir' && ls '$P/secret_dir'"
