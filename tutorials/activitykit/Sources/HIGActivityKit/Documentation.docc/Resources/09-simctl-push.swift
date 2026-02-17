# 시뮬레이터에 Push 알림 전송
xcrun simctl push booted com.example.delivery TestPayload.apns

# 특정 기기 지정
xcrun simctl push <DEVICE_UDID> com.example.delivery TestPayload.apns

# 시뮬레이터 목록 확인
xcrun simctl list devices
