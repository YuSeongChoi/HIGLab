# 🍎 HIG Lab

> **Apple Human Interface Guidelines를 코드로 실습하는 곳**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Apple HIG의 **Technologies** 섹션을 기반으로, 각 기술별로 3가지를 제공합니다:

1. **📝 블로그 포스트** — HIG 가이드라인 한글 해설 + 성장고리 커리큘럼
2. **📚 DocC 튜토리얼** — Xcode에서 바로 실습 가능한 step-by-step 가이드
3. **💻 샘플 프로젝트** — 완성된 SwiftUI 코드

## 🗺️ 기술 로드맵

### Phase 1: 핵심 기술
| # | Technology | 블로그 | DocC | 샘플 | 상태 |
|---|-----------|--------|------|------|------|
| 1 | **Widgets** | [날씨 위젯 챌린지](site/widgets/) | [DocC 튜토리얼](tutorials/widgets/) | [WeatherWidget](samples/WeatherWidget/) | ✅ |
| 2 | Live Activities | 배달 추적 | DocC 준비중 | DeliveryTracker | 🔜 |
| 3 | App Shortcuts & Siri | Siri 제어 | DocC 준비중 | VoiceTaskManager | 🔜 |
| 4 | App Intents | 시스템 통합 | DocC 준비중 | SmartIntents | 🔜 |
| 5 | SharePlay | 함께 보기 | DocC 준비중 | WatchTogether | 🔜 |

### Phase 2: 결제 & 서비스
| # | Technology | 상태 |
|---|-----------|------|
| 6 | In-App Purchase | 📋 |
| 7 | Apple Pay | 📋 |
| 8 | Sign in with Apple | 📋 |
| 9 | iCloud | 📋 |

### Phase 3~4: 플랫폼 확장 & 시스템 통합
CarPlay, Game Center, HealthKit, ML, Notifications, Maps, Photos 등 20개 기술

## 📁 프로젝트 구조

```
hig-lab/
├── site/                    ← 블로그 포스트 (HTML)
│   └── widgets/
├── tutorials/               ← DocC 패키지 (기술별)
│   └── widgets/
├── samples/                 ← Xcode 샘플 프로젝트
│   └── WeatherWidget/
└── .github/workflows/       ← 자동 배포
    └── deploy.yml
```

## 🚀 온라인 보기

- **메인**: https://YOUR_USERNAME.github.io/hig-lab/
- **Widgets DocC**: https://YOUR_USERNAME.github.io/hig-lab/widgets/tutorials/table-of-contents

## 🛠️ 로컬에서 DocC 빌드

```bash
cd tutorials/widgets
swift package resolve
swift package --disable-sandbox preview-documentation --target HIGWidgets
# → http://localhost:8080/documentation/higwidgets
```

## 📄 라이선스

MIT License

---

**HIG Lab** by [개발자리](https://youtube.com/@devjari) 🚀
