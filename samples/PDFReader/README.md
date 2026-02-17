# PDFReader

HIG Lab 샘플 프로젝트 — **PDFKit** 활용 PDF 리더 앱

## 개요

PDFReader는 Apple의 PDFKit 프레임워크를 활용하여 PDF 문서를 읽고, 검색하고, 주석을 다는 기능을 제공하는 샘플 앱입니다.

## 주요 기능

### 📖 PDF 뷰어
- 연속 스크롤 / 단일 페이지 모드
- 확대/축소 (50% ~ 300%)
- 페이지 이동 및 네비게이션
- 드래그 앤 드롭으로 파일 열기

### 🔍 텍스트 검색
- 실시간 텍스트 검색
- 검색 결과 하이라이트
- 검색 결과 간 이동 (이전/다음)
- 컨텍스트 미리보기

### 📑 썸네일
- 페이지 썸네일 그리드
- 현재 페이지 하이라이트
- 비동기 썸네일 로딩
- 북마크 표시

### 🔖 북마크
- 페이지 북마크 추가/삭제
- 북마크 목록 보기
- 북마크 간 빠른 이동
- 북마크 영속성 (UserDefaults)

### ✏️ 주석
- **형광펜** — 텍스트 하이라이트
- **밑줄** — 텍스트 밑줄
- **취소선** — 텍스트 취소선
- **메모** — 메모 아이콘 추가
- **텍스트** — 자유 텍스트 입력
- **도형** — 원, 사각형
- 6가지 색상 선택
- 실행 취소 지원

## 프로젝트 구조

```
PDFReader/
├── Shared/                        # 공유 모듈
│   ├── PDFDocument+Extensions.swift   # PDFDocument 확장
│   ├── Bookmark.swift                  # 북마크 모델 및 관리자
│   └── AnnotationManager.swift         # 주석 관리자
│
├── PDFReaderApp/                  # 앱 모듈
│   ├── PDFReaderApp.swift             # @main 앱 진입점
│   ├── ContentView.swift              # 메인 콘텐츠 (파일 선택)
│   ├── PDFViewerView.swift            # PDF 뷰어
│   ├── ThumbnailView.swift            # 썸네일 그리드
│   ├── SearchView.swift               # 검색 기능
│   └── AnnotationView.swift           # 주석 도구
│
└── README.md
```

## 주요 클래스 및 구조체

### Shared

| 파일 | 설명 |
|------|------|
| `PDFDocument+Extensions` | 문서 정보, 페이지 관리, 검색, 썸네일 유틸리티 |
| `Bookmark` | 북마크 모델 및 `BookmarkManager` (CRUD, 영속성) |
| `AnnotationManager` | 주석 생성/삭제/수정, 실행 취소 스택 |

### PDFReaderApp

| 파일 | 설명 |
|------|------|
| `PDFReaderApp` | 앱 진입점, 윈도우 설정, 메뉴 커맨드 (macOS) |
| `ContentView` | 파일 선택 UI, 드래그 앤 드롭, 최근 파일 |
| `PDFViewerView` | 메인 PDF 뷰어, 네비게이션, PDFView 래퍼 |
| `ThumbnailView` | 페이지 썸네일 그리드, 비동기 로딩 |
| `SearchView` | 텍스트 검색, 결과 목록, 하이라이트 |
| `AnnotationView` | 주석 도구 바, 색상 선택, 주석 목록 |

## 기술 스택

- **SwiftUI** — UI 프레임워크
- **PDFKit** — PDF 렌더링 및 조작
- **Combine** — 반응형 프로그래밍
- **UniformTypeIdentifiers** — 파일 타입 처리

## 플랫폼 지원

- ✅ iOS 17.0+
- ✅ macOS 14.0+
- ✅ iPadOS 17.0+

## 사용 방법

### 파일 열기
1. 앱 실행 후 "PDF 파일 선택" 버튼 클릭
2. 또는 PDF 파일을 드롭 영역에 드래그 앤 드롭
3. 최근 파일 목록에서 선택

### 페이지 이동
- 하단 화살표 버튼으로 이전/다음 페이지
- 페이지 번호 클릭하여 직접 이동
- 썸네일에서 페이지 선택

### 검색
1. 툴바의 검색 버튼 클릭 (또는 ⌘F)
2. 검색어 입력
3. 결과 목록에서 항목 선택
4. 화살표로 결과 간 이동

### 북마크
1. 툴바의 북마크 버튼 클릭 (또는 ⌘D)
2. 사이드바의 "북마크" 탭에서 목록 확인
3. ⌥⌘] / ⌥⌘[ 로 북마크 간 이동

### 주석
1. 툴바의 주석 버튼 클릭
2. 도구 선택 (형광펜, 밑줄 등)
3. 색상 선택
4. 텍스트 선택하여 주석 적용

## 키보드 단축키 (macOS)

| 단축키 | 기능 |
|--------|------|
| ⌘O | 파일 열기 |
| ⌘F | 검색 |
| ⌘D | 북마크 토글 |
| ⌥⌘T | 썸네일 패널 토글 |
| ⌥⌘] | 다음 북마크 |
| ⌥⌘[ | 이전 북마크 |
| ⌘Z | 실행 취소 |

## 확장 포인트

### 추가 주석 타입
`AnnotationType` enum에 새 케이스 추가 후 `AnnotationManager`에 생성 메서드 구현

### 문서 아웃라인
`PDFDocument.outlineRoot`를 활용한 목차 네비게이션 추가 가능

### 클라우드 동기화
`BookmarkManager`의 저장 로직을 CloudKit이나 iCloud로 확장 가능

### 문서 수정
`PDFDocument.write(to:)`를 활용하여 주석이 포함된 PDF 저장 가능

## 참고 자료

- [PDFKit Documentation](https://developer.apple.com/documentation/pdfkit)
- [Human Interface Guidelines - Document Apps](https://developer.apple.com/design/human-interface-guidelines/document-apps)

---

© 2024 HIG Lab
