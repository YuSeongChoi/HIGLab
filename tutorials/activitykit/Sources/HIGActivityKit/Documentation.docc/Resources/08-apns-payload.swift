// MARK: - APNs Payload for Live Activity Update

/*
 서버에서 APNs로 보내는 페이로드 형식:
 
 Headers:
 - apns-push-type: liveactivity
 - apns-topic: {bundle-id}.push-type.liveactivity
 - apns-priority: 10 (즉시) 또는 5 (배터리 절약)
 
 Payload:
*/

let apnsPayload = """
{
    "aps": {
        "timestamp": 1699000000,
        "event": "update",
        "content-state": {
            "status": "pickedUp",
            "estimatedArrival": 1699001800,
            "driverName": "김배달",
            "driverImageURL": "https://example.com/driver.jpg"
        },
        "alert": {
            "title": "배달 시작!",
            "body": "김배달님이 음식을 픽업했어요"
        }
    }
}
"""

// event 종류:
// - "update": 상태 업데이트
// - "end": Activity 종료

let endPayload = """
{
    "aps": {
        "timestamp": 1699002000,
        "event": "end",
        "dismissal-date": 1699005600,
        "content-state": {
            "status": "delivered",
            "estimatedArrival": 1699002000,
            "driverName": "김배달",
            "driverImageURL": null
        },
        "alert": {
            "title": "배달 완료!",
            "body": "맛있게 드세요 🍕"
        }
    }
}
"""
