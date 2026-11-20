#!/usr/bin/env bash
# Git 설정 확인 (사용자 정보/기본 브랜치는 미리 설정해 둘 것)
#   git config --global user.name  "이름"
#   git config --global user.email "이메일"
#   git config --global init.defaultBranch main
source "$(dirname "$0")/lib.sh"
start_log 07_git

run "git --version"
# credential/token 관련 줄은 기록하지 않음
run "git config --list --show-origin | grep -viE 'credential|token|password|helper'"
run "git config --global user.name"
run "git config --global init.defaultBranch"
run "git remote -v"
run "git branch -vv"
run "git log --oneline -5"
