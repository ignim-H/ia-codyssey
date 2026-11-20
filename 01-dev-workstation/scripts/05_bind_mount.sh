#!/usr/bin/env bash
# 바인드 마운트: 호스트 파일 변경이 재빌드 없이 컨테이너에 즉시 반영되는지 확인
source "$(dirname "$0")/lib.sh"
require_docker
start_log 05_bind_mount

SRC="practice/bind-site"
rm -rf "$SRC"; mkdir -p "$SRC"
cp "app/site/index.html" "$SRC/index.html"
docker rm -f web-bind >/dev/null 2>&1
# Windows Git Bash 에서는 C:/... 형태 경로가 필요 (pwd -W), macOS/Linux 는 pwd
HOST_DIR="$(pwd -W 2>/dev/null || pwd)"

note "호스트 디렉토리를 컨테이너 웹 루트에 바인드 마운트"
run "docker run -d -p 8082:80 --name web-bind -v '$HOST_DIR/$SRC':/usr/share/nginx/html codyssey-web:1.0"
sleep 2
run "docker inspect web-bind --format '{{range .Mounts}}{{.Type}}: {{.Source}} -> {{.Destination}}{{end}}'"

note "변경 전"
run "grep MESSAGE '$SRC/index.html'"
run "curl -s http://localhost:8082 | grep MESSAGE"

note "호스트에서 파일 수정 (컨테이너 재시작/재빌드 없음)"
run "sed -i.bak 's/MESSAGE: original/MESSAGE: changed on host at $(date +%H:%M:%S)/' '$SRC/index.html' && rm -f '$SRC/index.html.bak'"

note "변경 후"
run "grep MESSAGE '$SRC/index.html'"
run "curl -s http://localhost:8082 | grep MESSAGE"
run "docker exec web-bind grep MESSAGE /usr/share/nginx/html/index.html"

echo
echo ">>> 원하면 브라우저로 http://localhost:8082 변경 전/후를 캡처하세요."
echo ">>> 정리: docker rm -f web-bind"
