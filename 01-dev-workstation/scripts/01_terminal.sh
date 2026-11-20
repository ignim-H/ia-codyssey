#!/usr/bin/env bash
# 터미널 기본 조작: 위치 확인, 목록(숨김 포함), 이동, 생성, 복사, 이동/이름변경, 삭제, 내용 확인, 빈 파일
source "$(dirname "$0")/lib.sh"
start_log 01_terminal

P="practice"
rm -rf "$P"

note "현재 위치 확인 / 절대경로 vs 상대경로"
run "pwd"
run "cd '$PWD' && pwd && cd ./scripts && pwd && cd .. && pwd"

note "디렉토리 생성 (-p: 중간 경로까지 한 번에)"
run "mkdir -p '$P/docs' '$P/backup'"

note "목록 확인 (숨김 파일 포함)"
run "cd '$P' && ls -la"

note "빈 파일 생성 / 숨김 파일 생성"
run "cd '$P' && touch empty.txt .hidden_config && ls -la"

note "파일 내용 작성 및 확인"
run "cd '$P' && echo 'Hello Codyssey' > docs/note.txt && echo 'second line' >> docs/note.txt && cat docs/note.txt"
run "cd '$P' && head -n 1 docs/note.txt && wc -l docs/note.txt"

note "복사"
run "cd '$P' && cp docs/note.txt backup/note_copy.txt && ls -l backup"

note "이동 / 이름 변경"
run "cd '$P' && mv backup/note_copy.txt backup/note_renamed.txt && mv empty.txt docs/ && ls -l backup docs"

note "삭제"
run "cd '$P' && rm backup/note_renamed.txt && rmdir backup && ls -la"

note "트리 형태로 최종 구조 확인"
run "cd '$P' && find . | sort"
