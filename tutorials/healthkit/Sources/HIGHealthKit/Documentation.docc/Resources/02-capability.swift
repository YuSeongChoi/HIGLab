// MARK: - Xcode Capability 설정

/*
 HealthKit Capability 추가 단계:
 
 1. Xcode에서 프로젝트 파일(.xcodeproj) 선택
 
 2. TARGETS에서 앱 타겟 선택
 
 3. "Signing & Capabilities" 탭으로 이동
 
 4. "+ Capability" 버튼 클릭
 
 5. 검색창에 "HealthKit" 입력
 
 6. HealthKit 더블클릭하여 추가
 
 추가 옵션 (필요시 체크):
 ┌─────────────────────────────────────┐
 │ ☑️ HealthKit                        │
 │   ☐ Clinical Health Records        │  ← 의료 기록 접근 시
 │   ☐ Background Delivery            │  ← 백그라운드 업데이트 시
 └─────────────────────────────────────┘
 
 설정 완료 후 자동 생성되는 파일:
 - [AppName].entitlements
 
 이 파일에 com.apple.developer.healthkit 키가 추가됩니다.
 */
