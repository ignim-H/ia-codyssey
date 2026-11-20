#!/usr/bin/env bash
# 커스텀 이미지 빌드 + 포트 매핑 2회 접속 검증
source "$(dirname "$0")/lib.sh"
require_docker
start_log 04_build_run

APP="app"
docker rm -f web-8080 web-8081 >/dev/null 2>&1

note "Dockerfile 내용"
run "cat '$APP/Dockerfile'"

note "빌드"
run "docker build -t codyssey-web:1.0 '$APP'"
run "docker images codyssey-web"
run "docker inspect codyssey-web:1.0 --format '{{json .Config.Labels}}'"
run "docker inspect codyssey-web:1.0 --format '{{json .Config.Env}}'"

note "포트 매핑 실행 (호스트 8080 → 컨테이너 80)"
run "docker run -d -p 8080:80 --name web-8080 codyssey-web:1.0"

note "포트 매핑 실행 (호스트 8081 → 컨테이너 80, 같은 이미지로 두 번째 컨테이너)"
run "docker run -d -p 8081:80 -e APP_ENV=prod --name web-8081 codyssey-web:1.0"

sleep 3
run "docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}'"
run "curl -s http://localhost:8080 | grep -E '<h1>|MESSAGE'"
run "curl -s http://localhost:8081 | grep -E '<h1>|MESSAGE'"
run "curl -si http://localhost:8080/health"
run "docker exec web-8081 printenv APP_ENV"

note "헬스체크 상태 확인 (start-period 이후)"
sleep 10
run "docker inspect web-8080 --format '{{.State.Health.Status}}'"
run "docker logs web-8080 | tail -5"

echo
echo ">>> 지금 브라우저에서 http://localhost:8080 과 http://localhost:8081 을 열고"
echo ">>> 주소창이 보이게 캡처해서 docs/screenshots/port-8080.png, port-8081.png 로 저장하세요."
echo ">>> 캡처가 끝나면 'docker rm -f web-8080 web-8081' 로 정리하세요."
