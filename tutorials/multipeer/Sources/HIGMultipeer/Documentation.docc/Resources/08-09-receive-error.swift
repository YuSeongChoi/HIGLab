import MultipeerConnectivity

extension ResourceManager {
    
    // 수신 오류 처리
    private func handleReceiveError(_ error: Error, for resourceName: String) {
        let nsError = error as NSError
        
        switch nsError.code {
        case MCError.timedOut.rawValue:
            print("수신 시간 초과: \(resourceName)")
            
        case MCError.cancelled.rawValue:
            print("수신 취소됨: \(resourceName)")
            
        case MCError.notConnected.rawValue:
            print("연결 끊김: \(resourceName)")
            
        default:
            print("수신 오류 (\(nsError.code)): \(error.localizedDescription)")
        }
        
        // 사용자에게 알림
        DispatchQueue.main.async {
            self.lastError = error
            self.showErrorAlert = true
        }
    }
    
    @Published var lastError: Error?
    @Published var showErrorAlert = false
}

// 수신 취소
extension ResourceManager {
    
    func cancelReceive(for info: ReceiveInfo) {
        info.progress.cancel()
        
        DispatchQueue.main.async {
            self.receivingResources.removeAll { $0.id == info.id }
        }
    }
}
