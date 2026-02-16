import SwiftUI

struct DeniedView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.circle")
                .font(.system(size: 80))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("접근 권한 필요")
                    .font(.title)
                    .bold()
                
                Text("Apple Music 접근이 거부되어 있습니다.\n설정에서 권한을 변경해주세요.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                openSettings()
            } label: {
                HStack {
                    Image(systemName: "gear")
                    Text("설정 열기")
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
        .padding()
    }
    
    private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
