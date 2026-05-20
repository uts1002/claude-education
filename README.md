# AI Fluency 학습 허브

다정초 엄태식의 개인 학습 허브. 앤트로픽 아카데미의 두 코스(*AI Fluency for Educators*, *Teaching AI Fluency Framework*)를 한국어로 정리하고, 비유·연수 자료·퀴즈와 함께 다시 짠 단일 페이지 사이트입니다.

## 빠르게 시작하기

`site/index.html`을 더블클릭하세요. 그게 끝입니다. 인터넷이 있으면 폰트·Tailwind·marked.js가 CDN에서 로드되고, 모든 강의 콘텐츠는 HTML 안에 임베드되어 있어요. 인터넷 없이도 기본 학습은 가능 (스타일·마크다운 렌더링이 약간 제약될 수 있음).

## 폴더 구조

```
claude_education/
├── AIFluency/             원본 강의 자료 (코어 코스, YouTube 자막) — 보존
├── for_educators/         원본 강의 자료 (교육자용) — 보존
├── for_teaching/          원본 강의 자료 (가르치기) — 보존
├── courses/               한글로 정리한 강의 콘텐츠
│   ├── _meta.json         코스 목록·학습 경로 (23차시)
│   ├── aiff/              AI Fluency 코어 — 프레임워크와 기초 (12차시) ⭐ 출발점
│   │   ├── _course.json
│   │   ├── 02a-why-ai-fluency.md
│   │   ├── 02a-why-ai-fluency.quiz.json
│   │   └── … (12편)
│   ├── aif4e/             교육자를 위한 AI Fluency (4차시)
│   │   ├── _course.json
│   │   └── … (4편)
│   └── taif/              AI Fluency 가르치기 (7차시)
│       └── … (7편)
├── site/
│   └── index.html         📌 실제 사이트 — 더블클릭으로 시작
├── build.py               빌더 (옵션)
└── README.md              이 파일
```

## 학습 경로 (총 23차시)

```
[AIFF 코어 12편]   →   [AIF4E 4편]   →   [TAIF 7편]
프레임워크·LLM 기초    교사 본인 적용     학생·동료 가르치기
```

코어 코스(aiff)가 모든 학습의 *출발점*입니다 — 4D 프레임워크 본격 정의와 생성형 AI 작동·능력·한계를 다룹니다. 다른 두 코스는 이걸 이수했다는 가정 위에 *적용*을 다룹니다.

## 사이트가 제공하는 것

- **차시별 한글 정리** — 한 줄 요약, 핵심 정리, 비유, 더 깊이, 출처
- **연수 자료 카드** — "한 줄 정의", "자주 받는 질문", "연수 활동 아이디어"
- **퀴즈 + 진도 추적** — 4지선다 5~6문항/차시, localStorage에 점수·완료 표시 저장
- **학습 경로 그래프** — 11개 차시의 의존 관계를 SVG로 시각화, 완료한 차시는 색이 바뀜
- **비유·연수 카드 뷰** — 차시별 비유와 연수 포인트만 모아서 보기
- **내 메모·하이라이트** — 강의별 메모 자동 저장, 모아 보기
- **전체 검색** — 강의 본문에서 키워드 검색, 스니펫 미리보기

## 새 강의 추가하기

### 방법 A — Claude에게 부탁 (가장 쉬움)

세션을 열고 "새 강의 추가해줘. 원본은 `for_teaching/새파일.txt`야."처럼 말하면, Claude가
- `.md`와 `.quiz.json`을 `courses/`에 만들고
- `_course.json`과 `_meta.json`을 갱신하고
- `site/index.html`에 임베드까지

한 번에 처리합니다. Python 안 돌려도 됩니다.

### 방법 B — 직접 추가 + `python build.py`

1. `courses/{코스}/NN-제목.md` 작성 (아래 템플릿 참고)
2. `courses/{코스}/NN-제목.quiz.json` 작성
3. `courses/{코스}/_course.json`의 `lessons` 배열에 추가
4. (선택) `courses/_meta.json`의 `learningPath.edges`에 의존 관계 추가
5. 터미널에서 `python build.py` 실행
   - **주의**: `build.py`는 `site/index.html`의 `/* COURSE_DATA_START */ … /* COURSE_DATA_END */` 영역에 단일 JSON으로 임베드하는 방식이라, 사이트가 *기대하는 형식*과 다를 수 있어요. 가장 안정적인 방법은 A입니다.

## 강의 마크다운 템플릿

```markdown
---
title: 제목
duration: "약 10분"
difficulty: 2
tags: [태그1, 태그2]
metaphor: "한 줄 비유 — 핵심 메시지를 일상 비유로"
nextSuggested: ["코스/다음차시-슬러그"]
sourceFile: "원본/파일/경로.txt"
---

## 한 줄 요약
…

## 이 강의가 답하는 질문
…

## 핵심 정리
…

## 비유로 이해하기 🪜
…

## 연수 자료 — 동료에게 설명할 때
### 한 줄 정의
> "…"

### 자주 받는 질문
…

### 연수에서 활동 아이디어
…

## 더 깊이
> 원문 인용
> ─ 한국어 의역

## 출처
…
```

## 퀴즈 JSON 템플릿

```json
{
  "title": "이해 확인 — 차시 제목",
  "passingScore": 3,
  "questions": [
    {
      "type": "mcq",
      "question": "질문",
      "options": ["보기 A", "보기 B", "보기 C", "보기 D"],
      "answer": 0,
      "explanation": "해설 — 왜 이게 답인지"
    }
  ]
}
```

- `answer`는 0부터 시작하는 인덱스
- `passingScore`는 합격 정답 수 (기본 60% 반올림)
- `explanation`은 정답·오답 모두에 표시됨

## 디자인 결정

- 색: 차분한 틸 `#0d9488` — 학습용에 적합, 길게 보기 좋음
- 폰트: Pretendard, 자간 `-0.01em`
- 톤: 토스 — 깔끔·미니멀, 큰 둥근 모서리, 그림자 최소
- 다정초 web-design 가이드 준수: 무지개 그라데이션·반짝이 이모지·글래스모피즘 금지

## 출처 및 라이선스

- 원본 강의: © 2025 Rick Dakan, Joseph Feller, Anthropic — [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/)
- 한국어 정리·사이트 구축: 다정초 엄태식 (Claude와 협업, 2026.05)
