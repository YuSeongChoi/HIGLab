import Network

extension TCPClient {
    func sendWithRetry(_ data: Data, retryCount: Int = 3) {
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .contentProcessed { [weak self] error in
                if let error = error {
                    print("전송 오류: \(error)")
                    
                    // 재시도 로직
                    if retryCount > 0 {
                        print("재시도 중... (\(retryCount)회 남음)")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self?.sendWithRetry(data, retryCount: retryCount - 1)
                        }
                    } else {
                        print("전송 최종 실패")
                        self?.handleSendFailure(data)
                    }
                } else {
                    print("전송 완료")
                }
            }
        )
    }
    
    private func handleSendFailure(_ data: Data) {
        // 실패한 메시지를 로컬에 저장하거나 사용자에게 알림
    }
}
