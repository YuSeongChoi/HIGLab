# WidgetKit

  ## 학습 소스
  - site: `site/widgets/01-weather-widget-challenge.html`
  - issue: #5
  - branch: `practice/p1-widgetkit-review`

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
  - `TimelineEntry`를 채택한 Entry는 `date`를 반드시 포함하며, 시스템은 이 시점을 기준으로 렌더링/갱신을 판단한다.
  - `AppIntentTimelineProvider`는 `placeholder` / `snapshot` / `timeline`을 구현한다.
  - `timeline`에서 `Timeline(entries:policy:)`로 갱신 정책(`.after`, `.atEnd`, `.never`)을 제어한다.
  - Provider 구현 시 `async/await`로 비동기 데이터 fetch를 자연스럽게 연결할 수 있다.

  ### 내가 구현한 것
  - `WeatherEntry(date:weather:)` 형태의 Entry 구성
  - `placeholder`: 위젯 갤러리용 실데이터 형태 미리보기
  - `snapshot`: 위젯 추가/편집 시점의 단일 스냅샷
  - `timeline`: 15분 기준 next update 설정

  ### 검증
  - [x] 위젯 갤러리 placeholder 노출 확인
  - [x] timeline 재요청 시점 확인

  ### 회고
  - WidgetKit은 `Provider -> Entry -> View`의 흐름이 명확하고, 갱신 정책은 `timeline`에서만 제어된다.

  ## Ring 3 — HIG 준수 UI 디자인
  ### 개념 요약
  - small 위젯(예: 약 169x169pt)은 핵심 정보 1-2개를 즉시 읽히게 구성한다.
  - medium(예: 약 360x169pt)은 가로 확장을 활용해 요약+보조정보를 함께 보여준다.
  - large(예: 약 360x376pt)은 상세 정보까지 포함 가능하지만 정보 과밀은 피해야 한다.
  - iOS 17+에서는 `containerBackground(for: .widget)`로 상황별 배경을 구성할 수 있다.

  ### 내가 구현한 것
  - family별 레이아웃 분기
  - 날씨 상태 기반 그라디언트 배경(`WeatherCondition.gradient`)

  ### 검증
  - [x] small/medium/large 레이아웃 깨짐 없음
  - [x] 배경 대비(가독성) 확인

  ### 회고
  - small은 요약, medium/large는 확장 정보라는 기준이 있어야 레이아웃 우선순위가 흔들리지 않는다.

  ## Ring 4 — 데이터 & 인터랙션
  ### 개념 요약
  - iOS 17+에서 `Button(intent:)`를 사용하면 앱을 열지 않고 위젯에서 액션을 직접 수행할 수 있다.
  - 인터랙션 이후 `WidgetCenter.shared.reloadAllTimelines()`로 반영 타이밍을 제어한다.
  - 잠금화면 위젯은 시스템이 색을 제어하므로 대비 중심으로 표현해야 한다.

  ### 내가 구현한 것
  - `RefreshWeatherIntent`
  - 위젯 내 새로고침 버튼

  ### 검증
  - [x] 버튼 탭 시 타임라인 갱신 호출 확인

  ### 회고
  - 인터랙션은 가능한 단순하게 유지하고, 결과 반영은 timeline 갱신으로 연결하는 패턴이 안전하다.

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
    1. Entry는 `TimelineEntry` + `date`가 핵심이며 시스템 갱신 판단의 기준점이다.
    2. `placeholder/snapshot/timeline`의 목적을 분리해야 위젯 품질과 사용자 경험이 안정된다.
    3. family별 정보 밀도와 iOS 17+ 인터랙티브/배경 처리 전략이 WidgetKit 설계의 핵심이다.
  - 다음 액션:
    1. timeline policy를 데이터 성격에 맞춰 재검토(15/30분 근거 명시)
    2. 잠금화면 family 대비 중심 스타일 추가 점검
    3. Mock -> 실제 WeatherKit API 전환 실험
