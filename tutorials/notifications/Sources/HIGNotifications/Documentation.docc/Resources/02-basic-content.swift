import UserNotifications

// UNMutableNotificationContent 기본 설정

let content = UNMutableNotificationContent()

// 필수 요소
content.title = "리마인더"           // 굵은 제목
content.body = "약 먹을 시간이에요"   // 본문 내용

// 선택 요소
content.subtitle = "건강"            // 작은 부제목
content.sound = .default             // 알림 소리

// badge는 앱 아이콘의 숫자
content.badge = NSNumber(value: 1)

// 여러 줄 본문도 가능
content.body = """
오전 9시 미팅
장소: 회의실 A
참석자: 김철수, 이영희
"""
