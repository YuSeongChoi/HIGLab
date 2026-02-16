import CoreNFC

class FeliCaReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    func readFeliCaBlocks(_ tag: NFCFeliCaTag, session: NFCTagReaderSession) {
        // 서비스 코드 설정 (리틀 엔디안)
        // 예: 0x000B (Suica 잔액 조회)
        let serviceCodeList = [Data([0x0B, 0x00])]
        
        // 읽을 블록 번호 (리틀 엔디안)
        // 블록 0부터 시작
        let blockList = [Data([0x80, 0x00])]  // 블록 0
        
        tag.readWithoutEncryption(
            serviceCodeList: serviceCodeList,
            blockList: blockList
        ) { status1, status2, blockData, error in
            if let error = error {
                print("읽기 실패: \(error)")
                session.invalidate(errorMessage: "읽기 실패")
                return
            }
            
            // 상태 확인
            print("Status: \(status1), \(status2)")
            
            // 블록 데이터 처리 (각 블록 16바이트)
            for (index, block) in blockData.enumerated() {
                print("Block \(index): \(block.hexString)")
                
                // Suica 잔액 예시 (리틀 엔디안)
                if block.count >= 2 {
                    let balance = UInt16(block[0]) | (UInt16(block[1]) << 8)
                    print("  추정 잔액: ¥\(balance)")
                }
            }
            
            session.alertMessage = "읽기 완료!"
            session.invalidate()
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        guard case let .feliCa(tag) = tags.first else { return }
        
        session.connect(to: tags.first!) { error in
            if error == nil {
                self.readFeliCaBlocks(tag, session: session)
            }
        }
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didInvalidateWithError error: Error) {
        tagSession = nil
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
