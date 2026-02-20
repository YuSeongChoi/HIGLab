# 🚀 시작하기 (주니어 개발자용)

> iOS 개발을 시작하는 분들을 위한 친절한 가이드

---

## 👋 환영해요!

HIGLab은 Apple의 50개 핵심 프레임워크를 실전 코드로 배우는 프로젝트예요.  
이 문서는 **어디서부터 시작해야 할지 모르는 분들**을 위해 작성했어요.

---

## 📁 이 프로젝트 구조 이해하기

```
HIGLab/
│
├── 📝 site/              ← 블로그 (개념 설명 + 코드 예시)
│   └── widgets/          ← 예: WidgetKit 블로그 글
│
├── 📚 tutorials/         ← DocC 튜토리얼 (단계별 실습)
│   └── widgets/          ← 예: WidgetKit 튜토리얼 패키지
│
├── 💻 samples/           ← 샘플 프로젝트 (완성된 앱)
│   └── WeatherWidget/    ← 예: 날씨 위젯 앱
│       └── README.md     ← 이 앱이 뭔지 설명
│
├── 🤖 ai-reference/      ← AI 코드 생성용 참조 문서
│   └── HOW-TO-USE.md     ← AI 활용법
│
└── 📄 README.md          ← 프로젝트 전체 소개
```

### 폴더별 역할

| 폴더 | 뭐하는 곳? | 언제 봐요? |
|------|----------|----------|
| `site/` | 개념 설명 + 코드 해설 | 🌱 처음 배울 때 |
| `tutorials/` | 단계별 따라하기 | 📖 직접 실습할 때 |
| `samples/` | 완성된 앱 코드 | 💼 실전 코드 참고할 때 |
| `ai-reference/` | AI 프롬프트용 | 🤖 AI로 코드 생성할 때 |

---

## 🎯 레벨별 추천 시작점

### 🌱 완전 초보 (Swift 막 배움)

**1단계: SwiftUI 기초**
```bash
# 블로그 먼저 읽기
open https://m1zz.github.io/HIGLab/swiftui/01-tutorial.html

# 샘플 코드 보기
cd samples/TaskMaster
cat README.md
```

**추천 샘플**: `TaskMaster` (할일 앱)
- SwiftUI 기본 문법
- @State, @Binding
- List, NavigationStack

---

### 🌿 기초 있음 (SwiftUI 좀 해봄)

**1단계: 데이터 저장**
```bash
# SwiftData 블로그
open https://m1zz.github.io/HIGLab/swiftdata/01-tutorial.html

# 샘플 코드
cd samples/TaskMaster
```

**2단계: 상태 관리**
```bash
# @Observable 패턴
open https://m1zz.github.io/HIGLab/observation/01-tutorial.html
```

**추천 샘플**: `CloudNotes`, `ContactBook`

---

### 🌳 중급 (앱 몇 개 만들어봄)

**추천 기술들**:
1. `WidgetKit` - 위젯 만들기 → `WeatherWidget`
2. `ActivityKit` - Live Activity → `DeliveryTracker`
3. `StoreKit` - 인앱결제 → `SubscriptionApp`

```bash
# 위젯 도전!
cd samples/WeatherWidget
cat README.md
```

---

### 🌲 고급 (실무 경험 있음)

**도전해볼 기술들**:
- `Foundation Models` - 온디바이스 AI → `AIChatbot`
- `ARKit` + `RealityKit` → `ARFurniture`
- `Core Bluetooth` → `BLEScanner`

---

## 📖 학습 순서 추천

### 코스 A: 앱 개발 기초 (2주)

```
1일차: SwiftUI 기초        → site/swiftui/
2일차: 상태 관리           → site/observation/
3일차: 데이터 저장         → site/swiftdata/
4일차: 샘플 분석           → samples/TaskMaster/
5일차: 직접 만들어보기
```

### 코스 B: 위젯 마스터 (1주)

```
1일차: WidgetKit 개념      → site/widgets/
2일차: 샘플 분석           → samples/WeatherWidget/
3일차: DocC 튜토리얼       → tutorials/widgets/
4일차: 나만의 위젯 만들기
```

### 코스 C: 실전 기능 (2주)

```
1주차: 위젯 + Live Activity
2주차: 인앱결제 + CloudKit
```

---

## ❓ 자주 묻는 질문

### Q: 코드가 너무 어려워요
**A:** `samples/TaskMaster`부터 시작하세요. 가장 기본적인 패턴이에요.

### Q: 어떤 샘플부터 봐야 해요?
**A:** 
- 초보: `TaskMaster` (할일 앱)
- 중급: `WeatherWidget` (위젯)
- 고급: `AIChatbot` (AI)

### Q: 실행이 안 돼요
**A:** 
1. Xcode 15+ 확인
2. iOS 17+ 시뮬레이터 선택
3. 샘플 폴더의 README.md 확인

### Q: 이해가 안 되는 코드가 있어요
**A:** 
1. 해당 기술의 블로그 글 읽기 (`site/기술명/`)
2. DocC 튜토리얼 따라하기 (`tutorials/기술명/`)
3. AI Reference로 AI에게 물어보기 (`ai-reference/`)

---

## 🛠 개발 환경 설정

### 필수 요구사항
- **macOS**: Sonoma 14.0+
- **Xcode**: 15.0+
- **iOS**: 17.0+ (시뮬레이터)

### 프로젝트 열기

```bash
# 저장소 클론
git clone https://github.com/M1zz/HIGLab.git
cd HIGLab

# 샘플 프로젝트 확인
ls samples/

# 원하는 샘플 열기
cd samples/TaskMaster
open .  # Finder에서 열기
```

### Xcode에서 실행

1. `samples/프로젝트명/` 폴더 열기
2. Swift 파일들을 새 Xcode 프로젝트에 추가
3. `Cmd + R`로 실행

---

## 🔗 도움되는 링크

- 📺 [개발자리 유튜브](https://youtube.com/@leeo25) - 영상 강의
- 🌐 [HIGLab 사이트](https://m1zz.github.io/HIGLab/) - 블로그
- 📚 [Apple HIG](https://developer.apple.com/design/human-interface-guidelines/) - 공식 가이드
- 📖 [Swift 문서](https://docs.swift.org/swift-book/) - 언어 레퍼런스

---

## 💪 화이팅!

iOS 개발은 처음엔 어려워 보이지만, 하나씩 배우다 보면 어느새 앱을 만들고 있을 거예요.

**작은 것부터 시작하세요:**
1. `TaskMaster` 코드 읽기
2. 한 줄씩 이해하기
3. 조금씩 수정해보기
4. 나만의 앱 만들기!

질문이 있으면 [GitHub Issues](https://github.com/M1zz/HIGLab/issues)에 남겨주세요 😊

---

Made with ❤️ for Junior iOS Developers
