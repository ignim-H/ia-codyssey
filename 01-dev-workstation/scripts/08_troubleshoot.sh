#!/usr/bin/env bash
# 트러블슈팅 재현: 실제로 오류를 일으키고 → 원인 확인 → 해결하는 과정을 로그로 남긴다.
source "$(dirname "$0")/lib.sh"
require_docker
start_log 08_troubleshoot

docker rm -f ts-a ts-b ts-name >/dev/null 2>&1

note "[케이스 1] 포트 충돌: 같은 호스트 포트(8090)를 두 컨테이너가 사용"
run "docker run -d -p 8090:80 --name ts-a codyssey-web:1.0"
run "docker run -d -p 8090:80 --name ts-b codyssey-web:1.0"
note "확인: 누가 8090 을 쓰고 있는가"
run "docker ps --filter publish=8090 --format '{{.Names}} {{.Ports}}'"
run "lsof -nP -iTCP:8090 -sTCP:LISTEN 2>/dev/null | head -3 || netstat -ano | grep ':8090' | head -3"
note "해결: 생성 실패한 컨테이너 제거 후 다른 호스트 포트(8091)로 실행"
run "docker rm -f ts-b; docker run -d -p 8091:80 --name ts-b codyssey-web:1.0"
sleep 1
run "curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://localhost:8091"

note "[케이스 2] 컨테이너 이름 중복"
run "docker run -d --name ts-name ubuntu:22.04 sleep 60"
run "docker run -d --name ts-name ubuntu:22.04 sleep 60"
note "확인: 중지된 컨테이너도 이름을 점유한다"
run "docker ps -a --filter name=ts-name --format '{{.Names}} {{.Status}}'"
note "해결: 기존 컨테이너 삭제 후 재실행 (또는 --rm 사용)"
run "docker rm -f ts-name && docker run -d --name ts-name ubuntu:22.04 sleep 60"

note "정리"
run "docker rm -f ts-a ts-b ts-name"
