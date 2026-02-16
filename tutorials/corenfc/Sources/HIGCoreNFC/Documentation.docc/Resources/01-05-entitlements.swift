// App.entitlements 파일 설정
//
// 1. Xcode에서 Signing & Capabilities 탭 열기
// 2. "+ Capability" 클릭
// 3. "Near Field Communication Tag Reading" 추가
//
// 또는 직접 entitlements 파일 수정:

/*
 <?xml version="1.0" encoding="UTF-8"?>
 <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
   "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
 <plist version="1.0">
 <dict>
     <key>com.apple.developer.nfc.readersession.formats</key>
     <array>
         <string>NDEF</string>
         <string>TAG</string>
     </array>
 </dict>
 </plist>
 */

// NDEF: NFCNDEFReaderSession 사용 가능
// TAG: NFCTagReaderSession 사용 가능 (네이티브 태그 접근)
