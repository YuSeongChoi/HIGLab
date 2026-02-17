# 🤖 AI Reference

> **AI 코드 생성을 위한 참조 문서**
> 
> 이 폴더의 문서들은 Claude, GPT 등 AI가 iOS/SwiftUI 코드를 정확하게 생성할 수 있도록 설계되었습니다.

## 📚 문서 목록

### App Frameworks (Phase 1)
| 문서 | 설명 | 주요 키워드 |
|------|------|------------|
| [widgets.md](widgets.md) | WidgetKit 위젯 구현 | Timeline, Provider, Widget Family |
| [activitykit.md](activitykit.md) | Live Activity, Dynamic Island | ActivityAttributes, ContentState |
| [swiftui-observation.md](swiftui-observation.md) | @Observable 상태 관리 | @Observable, @Bindable, @Environment |
| [swiftdata.md](swiftdata.md) | SwiftData CRUD | @Model, @Query, ModelContainer |
| [foundation-models.md](foundation-models.md) | 온디바이스 AI | LanguageModelSession, Tool |

### App Services (Phase 2)
| 문서 | 설명 | 주요 키워드 |
|------|------|------------|
| [storekit.md](storekit.md) | 인앱결제, 구독 | Product, Transaction, purchase() |

### System & Network (Phase 4)
| 문서 | 설명 | 주요 키워드 |
|------|------|------------|
| [core-bluetooth.md](core-bluetooth.md) | BLE 기기 연결 | CBCentralManager, CBPeripheral |

## 🎯 사용 방법

### 1. AI에게 문서 제공

```
이 문서를 참고해서 날씨 위젯을 만들어줘:

[widgets.md 내용 붙여넣기]
```

### 2. 프로젝트 컨텍스트로 사용

AI 도구(Claude, Cursor, GitHub Copilot 등)의 컨텍스트에 이 폴더를 포함시키면,
정확한 iOS 코드 생성이 가능합니다.

### 3. 조합 사용

```
widgets.md + swiftdata.md 참고해서
SwiftData로 저장되는 할일을 표시하는 위젯 만들어줘
```

## 📝 문서 구조

각 문서는 다음 구조를 따릅니다:

1. **개요**: 프레임워크 설명 (1-2문장)
2. **필수 Import**: 필요한 import 문
3. **핵심 구성요소**: 주요 타입/프로토콜 설명
4. **전체 작동 예제**: 복사해서 바로 실행 가능한 코드
5. **고급 패턴**: 추가 사용 사례
6. **주의사항**: 흔한 실수와 해결법

## ✅ 코드 품질

모든 예제 코드는:
- ✅ Swift 5.9+ / iOS 17+ 기준
- ✅ 컴파일 가능한 전체 코드
- ✅ SwiftUI 최신 패턴 (@Observable 등)
- ✅ #Preview 매크로 포함
- ✅ 한글 주석

## 🔗 관련 자료

- [📝 블로그](https://m1zz.github.io/HIGLab/) - 상세 설명
- [📚 DocC 튜토리얼](../tutorials/) - 단계별 학습
- [💻 샘플 프로젝트](../samples/) - 실전 코드

---

Made for AI, by [개발자리](https://youtube.com/@devjari)
