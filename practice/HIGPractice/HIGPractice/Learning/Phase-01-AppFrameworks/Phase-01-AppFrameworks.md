# Phase 01 - App Frameworks

## Framework Checklist

- [x] WidgetKit
- [x] ActivityKit
- [ ] App Intents
- [ ] SwiftUI
- [x] SwiftData
- [ ] Observation
- [ ] Foundation Models

---

## ActivityKit Summary (DeliveryTracker)

- Goal:
  - Live Activity lifecycle(start/update/end)와 Lock Screen/Dynamic Island UI 흐름을 학습하고, 앱/위젯 역할을 명확히 분리한다.
- Implementation Summary:
  - 앱: `DeliveryActivityDebugPanel` + `DeliveryActivityManager`에서 로컬 테스트용 시작/업데이트/종료 트리거 구성.
  - 위젯: `DeliveryTrackerLiveActivity`에서 Lock Screen/Compact/Minimal/Expanded 레이아웃 렌더링.
  - 모델: `Shared/DeliveryTracker`로 `DeliveryAttributes`, `DeliveryStatus` 공통화(앱/위젯 중복 제거).
  - 안정성: `SafeActivityManager`, `ActivityError`, `AppActivityLogger`, `ActivityMonitor`로 디버그/관찰 경로 구성.
- Blockers & Fixes:
  - `simctl push`로 Live Activity remote push 테스트 제약 확인(환경별 지원 제한).
  - 로컬 학습은 `pushType: nil` 기반 start/update/end 패널로 대체.
  - 빌드 입력 파일 오류(`.apns` unexpected input) 정리 및 불필요 payload 파일 제거.
- Notes:
  - 운영 환경에서는 서버 이벤트 + push token(`.token`) 기반 업데이트로 전환 필요.
  - 현재 패널은 학습/디버그 목적의 컨트롤 플레인이다.

---

## WidgetKit Summary (WeatherWidget)

- Goal:
  - WidgetKit 타임라인 구조와 family별 정보 밀도 설계를 학습하고, 개인화(AppIntent) 흐름을 정리한다.
- Implementation Summary:
  - `WeatherEntry` + `WeatherProvider(AppIntentTimelineProvider)` 기반 timeline 구성.
  - `AppIntentConfiguration(intent: SelectCityIntent)`로 도시 개인화 지원.
  - `systemSmall/systemMedium/systemLarge` + `accessoryCircular/accessoryRectangular/accessoryInline` 대응.
  - `containerBackground(for: .widget)`와 상태 기반 그라디언트 적용.
- Blockers & Fixes:
  - 인터랙티브 위젯 액션은 현재 범위에서 제외하고 timeline 안정성 중심으로 우선 정리.
- Notes:
  - 상세 내용은 `WidgetKit/WidgetKit.md` 문서 최신화 완료.

---

## Template (Copy Per Framework)

### {Framework}
- Goal:
- Learning Sources:
  - Site:
  - Tutorials:
  - Samples:
  - AI Reference:
- Implementation Summary:
- Blockers & Fixes:
- Issue / PR:
- Velog:
- Retrospective (3 lines):
