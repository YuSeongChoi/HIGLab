# 🔍 HIG Lab 아키텍처 리뷰

> 10년차 Apple 프레임워크 개발자 관점

## 🚨 현재 문제점

### 1. 코드 중복 & 버전 불일치

**Sample 코드 (samples/WeatherWidget/)**
```swift
// iOS 17+ 최신 API
struct WeatherProvider: AppIntentTimelineProvider {
    func timeline(for configuration: SelectCityIntent, ...) async -> Timeline<WeatherEntry>
}

struct WeatherWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectCityIntent.self, provider: WeatherProvider())
    }
}
```

**DocC 코드 (tutorials/widgets/.../Resources/)**
```swift
// Legacy API (iOS 14-16)
struct WeatherProvider: TimelineProvider {
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> Void)
}

struct WeatherWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider())
    }
}
```

❌ **문제**: 사용자가 DocC 튜토리얼 따라하면 Sample과 다른 코드를 배움

### 2. Single Source of Truth 부재

```
현재 구조:
├── samples/WeatherWidget/*.swift     ← 코드 버전 A
├── tutorials/.../Resources/*.swift   ← 코드 버전 B (복사본)
└── site/widgets/*.html               ← 코드 버전 C (하드코딩)
```

- 샘플 수정 → DocC 수동 업데이트 필요
- DocC 수정 → Blog 수동 업데이트 필요
- **유지보수 악몽**

### 3. 학습 경험 단절

사용자 입장:
1. Blog 읽음 → 코드 A 학습
2. DocC 따라함 → 코드 B 학습 (다름!)
3. Sample 다운로드 → 코드 C 발견 (또 다름!)

😵 혼란

---

## ✅ 권장 아키텍처

### 원칙: Sample이 Source of Truth

```
HIGLab/
├── samples/                          # ← 🎯 Single Source of Truth
│   └── WeatherWidget/
│       ├── WeatherWidget.xcodeproj   # 실제 빌드 가능
│       ├── WeatherWidgetApp/
│       ├── WeatherWidgetExtension/
│       ├── Shared/
│       └── README.md                 # 사용법
│
├── tutorials/
│   └── widgets/
│       └── Documentation.docc/
│           ├── Tutorials/*.tutorial
│           └── Resources/            # ← samples/ 코드 참조 or 복사
│
└── site/
    └── widgets/
        └── *.html                    # ← samples/ 코드 인용
```

### 구현 전략

#### Option A: 심볼릭 링크 (권장)
```bash
cd tutorials/widgets/Sources/HIGWidgets/Documentation.docc/
ln -s ../../../../../samples/WeatherWidget/Snippets Resources
```

#### Option B: 빌드 스크립트
```bash
# build-docs.sh
cp -r samples/WeatherWidget/Snippets/* tutorials/widgets/.../Resources/
```

#### Option C: 코드 추출 도구
```swift
// extract-snippets.swift
// Sample에서 // MARK: SNIPPET-START ~ SNIPPET-END 구간 추출
```

---

## 🛠️ 즉시 수정 필요 항목

### Priority 1: WidgetKit (기준 샘플)

1. ✅ `samples/WeatherWidget/` - 이미 완성 (iOS 17+ API)
2. ❌ `tutorials/widgets/.../Resources/` - Sample과 동기화 필요
3. ❌ `site/widgets/` - Sample 코드로 업데이트 필요

### Priority 2: 나머지 50개 프레임워크

- 각 Sample 프로젝트가 **실제 빌드 가능**해야 함
- DocC/Blog는 Sample 코드를 **인용**해야 함

---

## 📋 체크리스트

### Sample 프로젝트 품질 기준

- [ ] Xcode에서 빌드 & 실행 가능
- [ ] iOS 17+ 최신 API 사용
- [ ] HIG 가이드라인 주석 포함
- [ ] Preview 지원
- [ ] README.md 포함

### DocC 튜토리얼 품질 기준

- [ ] Sample 코드와 100% 일치
- [ ] @Code 참조가 실제 파일을 가리킴
- [ ] @Assessments 퀴즈 포함
- [ ] 10챕터 완성

### Blog 품질 기준

- [ ] Sample 코드 직접 인용
- [ ] HIG 원칙 설명
- [ ] 실습 가능한 단계

---

## 🎯 액션 플랜

### Phase 1: WidgetKit 파일럿 (1시간)
1. DocC Resources를 Sample 코드로 교체
2. Blog 코드 블록 업데이트
3. 검증: 모든 곳에서 동일한 코드

### Phase 2: 빌드 자동화 (30분)
1. `scripts/sync-snippets.sh` 생성
2. GitHub Actions에 추가

### Phase 3: 나머지 프레임워크 (점진적)
1. Sample 완성 → DocC 동기화 → Blog 동기화

---

*작성: 2026-02-17*
