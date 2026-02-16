// MARK: - Info.plist 필수 설정

/*
 HealthKit을 사용하려면 Info.plist에 다음 키를 추가해야 합니다:
 
 1. NSHealthShareUsageDescription (읽기 권한)
    - 사용자가 "건강 데이터 읽기"를 승인할 때 표시되는 메시지
    - 예: "걸음 수와 심박수를 확인하여 피트니스 대시보드에 표시합니다."
 
 2. NSHealthUpdateUsageDescription (쓰기 권한)
    - 사용자가 "건강 데이터 쓰기"를 승인할 때 표시되는 메시지
    - 예: "운동 기록을 건강 앱에 저장합니다."
 
 XML 형식:
 
 <key>NSHealthShareUsageDescription</key>
 <string>걸음 수, 심박수, 수면 데이터를 읽어 피트니스 대시보드에 표시합니다.</string>
 
 <key>NSHealthUpdateUsageDescription</key>
 <string>운동 기록을 건강 앱에 저장하여 Apple 건강과 동기화합니다.</string>
 
 ⚠️ 주의: 이 설명 없이 권한을 요청하면 앱이 크래시합니다!
 */
