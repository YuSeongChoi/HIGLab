# 푸시 알림 설정

## Xcode Capability 추가

1. **Push Notifications**
   - Signing & Capabilities → + Capability
   - "Push Notifications" 추가

2. **Background Modes**
   - Signing & Capabilities → + Capability
   - "Background Modes" 추가
   - [x] Remote notifications 체크

## Info.plist (필요시)
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 주의사항
- 시뮬레이터에서는 푸시 알림 테스트 제한
- 실제 디바이스에서 테스트 권장
