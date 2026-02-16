import SwiftUI
import TipKit

struct DownloadTip: Tip {
    var title: Text { Text("오프라인 저장") }
    var message: Text? { Text("다운로드하여 오프라인에서도 보세요") }
}

struct InvalidateTipView: View {
    let downloadTip = DownloadTip()
    @State private var isDownloaded = false
    
    var body: some View {
        VStack {
            Button {
                downloadContent()
            } label: {
                Label(
                    isDownloaded ? "다운로드 완료" : "다운로드",
                    systemImage: isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle"
                )
            }
            .popoverTip(downloadTip)
        }
    }
    
    func downloadContent() {
        isDownloaded = true
        
        // 사용자가 해당 기능을 사용했으므로 팁 무효화
        // .actionPerformed: 사용자가 기능을 실제로 사용함
        downloadTip.invalidate(reason: .actionPerformed)
        
        // 다른 무효화 이유:
        // .tipClosed: 사용자가 팁을 닫음 (TipKit이 자동 처리)
    }
}
