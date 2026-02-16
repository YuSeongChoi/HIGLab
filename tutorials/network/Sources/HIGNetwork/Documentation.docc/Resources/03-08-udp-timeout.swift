import Network

extension UDPClient {
    // 타임아웃이 있는 요청-응답 패턴
    func request(_ data: Data, timeout: TimeInterval = 5.0, completion: @escaping (Data?) -> Void) {
        var timeoutTask: DispatchWorkItem?
        var completed = false
        
        // 타임아웃 설정
        timeoutTask = DispatchWorkItem { [weak self] in
            guard !completed else { return }
            completed = true
            print("타임아웃: 응답 없음")
            completion(nil)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timeout, execute: timeoutTask!)
        
        // 응답 대기
        connection?.receiveMessage { [weak self] responseData, _, _, error in
            guard !completed else { return }
            completed = true
            timeoutTask?.cancel()
            
            if error != nil {
                completion(nil)
            } else {
                completion(responseData)
            }
        }
        
        // 요청 전송
        connection?.send(
            content: data,
            contentContext: .defaultMessage,
            isComplete: true,
            completion: .contentProcessed { _ in }
        )
    }
}
