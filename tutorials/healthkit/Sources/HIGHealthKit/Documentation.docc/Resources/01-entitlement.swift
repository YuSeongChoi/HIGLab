// MARK: - HealthKit Entitlement 설정

/*
 Xcode에서 HealthKit capability를 활성화하는 방법:
 
 1. 프로젝트 네비게이터에서 프로젝트 선택
 2. TARGETS에서 앱 타겟 선택
 3. "Signing & Capabilities" 탭 클릭
 4. "+ Capability" 버튼 클릭
 5. "HealthKit" 검색 후 추가
 
 추가 옵션:
 - Clinical Health Records: 의료 기록 접근 (병원 연동)
 - Background Delivery: 백그라운드에서 데이터 업데이트 수신
 
 이 설정은 자동으로 entitlements 파일을 생성합니다:
 
 <?xml version="1.0" encoding="UTF-8"?>
 <plist version="1.0">
 <dict>
     <key>com.apple.developer.healthkit</key>
     <true/>
     <key>com.apple.developer.healthkit.access</key>
     <array/>
 </dict>
 </plist>
 
 ⚠️ 이 설정 없이는 HKHealthStore 사용 시 런타임 에러 발생!
 */
