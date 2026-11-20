#!/usr/bin/env bash
# Docker 설치 점검 + 기본 운영 명령 + hello-world / ubuntu 실습
source "$(dirname "$0")/lib.sh"
require_docker
start_log 03_docker_basic

note "설치 및 데몬 점검"
run "docker --version"
run "docker info --format 'Server Version: {{.ServerVersion}} | OS: {{.OperatingSystem}} | Arch: {{.Architecture}} | CPUs: {{.NCPU}} | Mem: {{.MemTotal}} | Containers: {{.Containers}} | Images: {{.Images}}'"
run "docker context ls"

note "이미지 다운로드 / 목록"
run "docker pull hello-world"
run "docker pull ubuntu:22.04"
run "docker images"

note "hello-world 실행"
run "docker run --name hello-test hello-world"

note "ubuntu 컨테이너 내부 명령 실행"
run "docker run --rm ubuntu:22.04 bash -c 'echo \"inside container: \$(hostname)\"; cat /etc/os-release | head -2; ls /'"

note "컨테이너 실행(백그라운드) / 목록 / 중지"
run "docker run -d --name ubuntu-keep ubuntu:22.04 sleep infinity"
run "docker ps"
run "docker exec ubuntu-keep bash -c 'echo hello from exec; ls /tmp'"
run "docker stop ubuntu-keep"
run "docker ps"
run "docker ps -a"

note "attach vs exec 관찰"
# attach: 컨테이너의 메인 프로세스(PID 1)에 붙음 → 거기서 exit 하면 컨테이너가 종료됨
# exec : 별도 프로세스를 새로 띄움 → exit 해도 메인 프로세스는 계속 살아 있음
run "docker run -dit --name attach-test ubuntu:22.04 bash"
run "docker exec attach-test bash -c 'exit 0'; docker ps --filter name=attach-test --format '{{.Names}} {{.Status}}'"
run "echo 'exit' | docker attach attach-test; sleep 1; docker ps -a --filter name=attach-test --format '{{.Names}} {{.Status}}'"

note "로그 / 리소스 확인"
run "docker logs hello-test | head -5"
run "docker start ubuntu-keep && docker stats --no-stream"

note "정리"
run "docker rm -f hello-test ubuntu-keep attach-test"
run "docker ps -a"
