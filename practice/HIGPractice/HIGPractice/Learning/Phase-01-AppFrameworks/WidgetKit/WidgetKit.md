# WidgetKit

## 학습 소스
- site: `site/widgets/01-weather-widget-challenge.html`
- issue: #5
- branch: `practice/p1-widgetkit-review`

## Ring 1 — HIG 위젯 가이드라인
### 개념 요약
- 핵심 원칙: `Glanceable`, `Relevant`, `Personalized`
- 위젯은 "작은 앱"이 아니라 앱의 핵심 정보를 홈/잠금화면에 투영하는 컴포넌트다.
- 크기별 정보 밀도를 다르게 설계해야 한다.

### 내가 이해한 바
- 위젯은 빠른 파악이 목적이므로 텍스트를 줄이고 상태/숫자 중심으로 구성해야 한다.
- 갱신 주기는 데이터 성격에 맞춰 명확한 근거를 가져야 한다.

## Ring 2 — Widget Extension 기본 구조
### 개념 요약
- `TimelineEntry`는 `date`가 필수이며, 시스템은 이 기준으로 렌더/갱신 시점을 판단한다.
- `AppIntentTimelineProvider`는 `placeholder`, `snapshot`, `timeline`을 분리해 구현한다.
- `Timeline(entries:policy:)`로 갱신 정책을 제어한다.

### 내가 구현한 것
- `WeatherEntry(date:weather:)`
- `WeatherProvider`에서:
  - `placeholder`: `WeatherData.preview`
  - `snapshot`: `WeatherService` 비동기 조회
  - `timeline`: 15분 간격(`.after(nextUpdate)`)
- `WeatherWidget`에 `AppIntentConfiguration(intent: SelectCityIntent.self, provider: WeatherProvider())` 적용

### 검증
- [x] 위젯 갤러리 placeholder 노출 확인
- [x] snapshot/timeline 데이터 경로 정상 동작 확인
- [x] 15분 주기 timeline policy 적용 확인

### 회고
- `Provider -> Entry -> View` 흐름이 선명해서 유지보수가 쉽다.
- 갱신 정책은 provider에만 두는 것이 가장 명확하다.

## Ring 3 — HIG 준수 UI 디자인
### 개념 요약
- Small: 핵심 수치 1~2개 우선
- Medium: 현재 상태 + 시간별 요약 병행
- Large: 상세 정보 확장 가능, 과밀 금지
- iOS 17+는 `containerBackground(for: .widget)`로 배경 처리

### 내가 구현한 것
- Family별 전용 뷰:
  - `SmallWeatherView`
  - `MediumWeatherView`
  - `LargeWeatherView`
  - `CircularWeatherView`, `RectangularWeatherView`, `accessoryInline`
- 날씨 상태 기반 그라디언트 배경 적용

### 검증
- [x] `systemSmall/systemMedium/systemLarge` 레이아웃 분기 정상
- [x] `accessoryCircular/accessoryRectangular/accessoryInline` 분기 정상
- [x] 숫자 갱신 시 `numericText` 전환 적용

### 회고
- Small을 기준으로 정보 우선순위를 먼저 잡으면 Medium/Large 확장이 쉬워진다.

## Ring 4 — 데이터 & 인터랙션
### 개념 요약
- WidgetKit은 기본적으로 timeline 기반 비동기 조회 흐름이 안정적이다.
- AppIntent 기반 설정은 지원하지만, 인터랙티브 버튼은 반드시 필요한 경우만 도입한다.

### 내가 구현한 것
- `WeatherService` 기반 fetch
- `SelectCityIntent`로 도시 설정 반영
- 현재는 `Button(intent:)` 기반 인터랙티브 액션은 미적용(학습 범위에서 제외)

### 검증
- [x] 도시 변경 시 timeline 조회 파라미터 반영
- [x] 설정 intent와 provider 연결 확인

### 회고
- 현 단계에서는 "정확한 상태 표시 + 일관된 갱신 정책"이 인터랙션 추가보다 중요했다.

## Ring 5 — 설정 & 퍼스널라이즈
### 개념 요약
- `WidgetConfigurationIntent`로 사용자 선택값을 받아 개인화된 위젯을 구성한다.
- family별 같은 데이터라도 표현 밀도를 다르게 가져가야 한다.

### 내가 구현한 것
- `SelectCityIntent`, `CityOption`
- `AppIntentConfiguration`과 연결
- 부가 config intent(`AirQualityConfigIntent`, `UVIndexConfigIntent`, `WeeklyForecastConfigIntent`, `HourlyForecastConfigIntent`) 구조 정리

### 검증
- [x] 도시 옵션 선택 UI 노출 확인
- [x] 선택값 기반 데이터 표시 확인

### 회고
- 개인화의 핵심은 옵션 개수보다 "선택 결과가 즉시 의미 있게 보이는가"다.

## 현재 상태 요약
- `WidgetBundle`에 `WeatherWidget` + `DeliveryTrackerLiveActivity`를 함께 등록해 사용 중
- WeatherWidget은 WidgetKit timeline 중심
- DeliveryTracker는 ActivityKit 렌더링 중심으로 역할 분리 완료

## 최종 정리
- 오늘 배운 핵심 3가지:
  1. WidgetKit 품질은 timeline 정책과 family별 정보 밀도에서 결정된다.
  2. `placeholder/snapshot/timeline` 목적 분리가 위젯 안정성의 기본이다.
  3. ActivityKit과 병행할 때는 "WidgetKit=정기 갱신", "ActivityKit=실시간 상태"로 분리하는 것이 명확하다.
- 다음 액션:
  1. Weather timeline 주기(15분) 근거를 실제 데이터 소스 기준으로 재조정
  2. accessory family 대비/가독성 QA 추가 점검
  3. 필요 시에만 Widget 인터랙션(`Button(intent:)`)을 제한적으로 도입
