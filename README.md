# Debrief

녹음(또는 녹취록)과 **나에게 남은 한 줄**만 있으면 X 스레드와 LinkedIn 포스트를 만들어 주는 데모.

## 흐름

1. **업로드**: 오디오(.m4a, .mp3, .wav) 또는 녹취록(.txt, .srt, .vtt). 붙여넣기도 가능
2. **목적 선택**: 구직자 / 마케터 / 창업자. 사실은 그대로, 글의 각도만 바뀐다
3. **한 줄 입력**: 친구에게 다시 말해줄 문장 하나 (최대 140자). 모든 글이 이 문장을 중심으로 쓰인다
4. **결과**: X / LinkedIn 탭
   - X: 3~5개 포스트 스레드, 포스트별 280자 카운터, 첫 포스트가 채워진 채로 X 작성창 열기
   - LinkedIn: "see more" 전에 보이는 훅 미리보기, 글자 수
   - 공통: Shorter / Sharper opening / More personal / More casual 다듬기, 복사, 다시 쓰기

디자인: 흑백 모노톤, 큰 스테이지 패널 + 오른쪽 카드 열 (녹음 앱 레퍼런스 기반). 라이트/다크 모두 지원.

## 파일 구조

```
src/app.html         앱 본체 (HTML/CSS/JS 한 파일). claude.ai Artifact로 그대로 퍼블리시 가능
public/index.html    웹사이트 배포용 (build.sh가 src/app.html을 완전한 HTML 문서로 감쌈)
api/generate.js      글 생성: Anthropic API 호출 (ANTHROPIC_API_KEY)
api/transcribe.js    음성 → 텍스트: OpenAI Whisper API 호출 (OPENAI_API_KEY)
build.sh             public/index.html 생성
```

앱은 실행 환경을 스스로 감지한다.
- claude.ai Artifact 안: 보는 사람의 Claude 계정으로 글 생성. 오디오는 파형/길이만 표시하고, 전사는 지원하지 않으므로 녹취록 업로드를 안내
- 내 웹사이트: `/api/generate`, `/api/transcribe` 서버 함수 사용

## 내 웹사이트에 배포 (Vercel)

```bash
./build.sh
vercel                             # 또는 GitHub 저장소를 Vercel에서 Import
vercel env add ANTHROPIC_API_KEY
vercel env add OPENAI_API_KEY      # 오디오 전사를 쓸 경우
```

선택 환경변수: `ANTHROPIC_MODEL`(기본 `claude-sonnet-5-5`), `STT_MODEL`(기본 `whisper-1`).

주의: Vercel 서버 함수는 요청 본문이 약 4.5MB로 제한된다. 긴 녹음은 스토리지(Vercel Blob, S3)에 먼저 올리고 URL로 전사하는 방식으로 바꿔야 한다. 공개 데모라면 Anthropic/OpenAI 콘솔에서 월 사용량 상한을 꼭 설정할 것.

## 데모의 한계

- 데이터는 브라우저 localStorage에만 저장 (로그인 없음)
- 사용 로그 수집 없음: 사용성 검증을 위해 "복사/열기" 클릭, 다듬기 버튼 사용, 재생성 횟수를 서버에 기록하는 것이 다음 단계

## 다음 단계

1. 지인 10명 테스트: 업로드 → 결과까지 완주율, 결과 → 복사/열기 전환율, 가장 많이 누른 다듬기 버튼
2. 사용 이벤트 로깅
3. 이벤트 종료 후 먼저 묻는 체크인(문자/이메일) 기능 재도입
4. 개인 말투 학습
