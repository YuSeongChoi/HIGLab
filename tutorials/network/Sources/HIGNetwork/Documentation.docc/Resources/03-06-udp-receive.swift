import Network

extension UDPClient {
    func receive() {
        // UDP는 receiveMessage 사용 (데이터그램 단위)
        connection?.receiveMessage { data, context, isComplete, error in
            if let error = error {
                print("수신 오류: \(error)")
                return
            }
            
            if let data = data {
                print("수신: \(data.count) 바이트")
                
                // context에서 발신자 정보 확인 가능
                if let context = context {
                    print("메시지 ID: \(context.identifier)")
                }
                
                if let message = String(data: data, encoding: .utf8) {
                    print("내용: \(message)")
                }
            }
        }
    }
}
