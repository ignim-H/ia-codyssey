#!/usr/bin/env bash
# 제출 마무리: README 로그 갱신 → 민감정보 점검 → 스크린샷 확인 → 커밋 → GitHub push
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")/.." || exit 1

echo "== 0) Git 사용자 확인"
n="$(git config user.name)"; e="$(git config user.email)"
if [ -z "$n" ] || [ -z "$e" ] || [ "$n" = "본인이름" ] || [ "$e" = "GitHub이메일" ]; then
  echo "[!] 먼저 설정하세요:"
  echo '    git config --global user.name  "이름"'
  echo '    git config --global user.email "GitHub 이메일"'
  echo '    git config --global init.defaultBranch main'
  exit 1
fi

echo "== 1) GitHub 저장소 연결 확인"
if [ ! -d ../.git ]; then
  echo "   .git 없음 → GitHub 저장소와 연결"
  ( cd .. && git init -b main >/dev/null && git remote add origin https://github.com/ignim-H/ia-codyssey.git \
      && git fetch origin main && git reset origin/main >/dev/null ) || exit 1
fi
bash scripts/07_git.sh >/dev/null   # 원격 연결된 상태로 Git 로그 다시 기록

echo "== 1-2) README 로그 갱신"
perl scripts/fill_readme.pl || exit 1

echo "== 2) 민감정보 점검"
if grep -rnIE 'ghp_[A-Za-z0-9]{10,}|github_pat_[A-Za-z0-9_]{10,}|-----BEGIN [A-Z ]*PRIVATE KEY' \
     --exclude-dir=.git --exclude=finish.sh . ; then
  echo "[!] 토큰/개인키로 보이는 문자열이 있습니다. 지우고 다시 실행하세요."; exit 1
fi
echo "   clean"

echo "== 3) 스크린샷 확인"
missing=0
for s in port-8080 port-8081 vscode-github; do
  if [ -f "docs/screenshots/$s.png" ]; then echo "   ok  $s.png"; else echo "   [!] 없음 docs/screenshots/$s.png"; missing=1; fi
done
if [ "$missing" = 1 ] && [ -n "$NONINTERACTIVE" ]; then
  echo "   (없는 캡처는 나중에 추가 후 다시 실행하면 추가 커밋됩니다)"
elif [ "$missing" = 1 ]; then
  read -r -p "스크린샷 없이 일단 push 할까요? (나중에 추가 가능) (y/N) " a
  [ "$a" = y ] || [ "$a" = Y ] || exit 1
fi

echo "== 5) 커밋 & push"
cd .. || exit 1
git add -A
git commit -m "feat: 01 개발 워크스테이션 미션 (터미널/권한/Docker/Dockerfile/포트/마운트/볼륨/Git)" || echo "   (새로 커밋할 변경 없음)"
git push origin HEAD || { echo "[!] push 실패 - 위 메시지를 캡처해서 보내 주세요"; exit 1; }

echo
git log --oneline -1
echo "완료: https://github.com/ignim-H/ia-codyssey/tree/main/01-dev-workstation"
