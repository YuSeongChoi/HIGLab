import SwiftUI

struct InvitationView: View {
    @ObservedObject var advertiserManager: AdvertiserManager
    
    var body: some View {
        if let invitation = advertiserManager.pendingInvitation {
            VStack(spacing: 20) {
                Image(systemName: "person.wave.2")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text("연결 요청")
                    .font(.title2.bold())
                
                Text("\(invitation.peerID.displayName)님이 연결을 요청합니다.")
                    .multilineTextAlignment(.center)
                
                if let context = invitation.context,
                   let message = String(data: context, encoding: .utf8) {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 20) {
                    Button("거절") {
                        advertiserManager.declineInvitation()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("수락") {
                        advertiserManager.acceptInvitation()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 10)
            .padding()
        }
    }
}
