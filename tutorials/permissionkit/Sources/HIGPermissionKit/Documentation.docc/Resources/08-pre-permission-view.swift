#if canImport(PermissionKit)
import PermissionKit
import SwiftUI

// 프리-퍼미션 화면 컴포넌트
struct PrePermissionView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let benefits: [Benefit]
    let primaryButtonTitle: String
    let secondaryButtonTitle: String?
    let onPrimaryAction: () -> Void
    let onSecondaryAction: (() -> Void)?
    
    struct Benefit: Identifiable {
        let id = UUID()
        let icon: String
        let text: String
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // 아이콘
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(iconColor.gradient)
            
            // 제목
            Text(title)
                .font(.title.bold())
                .multilineTextAlignment(.center)
            
            // 설명
            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 혜택 목록
            VStack(alignment: .leading, spacing: 12) {
                ForEach(benefits) { benefit in
                    HStack(spacing: 12) {
                        Image(systemName: benefit.icon)
                            .foregroundStyle(iconColor)
                            .frame(width: 24)
                        
                        Text(benefit.text)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            Spacer()
            
            // 버튼들
            VStack(spacing: 12) {
                Button(action: onPrimaryAction) {
                    Text(primaryButtonTitle)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                if let secondaryTitle = secondaryButtonTitle,
                   let secondaryAction = onSecondaryAction {
                    Button(action: secondaryAction) {
                        Text(secondaryTitle)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

// 사용 예시
struct PrePermissionExample: View {
    var body: some View {
        PrePermissionView(
            icon: "bell.badge.fill",
            iconColor: .red,
            title: "알림을 받아보세요",
            description: "중요한 업데이트와 할인 정보를 놓치지 마세요",
            benefits: [
                .init(icon: "gift.fill", text: "특별 할인 알림"),
                .init(icon: "clock.fill", text: "예약 리마인더"),
                .init(icon: "star.fill", text: "새로운 기능 소식")
            ],
            primaryButtonTitle: "알림 허용하기",
            secondaryButtonTitle: "나중에",
            onPrimaryAction: {
                // 시스템 권한 요청
            },
            onSecondaryAction: {
                // 건너뛰기
            }
        )
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
