import CoreNFC

class FeliCaReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    // 주요 시스템 코드
    struct SystemCodes {
        static let common = Data([0x88, 0xB4])      // 공통 영역
        static let suica = Data([0x00, 0x03])       // Suica/PASMO
        static let ndef = Data([0xFE, 0x00])        // NDEF
        static let wildcard = Data([0xFF, 0xFF])   // 모든 시스템
    }
    
    func startSession() {
        tagSession = NFCTagReaderSession(
            pollingOption: .iso18092,  // FeliCa
            delegate: self
        )
        tagSession?.alertMessage = "FeliCa 카드를 스캔하세요."
        tagSession?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        guard case let .feliCa(tag) = tags.first else { return }
        
        session.connect(to: tags.first!) { error in
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            
            // 특정 시스템 코드로 폴링
            tag.polling(
                systemCode: SystemCodes.suica,
                requestCode: .systemCode,
                timeSlot: .max1
            ) { pmm, requestData, error in
                if let error = error {
                    print("폴링 실패: \(error)")
                    return
                }
                
                // PMm: Manufacture Parameter (8바이트)
                // 카드의 응답 시간 특성 등 포함
                print("PMm: \(pmm.hexString)")
                
                if let data = requestData {
                    print("Request Data: \(data.hexString)")
                }
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
