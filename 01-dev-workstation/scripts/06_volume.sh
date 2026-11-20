#!/usr/bin/env bash
# Docker 볼륨 영속성: 컨테이너를 삭제해도 볼륨 데이터는 유지되는지 확인
source "$(dirname "$0")/lib.sh"
require_docker
start_log 06_volume

docker rm -f vol-test vol-test2 >/dev/null 2>&1
docker volume rm codyssey-data >/dev/null 2>&1

note "볼륨 생성 / 확인"
run "docker volume create codyssey-data"
run "docker volume ls --filter name=codyssey-data"
run "docker volume inspect codyssey-data --format '{{.Name}} | driver={{.Driver}} | mountpoint={{.Mountpoint}}'"

note "컨테이너 1 에 볼륨 연결 후 데이터 기록"
run "docker run -d --name vol-test -v codyssey-data:/data ubuntu:22.04 sleep infinity"
run "docker exec vol-test bash -c 'echo \"saved at \$(date)\" > /data/hello.txt && cat /data/hello.txt'"

note "비교용: 볼륨 밖(/tmp)에도 기록"
run "docker exec vol-test bash -c 'echo temp > /tmp/temp.txt && ls /tmp/temp.txt'"

note "컨테이너 1 삭제"
run "docker rm -f vol-test"
run "docker ps -a --filter name=vol-test"

note "새 컨테이너 2 에 같은 볼륨 연결 → 데이터 유지 확인"
run "docker run -d --name vol-test2 -v codyssey-data:/data ubuntu:22.04 sleep infinity"
run "docker exec vol-test2 cat /data/hello.txt"
run "docker exec vol-test2 ls /tmp/temp.txt"

note "정리 (볼륨은 남겨 둠: 'docker volume rm codyssey-data' 로 삭제 가능)"
run "docker rm -f vol-test2"
