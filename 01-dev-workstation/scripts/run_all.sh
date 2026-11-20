#!/usr/bin/env bash
# 전체 실습을 순서대로 실행하고 logs/ 에 결과를 저장한다.
cd "$(dirname "$0")" || exit 1
for s in 00_env 01_terminal 02_permissions 03_docker_basic 04_build_run 05_bind_mount 06_volume 07_git 08_troubleshoot 09_compose; do
  echo; echo "==================== $s ===================="
  bash "./$s.sh"
done
echo; echo "완료. 로그 위치: $(cd .. && pwd)/logs"
perl fill_readme.pl
