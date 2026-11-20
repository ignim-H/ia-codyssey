# 베이스: 공식 nginx:alpine 이미지 (방식 A - 웹 서버 베이스 + 콘텐츠/설정 교체)
FROM nginx:alpine

# [커스텀 1] 이미지 메타데이터 - docker inspect 로 이미지 출처/용도 확인 가능
LABEL org.opencontainers.image.title="codyssey-web" \
      org.opencontainers.image.description="Codyssey 개발 워크스테이션 미션용 커스텀 NGINX" \
      org.opencontainers.image.version="1.0"

# [커스텀 2] 환경 변수 - 실행 모드 표시용 (docker run -e APP_ENV=prod 로 덮어쓰기 가능)
ENV APP_ENV=dev

# [커스텀 3] 헬스체크용 curl 설치 (alpine 기본 이미지에는 없음)
RUN apk add --no-cache curl

# [커스텀 4] 기본 설정 교체 - /health 엔드포인트 추가, 서버 정보 노출 최소화
COPY nginx/default.conf /etc/nginx/conf.d/default.conf

# [커스텀 5] 정적 콘텐츠 교체
COPY site/ /usr/share/nginx/html/

# [커스텀 6] 컨테이너 상태 자동 점검 - docker ps 의 STATUS 에 (healthy) 표시
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -fsS http://localhost/health || exit 1

EXPOSE 80
