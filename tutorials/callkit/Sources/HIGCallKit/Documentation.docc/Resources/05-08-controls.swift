import SwiftUI

struct CallControlsView: View {
    @ObservedObject var viewModel: CallViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            // 상단 버튼 행
            HStack(spacing: 50) {
                ControlButton(
                    icon: viewModel.isMuted ? "mic.slash.fill" : "mic.fill",
                    label: "음소거",
                    isActive: viewModel.isMuted
                ) {
                    viewModel.toggleMute()
                }
                
                ControlButton(
                    icon: "keyboard",
                    label: "키패드",
                    isActive: false
                ) {
                    viewModel.showKeypad()
                }
                
                ControlButton(
                    icon: viewModel.isSpeaker ? "speaker.wave.3.fill" : "speaker.fill",
                    label: "스피커",
                    isActive: viewModel.isSpeaker
                ) {
                    viewModel.toggleSpeaker()
                }
            }
            
            // 하단 버튼 행
            HStack(spacing: 50) {
                ControlButton(
                    icon: "plus",
                    label: "통화 추가",
                    isActive: false
                ) {
                    viewModel.addCall()
                }
                
                ControlButton(
                    icon: "video.fill",
                    label: "FaceTime",
                    isActive: false
                ) {
                    viewModel.startVideo()
                }
                
                ControlButton(
                    icon: viewModel.isOnHold ? "play.fill" : "pause.fill",
                    label: viewModel.isOnHold ? "재개" : "보류",
                    isActive: viewModel.isOnHold
                ) {
                    viewModel.toggleHold()
                }
            }
            
            // 통화 종료 버튼
            Button {
                viewModel.endCall()
            } label: {
                Image(systemName: "phone.down.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 70, height: 70)
                    .background(Color.red)
                    .clipShape(Circle())
            }
        }
    }
}

struct ControlButton: View {
    let icon: String
    let label: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .frame(width: 60, height: 60)
                    .background(isActive ? .white : .white.opacity(0.3))
                    .foregroundStyle(isActive ? .blue : .white)
                    .clipShape(Circle())
                
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.white)
            }
        }
    }
}

class CallViewModel: ObservableObject {
    @Published var isMuted = false
    @Published var isSpeaker = false
    @Published var isOnHold = false
    
    func toggleMute() { isMuted.toggle() }
    func toggleSpeaker() { isSpeaker.toggle() }
    func toggleHold() { isOnHold.toggle() }
    func showKeypad() { }
    func addCall() { }
    func startVideo() { }
    func endCall() { }
}
