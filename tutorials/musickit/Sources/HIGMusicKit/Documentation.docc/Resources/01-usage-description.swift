// Info.plist - NSAppleMusicUsageDescription 추가

/*
 방법 1: Info.plist 파일 직접 수정 (Source Code)
 
 <dict>
     ...
     <key>NSAppleMusicUsageDescription</key>
     <string>음악을 검색하고 재생하기 위해 Apple Music에 접근합니다.</string>
 </dict>
 
 
 방법 2: Xcode Property List 편집기
 
 1. Info.plist 선택
 2. + 버튼으로 새 항목 추가
 3. "Privacy - Media Library Usage Description" 선택
 4. 값에 설명 입력
 
 
 💡 설명 작성 팁:
 
 - 구체적으로: "음악 재생"이 아닌 "음악을 검색하고 재생"
 - 사용자 관점: "앱 기능"이 아닌 "당신의 음악을"
 - 한국어로: 앱 언어에 맞춰 작성
 
 예시:
 "내 라이브러리의 음악을 재생하고 Apple Music에서 새로운 음악을 찾기 위해 접근 권한이 필요합니다."
*/
