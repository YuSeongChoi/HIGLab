import SwiftUI

struct FirmwareUpdateView: View {
    @State private var updateState: UpdateState = .idle
    @State private var progress: Double = 0
    let firmwareInfo: FirmwareInfo
    
    enum UpdateState {
        case idle
        case downloading
        case transferring
        case rebooting
        case complete
        case failed(String)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // 상태 아이콘
            stateIcon
                .font(.system(size: 60))
                .foregroundStyle(stateColor)
            
            // 상태 텍스트
            Text(stateTitle)
                .font(.title2.bold())
            
            Text(stateDescription)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            // 진행률 바
            if showProgress {
                VStack(spacing: 8) {
                    ProgressView(value: progress)
                        .progressViewStyle(.linear)
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .monospacedDigit()
                }
                .padding(.horizontal)
            }
            
            // 액션 버튼
            if case .idle = updateState {
                Button("업데이트 시작") {
                    startUpdate()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }
    
    private var stateIcon: Image {
        switch updateState {
        case .idle: return Image(systemName: "arrow.down.circle")
        case .downloading, .transferring: return Image(systemName: "arrow.triangle.2.circlepath")
        case .rebooting: return Image(systemName: "restart.circle")
        case .complete: return Image(systemName: "checkmark.circle.fill")
        case .failed: return Image(systemName: "exclamationmark.triangle.fill")
        }
    }
    
    private var stateColor: Color {
        switch updateState {
        case .complete: return .green
        case .failed: return .red
        default: return .blue
        }
    }
    
    private var stateTitle: String {
        switch updateState {
        case .idle: return "업데이트 준비됨"
        case .downloading: return "다운로드 중..."
        case .transferring: return "전송 중..."
        case .rebooting: return "재시작 중..."
        case .complete: return "업데이트 완료"
        case .failed(let error): return "업데이트 실패"
        }
    }
    
    private var stateDescription: String {
        switch updateState {
        case .idle: return "버전 \(firmwareInfo.version)으로 업데이트합니다."
        case .downloading: return "펌웨어를 다운로드하고 있습니다."
        case .transferring: return "기기로 전송 중입니다. 전원을 끄지 마세요."
        case .rebooting: return "기기가 재시작됩니다."
        case .complete: return "기기가 최신 상태입니다."
        case .failed(let error): return error
        }
    }
    
    private var showProgress: Bool {
        switch updateState {
        case .downloading, .transferring: return true
        default: return false
        }
    }
    
    private func startUpdate() {
        // 업데이트 로직 시작
    }
}
