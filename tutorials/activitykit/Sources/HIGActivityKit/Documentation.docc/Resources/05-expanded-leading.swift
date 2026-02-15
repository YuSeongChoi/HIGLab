import SwiftUI

// MARK: - Expanded Leading View
// 배달원 프로필 이미지

struct ExpandedLeadingView: View {
    let context: ActivityViewContext<DeliveryAttributes>
    
    var body: some View {
        if let driverImageURL = context.state.driverImageURL {
            AsyncImage(url: driverImageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                driverPlaceholder
            }
            .frame(width: 44, height: 44)
            .clipShape(Circle())
        } else {
            driverPlaceholder
        }
    }
    
    var driverPlaceholder: some View {
        ZStack {
            Circle()
                .fill(.quaternary)
            Image(systemName: "person.fill")
                .foregroundStyle(.secondary)
        }
        .frame(width: 44, height: 44)
    }
}
