import CoreNFC

class MIFAREReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    func startSession() {
        tagSession = NFCTagReaderSession(
            pollingOption: .iso14443,
            delegate: self
        )
        tagSession?.alertMessage = "MIFARE 카드를 스캔하세요."
        tagSession?.begin()
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        guard case let .miFare(tag) = tags.first else {
            session.invalidate(errorMessage: "MIFARE 태그가 아닙니다.")
            return
        }
        
        session.connect(to: tags.first!) { error in
            if let error = error {
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }
            
            self.identifyMIFAREFamily(tag, session: session)
        }
    }
    
    private func identifyMIFAREFamily(_ tag: NFCMiFareTag, 
                                       session: NFCTagReaderSession) {
        // MIFARE 제품군 식별
        let family = tag.mifareFamily
        
        switch family {
        case .ultralight:
            // MIFARE Ultralight (64-192 bytes)
            // 일회용 교통권, 이벤트 티켓
            print("MIFARE Ultralight 감지")
            print("  - 저비용, 소용량")
            print("  - 암호화 없음")
            
        case .plus:
            // MIFARE Plus (2KB-4KB)
            // MIFARE Classic 후속, AES 암호화
            print("MIFARE Plus 감지")
            print("  - AES 암호화 지원")
            print("  - MIFARE Classic 호환 모드")
            
        case .desfire:
            // MIFARE DESFire (2KB-8KB)
            // 고급 보안, 다중 애플리케이션
            print("MIFARE DESFire 감지")
            print("  - AES/3DES 암호화")
            print("  - 다중 애플리케이션 지원")
            print("  - 높은 보안 수준")
            
        case .unknown:
            print("알 수 없는 MIFARE 타입")
            
        @unknown default:
            print("새로운 MIFARE 타입")
        }
        
        // 공통 속성
        print("UID: \(tag.identifier.hexString)")
        print("Historical Bytes: \(tag.historicalBytes?.hexString ?? "없음")")
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
