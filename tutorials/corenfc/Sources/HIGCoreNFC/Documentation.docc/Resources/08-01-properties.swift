import CoreNFC

class ISO7816Reader: NSObject, NFCTagReaderSessionDelegate {
    
    func inspectISO7816Tag(_ tag: NFCISO7816Tag) {
        // NFCISO7816Tag 프로토콜의 주요 속성
        
        // 1. identifier (UID)
        // 태그의 고유 식별자 (4, 7, 또는 10바이트)
        let uid = tag.identifier
        print("UID: \(uid.hexString)")
        
        // 2. historicalBytes
        // Answer To Select (ATS)의 historical bytes
        // 태그 제조사 정보 등 포함
        if let historical = tag.historicalBytes {
            print("Historical Bytes: \(historical.hexString)")
        }
        
        // 3. applicationData
        // 애플리케이션 관련 데이터
        if let appData = tag.applicationData {
            print("Application Data: \(appData.hexString)")
        }
        
        // 4. initialSelectedAID
        // 초기 선택된 Application Identifier
        print("Initial AID: \(tag.initialSelectedAID)")
        
        // 5. proprietaryApplicationDataCoding
        // 앱 데이터 코딩 여부
        print("Proprietary Coding: \(tag.proprietaryApplicationDataCoding)")
    }
    
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) { }
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) { }
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) { }
}

extension Data {
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
