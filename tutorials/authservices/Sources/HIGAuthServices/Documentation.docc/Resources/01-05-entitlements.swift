// Xcode에서 Sign in with Apple capability 추가하기

// 1. 프로젝트 설정 > Signing & Capabilities 탭
// 2. "+ Capability" 버튼 클릭
// 3. "Sign in with Apple" 선택

// 추가되면 .entitlements 파일에 다음이 자동 추가됩니다:
/*
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" 
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
*/
