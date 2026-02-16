import CoreNFC

class ISO7816Reader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    func startSession() {
        tagSession = NFCTagReaderSession(
            pollingOption: .iso14443,
            delegate: self
        )
        tagSession?.alertMessage = "ISO 7816 카드를 스캔하세요."
        tagSession?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        guard case let .iso7816(tag) = tags.first else {
            session.invalidate(errorMessage: "ISO 7816 태그가 아닙니다.")
            return
        }
        
        session.connect(to: tags.first!) { error in
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            
            self.readInitialData(tag, session: session)
        }
    }
    
    private func readInitialData(_ tag: NFCISO7816Tag, 
                                  session: NFCTagReaderSession) {
        // 초기 데이터 읽기
        print("=== ISO 7816 태그 정보 ===")
        print("UID: \(tag.identifier.hexString)")
        
        // ATS (Answer To Select) 분석
        if let historical = tag.historicalBytes {
            print("Historical Bytes: \(historical.hexString)")
            analyzeHistoricalBytes(historical)
        }
        
        // 초기 선택된 AID
        if !tag.initialSelectedAID.isEmpty {
            print("선택된 AID: \(tag.initialSelectedAID)")
        }
    }
    
    private func analyzeHistoricalBytes(_ bytes: Data) {
        // Historical bytes 해석 (제조사마다 다름)
        // 일반적으로 카드 유형, 버전 정보 등 포함
        guard bytes.count > 0 else { return }
        
        let categoryIndicator = bytes[0]
        switch categoryIndicator {
        case 0x00:
            print("  카테고리: Status information")
        case 0x80:
            print("  카테고리: COMPACT-TLV")
        default:
            print("  카테고리: 제조사 정의 (0x\(String(format: "%02X", categoryIndicator)))")
        }
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        tagSession = nil
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
