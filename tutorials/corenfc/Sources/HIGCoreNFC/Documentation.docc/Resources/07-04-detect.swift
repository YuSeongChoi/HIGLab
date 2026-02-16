import CoreNFC

class TagReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    var onTagDetected: ((NFCTag) -> Void)?
    
    func startSession() {
        let pollingOptions: NFCTagReaderSession.PollingOption = [
            .iso14443, .iso15693, .iso18092
        ]
        
        tagSession = NFCTagReaderSession(
            pollingOption: pollingOptions,
            delegate: self
        )
        tagSession?.alertMessage = "태그를 스캔하세요."
        tagSession?.begin()
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        // 여러 태그가 감지될 수 있음
        print("감지된 태그 수: \(tags.count)")
        
        // 일반적으로 첫 번째 태그 사용
        guard let tag = tags.first else {
            session.invalidate(errorMessage: "태그를 찾을 수 없습니다.")
            return
        }
        
        // 태그 타입 출력
        switch tag {
        case .iso7816(let iso7816Tag):
            print("ISO 7816 태그 감지")
            print("  ID: \(iso7816Tag.identifier.hexString)")
            
        case .feliCa(let feliCaTag):
            print("FeliCa 태그 감지")
            print("  IDm: \(feliCaTag.currentIDm.hexString)")
            
        case .iso15693(let iso15693Tag):
            print("ISO 15693 태그 감지")
            print("  ID: \(iso15693Tag.identifier.hexString)")
            
        case .miFare(let miFareTag):
            print("MIFARE 태그 감지")
            print("  ID: \(miFareTag.identifier.hexString)")
            
        @unknown default:
            print("알 수 없는 태그 타입")
        }
        
        onTagDetected?(tag)
    }
    
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
