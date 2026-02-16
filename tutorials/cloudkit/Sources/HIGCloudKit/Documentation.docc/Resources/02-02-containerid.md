# CloudKit 컨테이너 ID

## 명명 규칙
- 형식: `iCloud.{bundle-identifier}`
- 예시: `iCloud.com.example.SharedNotes`

## 컨테이너 생성
1. Signing & Capabilities에서 CloudKit 활성화
2. "+" 버튼으로 새 컨테이너 추가
3. 컨테이너 ID 입력

## 여러 앱에서 컨테이너 공유
- 같은 컨테이너 ID를 사용하면 데이터 공유 가능
- 예: iOS 앱과 macOS 앱이 동일 컨테이너 사용

## 주의사항
- 컨테이너 ID는 한번 생성하면 삭제 불가
- Development/Production 환경 별도 관리
