#if canImport(PermissionKit)
import PermissionKit
import SwiftUI

// 각 권한 유형별 설명 데이터
struct PermissionExplanation {
    let type: PermissionType
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let benefits: [PrePermissionView.Benefit]
    
    enum PermissionType {
        case notification
        case camera
        case location
        case contacts
        case health
    }
    
    static let notification = PermissionExplanation(
        type: .notification,
        icon: "bell.badge.fill",
        iconColor: .red,
        title: "알림 받기",
        description: "중요한 업데이트를 실시간으로 받아보세요",
        benefits: [
            .init(icon: "gift.fill", text: "이벤트 및 할인 소식"),
            .init(icon: "clock.fill", text: "일정 리마인더"),
            .init(icon: "message.fill", text: "새 메시지 알림")
        ]
    )
    
    static let camera = PermissionExplanation(
        type: .camera,
        icon: "camera.fill",
        iconColor: .blue,
        title: "카메라 접근",
        description: "사진 촬영과 QR 코드 스캔에 사용됩니다",
        benefits: [
            .init(icon: "person.crop.circle", text: "프로필 사진 촬영"),
            .init(icon: "qrcode.viewfinder", text: "QR 코드 스캔"),
            .init(icon: "video.fill", text: "동영상 촬영")
        ]
    )
    
    static let location = PermissionExplanation(
        type: .location,
        icon: "location.fill",
        iconColor: .green,
        title: "위치 정보",
        description: "주변 매장과 서비스를 찾을 때 사용됩니다",
        benefits: [
            .init(icon: "map.fill", text: "가까운 매장 찾기"),
            .init(icon: "car.fill", text: "배달 추적"),
            .init(icon: "sun.max.fill", text: "지역 날씨 정보")
        ]
    )
    
    static let contacts = PermissionExplanation(
        type: .contacts,
        icon: "person.2.fill",
        iconColor: .orange,
        title: "연락처 접근",
        description: "친구를 찾고 초대할 때 사용됩니다",
        benefits: [
            .init(icon: "person.badge.plus", text: "친구 찾기"),
            .init(icon: "paperplane.fill", text: "쉬운 초대하기"),
            .init(icon: "person.3.fill", text: "함께하는 친구 확인")
        ]
    )
    
    static let health = PermissionExplanation(
        type: .health,
        icon: "heart.fill",
        iconColor: .pink,
        title: "건강 데이터",
        description: "운동과 건강 상태를 추적합니다",
        benefits: [
            .init(icon: "figure.walk", text: "활동량 분석"),
            .init(icon: "chart.line.uptrend.xyaxis", text: "건강 트렌드 확인"),
            .init(icon: "trophy.fill", text: "목표 달성 추적")
        ]
    )
}

// 권한 설명 카드 뷰
struct PermissionExplanationCard: View {
    let explanation: PermissionExplanation
    let status: PermissionStatus
    
    enum PermissionStatus {
        case pending, granted, denied
    }
    
    var body: some View {
        HStack {
            Image(systemName: explanation.icon)
                .font(.title2)
                .foregroundStyle(explanation.iconColor)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(explanation.title)
                    .font(.headline)
                
                Text(explanation.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            statusIcon
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .pending:
            Image(systemName: "circle")
                .foregroundStyle(.secondary)
        case .granted:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .denied:
            Image(systemName: "xmark.circle.fill")
                .foregroundStyle(.red)
        }
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
