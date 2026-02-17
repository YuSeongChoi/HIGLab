# 🤖 AI Reference 사용 가이드

> AI에게 iOS 코드 생성을 요청할 때 이 문서들을 활용하는 방법

---

## 🎯 이 문서가 필요한 이유

AI(Claude, GPT 등)에게 "위젯 만들어줘"라고 하면:

❌ **문서 없이**: 오래된 API 사용, 불완전한 코드, 컴파일 안 됨
✅ **문서 있으면**: 최신 API, 전체 작동 코드, 바로 실행 가능

---

## 📖 사용 방법

### 방법 1: 직접 붙여넣기 (가장 간단)

1. 원하는 문서 열기 (예: `widgets.md`)
2. 전체 내용 복사
3. AI 채팅에 붙여넣고 요청

```
이 문서를 참고해서 할일을 표시하는 위젯을 만들어줘:

[widgets.md 전체 내용 붙여넣기]
```

### 방법 2: GitHub Raw URL 사용

AI에게 URL을 제공:

```
이 문서를 읽고 날씨 위젯을 만들어줘:
https://raw.githubusercontent.com/M1zz/HIGLab/main/ai-reference/widgets.md
```

### 방법 3: Cursor / VS Code에서 사용

1. `ai-reference/` 폴더를 프로젝트에 추가
2. Cursor에서 `@ai-reference/widgets.md` 태그로 참조
3. 또는 `.cursorrules` 파일에 포함

```
# .cursorrules
@ai-reference/widgets.md 를 참고해서 iOS 위젯을 구현합니다.
```

### 방법 4: Claude Projects에 추가

1. Claude.ai > Projects
2. 새 프로젝트 생성
3. Knowledge에 `.md` 파일들 업로드
4. 프로젝트 내에서 자동 참조됨

### 방법 5: GitHub Copilot 컨텍스트

```swift
// @see ai-reference/swiftdata.md
// SwiftData를 사용한 할일 앱을 만들어줘
```

---

## 💬 프롬프트 예시

### 기본 요청

```
widgets.md를 참고해서 주식 시세를 표시하는 위젯을 만들어줘.
- Small, Medium 크기 지원
- 15분마다 갱신
- 상승/하락 색상 구분
```

### 여러 문서 조합

```
swiftdata.md + widgets.md를 참고해서
SwiftData에 저장된 할일 목록을 위젯에 표시하는 코드를 만들어줘.
```

### 수정 요청

```
방금 만든 위젯에 activitykit.md를 참고해서
Live Activity 기능을 추가해줘.
```

### 특정 부분만 요청

```
widgets.md의 "인터랙티브 위젯" 섹션을 참고해서
버튼을 누르면 카운터가 증가하는 위젯을 만들어줘.
```

---

## 📁 문서별 사용 시나리오

| 문서 | 이럴 때 사용 |
|------|------------|
| `widgets.md` | "위젯 만들어줘", "홈화면에 표시", "잠금화면 위젯" |
| `activitykit.md` | "Live Activity", "Dynamic Island", "배달 추적" |
| `swiftdata.md` | "데이터 저장", "CRUD", "@Model", "로컬 DB" |
| `swiftui-observation.md` | "@Observable", "상태 관리", "MVVM" |
| `foundation-models.md` | "AI 챗봇", "온디바이스 AI", "LLM" |
| `storekit.md` | "인앱결제", "구독", "프리미엄", "결제" |
| `core-bluetooth.md` | "블루투스", "BLE", "기기 연결", "IoT" |

---

## ✅ 좋은 프롬프트 작성법

### DO ✅

```
widgets.md를 참고해서 만들어줘:

1. 목표: 오늘의 운동 목표 달성률을 보여주는 위젯
2. 크기: Small, Medium
3. 데이터: HealthKit에서 걸음수 가져오기
4. 갱신: 30분마다
5. 디자인: 원형 프로그레스 바
```

### DON'T ❌

```
위젯 만들어줘
```

→ 구체적인 요구사항 + 참조 문서가 있어야 정확한 코드 생성 가능

---

## 🔧 문제 해결

### "코드가 컴파일 안 돼요"

1. 문서 전체를 제공했는지 확인
2. iOS/Xcode 버전 명시: "iOS 17+, Xcode 15에서 작동하게 해줘"
3. 에러 메시지와 함께 수정 요청

### "오래된 API를 사용해요"

```
iOS 17+ 최신 API만 사용해줘.
ObservableObject 대신 @Observable 사용.
```

### "일부 기능만 필요해요"

```
widgets.md의 "전체 작동 예제" 섹션만 참고해서
최소한의 코드로 만들어줘.
```

---

## 🎓 실전 예제

### 예제 1: 날씨 + 위젯

**프롬프트:**
```
widgets.md를 참고해서 날씨 위젯을 만들어줘.

요구사항:
- WeatherKit 대신 하드코딩된 데이터 사용 (테스트용)
- Small: 온도 + 아이콘
- Medium: 온도 + 3시간 예보
- 배경: 날씨에 따라 그라디언트 변경
```

### 예제 2: 할일 앱 전체

**프롬프트:**
```
swiftdata.md + swiftui-observation.md를 참고해서
할일 관리 앱을 만들어줘.

기능:
- 할일 추가/삭제/완료
- 카테고리 분류
- 마감일 설정
- 오늘 할일 필터
```

### 예제 3: 구독 + 결제

**프롬프트:**
```
storekit.md를 참고해서 프리미엄 구독 화면을 만들어줘.

요구사항:
- 월간/연간 구독 옵션
- 7일 무료 체험
- 구매 복원 버튼
- 구독 시 광고 제거
```

---

## 📚 추가 학습

AI Reference로 기본 코드를 생성한 후:

1. **📝 블로그**: 개념 이해 → [m1zz.github.io/HIGLab](https://m1zz.github.io/HIGLab/)
2. **📚 DocC**: 단계별 학습 → `tutorials/` 폴더
3. **💻 샘플**: 실전 코드 → `samples/` 폴더

---

## 💡 팁

1. **문서 최신 상태 유지**: `git pull`로 최신 버전 받기
2. **조합 활용**: 여러 문서를 함께 제공하면 복합 기능 구현 가능
3. **점진적 요청**: 한번에 모든 걸 요청하지 말고 단계별로
4. **피드백 루프**: 생성된 코드 실행 → 에러 수정 요청 → 반복

---

Made with ❤️ for AI-assisted iOS Development
