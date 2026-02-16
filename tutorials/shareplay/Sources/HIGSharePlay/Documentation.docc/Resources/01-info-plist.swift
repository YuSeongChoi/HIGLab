// Info.plist 설정
// ===============

// SharePlay를 지원하려면 Info.plist에 다음 키를 추가해야 합니다:

/*
 <key>NSSupportsGroupActivities</key>
 <true/>
*/

// 이 설정이 없으면:
// - GroupActivity.sessions()가 세션을 수신하지 못함
// - 앱이 SharePlay 대상으로 표시되지 않음

// ✅ Xcode에서 설정하는 방법:
// 1. 프로젝트 선택 → Info 탭
// 2. "Supports Group Activities" 키 추가
// 3. 값을 YES로 설정

// 또는 Info.plist 파일을 직접 편집:
/*
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" ...>
 <plist version="1.0">
 <dict>
     ...
     <key>NSSupportsGroupActivities</key>
     <true/>
     ...
 </dict>
 </plist>
*/

// ⚠️ 주의사항
// - iOS 15.0+ 에서만 SharePlay 사용 가능
// - macOS 12.0+ 에서도 지원
// - tvOS 15.0+ 에서도 지원
// - visionOS 1.0+ 에서도 지원

import Foundation

struct AppConfiguration {
    static let minimumIOSVersion = "15.0"
    static let supportsGroupActivities = true
}
