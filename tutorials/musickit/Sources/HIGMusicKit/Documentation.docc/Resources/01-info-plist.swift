// Info.plist에 추가할 키

/*
 Key: NSAppleMusicUsageDescription
 Type: String
 Value: 음악을 검색하고 재생하기 위해 Apple Music에 접근합니다.
 
 ⚠️ 이 키가 없으면:
 - 권한 요청 시 앱이 크래시하거나
 - 권한 요청이 무시됩니다
 
 💡 좋은 설명 예시:
 - "음악을 검색하고 재생하기 위해 Apple Music에 접근합니다."
 - "내 라이브러리에서 플레이리스트를 가져오기 위해 Apple Music 접근이 필요합니다."
 
 ❌ 나쁜 설명 예시:
 - "앱 기능을 위해 필요합니다." (너무 모호함)
 - "" (빈 문자열)
 */

// Info.plist XML 예시:
/*
<key>NSAppleMusicUsageDescription</key>
<string>음악을 검색하고 재생하기 위해 Apple Music에 접근합니다.</string>
*/
