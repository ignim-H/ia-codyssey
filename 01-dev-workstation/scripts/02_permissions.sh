#!/usr/bin/env bash
# 권한 실습: 파일 1개 + 디렉토리 1개, 변경 전/후 비교
# Windows(NTFS) 위의 Git Bash 에서는 리눅스 권한 비트가 저장되지 않아 chmod 가 반영되지 않는다
# (logs/02_permissions_windows.log, README 13-6 참고).
# → 리눅스 파일시스템을 가진 ubuntu 컨테이너 안에서, root 가 아닌 일반 사용자(uid 1000)로 실습한다.
#   (root 는 r/w 권한 검사를 무시하므로 일반 사용자로 해야 차이가 보인다)
source "$(dirname "$0")/lib.sh"
require_docker
start_log 02_permissions

mkdir -p practice
cat > practice/perm_lab.sh <<'LAB'
p() { echo "\$ $*"; bash -c "$*" 2>&1; echo; }
cd /tmp && mkdir -p perm/secret_dir && cd perm
printf 'echo "script executed"\n' > run.sh
echo hello > secret_dir/inside.txt

echo "# --- 실행 사용자 (root 아님) ---"
p "id"

echo "# --- [파일] 변경 전 (기본 644) ---"
p "ls -l run.sh"
p "./run.sh"

echo "# --- [파일] chmod 755 (rwxr-xr-x) → 실행 가능 ---"
p "chmod 755 run.sh && ls -l run.sh"
p "./run.sh"

echo "# --- [파일] chmod 644 (rw-r--r--) → 실행 불가 ---"
p "chmod 644 run.sh && ls -l run.sh"
p "./run.sh"

echo "# --- [파일] 심볼릭 모드 u+x ---"
p "chmod u+x run.sh && ls -l run.sh"

echo "# --- [파일] chmod 444 (r--r--r--) → 쓰기 불가 ---"
p "chmod 444 run.sh && ls -l run.sh && echo more >> run.sh"

echo "# --- [디렉토리] 변경 전 ---"
p "ls -ld secret_dir && ls secret_dir"

echo "# --- [디렉토리] chmod 700 → 소유자만 접근 ---"
p "chmod 700 secret_dir && ls -ld secret_dir"

echo "# --- [디렉토리] chmod 300 (r 제거) → 목록 조회 불가, x 가 있어 파일 직접 접근은 가능 ---"
p "chmod 300 secret_dir && ls -ld secret_dir && ls secret_dir"
p "cat secret_dir/inside.txt"

echo "# --- [디렉토리] chmod 600 (x 제거) → 내부 파일 접근 불가 ---"
p "chmod 600 secret_dir && ls -ld secret_dir"
p "cat secret_dir/inside.txt"

echo "# --- [디렉토리] chmod 755 로 복구 ---"
p "chmod 755 secret_dir && ls -ld secret_dir && ls secret_dir"
LAB

HOST_DIR="$(pwd -W 2>/dev/null || pwd)"
note "ubuntu 컨테이너(리눅스 파일시스템)에서 일반 사용자 uid 1000 으로 실습"
run "docker run --rm --user 1000:1000 -v '$HOST_DIR/practice/perm_lab.sh':/lab.sh:ro ubuntu:22.04 bash /lab.sh"
