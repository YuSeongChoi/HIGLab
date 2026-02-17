# Xcode Scheme에서 StoreKit Configuration 연결

## 1. Scheme 편집 열기
- Product → Scheme → Edit Scheme... (⌘<)

## 2. Run 설정에서 StoreKit Configuration 선택
1. 좌측에서 **Run** 선택
2. **Options** 탭 클릭
3. **StoreKit Configuration** 드롭다운에서 `.storekit` 파일 선택

## 3. 환경 변수 설정 (선택)
- `STOREKTIT_TEST` = `1` 설정으로 테스트 모드 활성화

## Configuration 파일 위치
- 프로젝트 루트 또는 별도 폴더에 `.storekit` 파일 저장
- Git으로 버전 관리 가능

## 주의사항
- Configuration 파일은 **로컬 테스트 전용**
- 실제 App Store Connect 상품 ID와 동일하게 설정 권장
- Sandbox/Production 테스트 시에는 Configuration 해제
