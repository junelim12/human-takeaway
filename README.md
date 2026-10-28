# Debrief

베이 지역 이벤트에 다니는 스타트업 종사자, 구직자, MBA생을 위한 LinkedIn 포스팅 도우미 데모.

녹음 툴은 기록은 남기지만 아무도 다시 열어보지 않는다는 문제에서 출발했다. Debrief는 이벤트가 끝나면 **먼저 물어본다**: "오늘 가장 기억에 남는 한 가지는?" 사용자가 한 줄로 답하면 그걸 주제로 LinkedIn 포스트 초안 3개(Story / Contrarian / Lessons)를 만든다.

## 데모 흐름

1. **You**: 이름, 현재 상황(구직 / MBA / 스타트업 재직 / 창업), 알려지고 싶은 분야, 예전 포스트(말투 참고용)
2. **Events**: 참석할 이벤트 등록 (이름, 날짜, 종료 시간, 장소, 연사)
3. **Inbox**: 종료 시간이 지나면 체크인 카드가 뜬다 → 답하기 / 내일 아침 다시 묻기 / 건너뛰기
4. **대화형 디브리프**: takeaway 한 줄 → (선택) 디테일 추가. 모르겠으면 브레인덤프 → takeaway 후보 3개 추천
5. **Drafts**: 초안 3개, "see more" 이전에 보이는 훅 미리보기, 글자 수, Shorter / More personal / More casual / Sharper hook 수정, 복사 후 LinkedIn 열기, 👍/👎, "I posted this" 기록
6. 상단 카운터: attended · debriefed · posted (핵심 지표: 초안 → 실제 포스팅 전환율)

## 파일 구조

```
src/app.html        앱 본체 (HTML/CSS/JS 한 파일). claude.ai Artifact로 그대로 퍼블리시 가능
public/index.html   내 웹사이트 배포용 (src/app.html을 완전한 HTML 문서로 감싼 버전)
api/generate.js     Vercel 서버리스 함수. Anthropic API 호출, API 키는 서버에만 보관
build.sh            src/app.html → public/index.html 생성
```

`src/app.html`은 실행 환경을 스스로 감지한다.
- claude.ai Artifact 안에서는 `window.claude.use("sample")`로 보는 사람의 Claude 계정을 통해 생성
- 그 밖(내 웹사이트)에서는 `POST /api/generate`로 서버 함수를 호출

## 내 웹사이트에 배포 (Vercel)

```bash
./build.sh                       # public/index.html 갱신
vercel                           # 또는 GitHub 저장소를 Vercel에 import
vercel env add ANTHROPIC_API_KEY # Anthropic Console에서 발급한 키
```

선택 환경변수: `ANTHROPIC_MODEL`(기본 `claude-sonnet-5-5`), `ANTHROPIC_MODEL_QUICK`(기본 `claude-haiku-5-5`).

기존 사이트에 붙일 때는 `/debrief` 같은 경로나 서브도메인으로 분리하는 걸 권장. 공개 데모라면 `api/generate.js`의 IP당 시간당 제한(기본 30회) 외에 Anthropic Console에서 월 사용량 상한도 설정해 둘 것.

## 데모의 한계 (다음 단계 후보)

- **데이터는 브라우저 localStorage에만 저장**: 로그인, 기기 간 동기화 없음
- **"먼저 묻기"는 앱을 열었을 때만 보임**: 실제 푸시는 다음 단계 (문자/이메일 + 스케줄러)
- **음성 입력**: 브라우저 음성 인식(Web Speech API)을 지원하는 곳(데스크톱 Chrome 등)에서만 마이크 버튼이 보임. claude.ai Artifact 안에서는 마이크가 막혀 있어 텍스트로만 입력
- **사용 데이터 수집 없음**: 사용성 검증용으로 투표/포스팅 이벤트를 서버에 기록하는 것은 다음 단계

## 로드맵

1. 지인 10명 사용 테스트 → 응답률(체크인에 답한 비율), 포스팅률(초안 → 실제 게시) 측정
2. 이벤트 종료 시점 문자/이메일 발송 (Twilio 또는 이메일 답장 수신)
3. Google Calendar / Luma 연동으로 이벤트 자동 등록
4. 개인 말투 학습, 히스토리, 로그인
