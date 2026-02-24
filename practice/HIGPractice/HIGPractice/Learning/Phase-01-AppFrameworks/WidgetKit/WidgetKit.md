# WidgetKit

  ## 학습 소스
  - site: `site/widgets/01-weather-widget-challenge.html`
  - issue: #5
  - branch: `practice/p1-widgetkit-core`

  ## Ring 1 — HIG 위젯 가이드라인
  ### 개념 요약
  - Glanceable(한눈에 파악) / Relevant(시의적절) / Personalized(개인화) 3원칙
  - Do: 콘텐츠 중심, 크기별 레이아웃, 다크모드/틴트, `containerBackground`
  - Don't: 정보 과다, 로딩 스피너, 앱명 반복, 과도한 갱신

  ### 내가 이해한 바
  - Apple은 위젯을 "미니 앱"이 아닌 `앱의 핵심 정보를 조 홈 화면에 투영하는 것` 이라고 정의
  - 즉, 사용자가 한눈에 정보를 파악하고 커스텀 가능하고 원하는 정보를 보여줘한다는 것!

  ## Ring 2 — Widget Extension 기본 구조
  ### 개념 요약
  - `AppIntentTimelineProvider` + `TimelineEntry` + View
  - `placeholder` / `snapshot` / `timeline` 역할 구분
  - `Timeline(policy: .after(nextUpdate))`로 갱신 시점 제어

  ### 내가 구현한 것
  - `WeatherData`, `WeatherEntry`, `WeatherProvider`
  - 15분 갱신 정책

  ### 검증
  - [ ] 위젯 갤러리 placeholder 노출 확인
  - [ ] timeline 재요청 시점 확인

  ### 회고
  - WidgetKit은 `TimelineProvider -> TimelineEntry -> View`의 `3계층 구조`로 동작한다.

  ## Ring 3 — HIG 준수 UI 디자인
  ### 개념 요약
  - family별 레이아웃 분리(`systemSmall`, `systemMedium`)
  - 조건별 그래디언트 배경

  ### 내가 구현한 것
  - `SmallWeatherView`, `MediumWeatherView`
  - `WeatherCondition.gradient`

  ### 검증
  - [ ] small/medium 레이아웃 깨짐 없음
  - [ ] 배경 대비(가독성) 확인

  ### 회고
  - (짧게)

  ## Ring 4 — 데이터 & 인터랙션
  ### 개념 요약
  - AppIntent 기반 인터랙티브 액션
  - `WidgetCenter.shared.reloadAllTimelines()`

  ### 내가 구현한 것
  - `RefreshWeatherIntent`
  - 위젯 내 새로고침 버튼

  ### 검증
  - [ ] 버튼 탭 시 타임라인 갱신 호출 확인

  ### 회고
  - (짧게)

  ## Ring 5 — 설정 & 퍼스널라이즈
  ### 개념 요약
  - `WidgetConfigurationIntent`로 사용자 설정(도시 선택)
  - family switch로 뷰 분기

  ### 내가 구현한 것
  - `SelectCityIntent`, `CityOption`
  - `AppIntentConfiguration` 적용

  ### 검증
  - [ ] 도시 변경 시 표시 데이터 변경 확인
  - [ ] 지원 family 정상 동작 확인

  ### 회고
  - (짧게)

  ## 최종 정리
  - 오늘 배운 핵심 3가지:
    1.
    2.
    3.
  - 다음 액션:
    1. Mock -> 실제 WeatherKit API 전환
    2. StandBy/Lock Screen 대응
