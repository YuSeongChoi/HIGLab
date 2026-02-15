# HIGLab 블로그 문제 진단

## 문제 분석
- [x] DocC 빌드 확인
- [x] GitHub Pages 링크 구조 확인
- [x] index.html의 링크 경로 검증
- [x] 로컬 프리뷰 테스트

## 발견된 이슈
1. **파일 충돌 문제** (주요 원인)
   - `site/widgets/` 폴더에 블로그 포스트 HTML 존재
   - GitHub Actions에서 `site/*` 복사 후 DocC를 `deploy/widgets/`로 출력
   - 결과: DocC가 블로그 파일을 덮어씀

2. **링크 구조 문제**
   - 블로그와 DocC 링크가 명확하게 분리되지 않음

## 해결 완료
- [x] 워크플로우 수정: 블로그 포스트를 `deploy/blog/`로 복사
- [x] index.html 수정: 블로그 링크를 `blog/widgets/`로 변경
- [x] DocC 튜토리얼 링크를 명시적으로 분리
- [x] HTML 중첩 <a> 태그 오류 수정: 카드를 <div>로 변경
- [x] DocC 리소스 파일 누락 문제 해결: 7개의 Swift 코드 예제 파일 추가
  - 01-glanceable.swift (Glanceable 원칙)
  - 01-relevant.swift (Relevant 원칙)
  - 01-personalized.swift (Personalized 원칙)
  - 01-size-small.swift (Small 위젯)
  - 01-size-medium.swift (Medium 위젯)
  - 01-size-large.swift (Large 위젯)
  - 01-size-lockscreen.swift (Lock Screen 위젯)
