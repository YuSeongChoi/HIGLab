# 💻 HIG Lab 샘플 프로젝트

각 기술별 완성된 Xcode 프로젝트입니다.

## WeatherWidget

나만의 날씨 위젯 — 6가지 크기 지원, 인터랙티브 버튼, 도시 선택 Configuration.

### 사용법

1. Xcode 15+ 에서 새 iOS App 프로젝트 생성
2. Widget Extension 타겟 추가 (Include Configuration App Intent 체크)
3. 이 폴더의 Swift 파일을 해당 타겟에 추가
4. `Shared/` 파일은 앱 타겟과 위젯 타겟 모두에 추가

### 파일 구조

```
WeatherWidget/
├── Shared/                          ← 앱 + 위젯 공통
│   ├── WeatherData.swift            ← 데이터 모델 + Mock
│   ├── WeatherGradient.swift        ← 조건별 그래디언트
│   └── WeatherService.swift         ← 날씨 서비스
│
├── WeatherWidgetApp/                ← 메인 앱 타겟
│   └── WeatherWidgetApp.swift
│
└── WeatherWidgetExtension/          ← 위젯 익스텐션 타겟
    ├── WeatherWidget.swift          ← Provider + Widget 정의
    ├── WeatherWidgetViews.swift     ← 6가지 크기별 뷰
    ├── SelectCityIntent.swift       ← 도시 선택 설정
    └── RefreshWeatherIntent.swift   ← 새로고침 인터랙션
```

### 요구 사항

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
