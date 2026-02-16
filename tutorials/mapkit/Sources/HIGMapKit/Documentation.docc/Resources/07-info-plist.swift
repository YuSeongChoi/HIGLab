// Info.plist 설정 (XML 형식)
// Xcode에서 Info 탭에서 추가하거나 직접 편집

/*
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>주변 맛집을 찾고 현재 위치를 지도에 표시하기 위해 위치 정보가 필요합니다.</string>
 
 // 백그라운드 위치 사용 시 추가
 <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
 <string>맛집까지 실시간 길안내를 위해 백그라운드에서도 위치 정보가 필요합니다.</string>
*/

// 프로젝트 설정에서 추가하는 방법:
// 1. Xcode에서 프로젝트 선택
// 2. TARGETS > [앱 이름] > Info 탭
// 3. Custom iOS Target Properties에서 + 버튼
// 4. "Privacy - Location When In Use Usage Description" 검색 후 추가
// 5. 사용자에게 보여줄 설명 입력

// 중요: 이 설명은 실제로 사용자에게 표시됩니다.
// 앱이 왜 위치 정보가 필요한지 명확하게 설명하세요.
