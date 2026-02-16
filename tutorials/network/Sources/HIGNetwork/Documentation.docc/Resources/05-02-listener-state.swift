import Network

extension ChatServer {
    func setupStateHandler() {
        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .setup:
                print("리스너 설정 중...")
                
            case .waiting(let error):
                print("대기 중: \(error.localizedDescription)")
                
            case .ready:
                // 실제 할당된 포트 확인
                if let port = self?.listener?.port {
                    print("서버 시작됨 - 포트: \(port)")
                }
                
            case .failed(let error):
                print("리스너 실패: \(error)")
                self?.restart()
                
            case .cancelled:
                print("리스너 취소됨")
                
            @unknown default:
                break
            }
        }
        
        // 리스너 시작
        listener?.start(queue: queue)
    }
    
    private func restart() {
        // 재시작 로직
    }
}
