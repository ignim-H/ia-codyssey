#!/usr/bin/env bash
# 보너스: Docker Compose (멀티 컨테이너 + 네트워크 + 환경 변수 + 운영 명령)
source "$(dirname "$0")/lib.sh"
require_docker
start_log 09_compose

C="compose"
run "cat '$C/docker-compose.yml'"
run "cd '$C' && docker compose up -d --build"
sleep 8
run "cd '$C' && docker compose ps"
note "서비스 이름(web)으로 컨테이너 간 통신 확인 (서비스 디스커버리)"
run "cd '$C' && docker compose exec -T client wget -qO- http://web/health"
run "cd '$C' && docker compose exec -T client wget -qO- http://web | grep '<h1>'"
note "redis 서비스에 이름으로 접속"
run "cd '$C' && docker compose exec -T web sh -c 'printf \"PING\r\n\" | nc -w 2 redis 6379'"
note "환경 변수로 호스트 포트/모드 변경"
run "cd '$C' && docker compose exec -T web printenv APP_ENV"
run "curl -s -o /dev/null -w 'HTTP %{http_code}\n' http://localhost:\${WEB_PORT:-8888}"
run "cd '$C' && docker compose logs --tail 5 web"
run "cd '$C' && docker compose down"
run "cd '$C' && docker compose ps"
