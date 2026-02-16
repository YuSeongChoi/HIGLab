import CoreNFC

class ISO7816Reader {
    
    /// SELECT 명령으로 애플리케이션 선택
    func selectApplication(
        _ tag: NFCISO7816Tag,
        aid: Data,
        completion: @escaping (Bool, Data?, Error?) -> Void
    ) {
        // SELECT 명령 생성
        // CLA: 0x00 (표준)
        // INS: 0xA4 (SELECT)
        // P1: 0x04 (AID로 선택)
        // P2: 0x00 (첫 번째 또는 유일한 occurrence)
        guard let apdu = NFCISO7816APDU(
            instructionClass: 0x00,
            instructionCode: 0xA4,
            p1Parameter: 0x04,
            p2Parameter: 0x00,
            data: aid,
            expectedResponseLength: 256
        ) else {
            completion(false, nil, nil)
            return
        }
        
        // APDU 전송
        tag.sendCommand(apdu: apdu) { data, sw1, sw2, error in
            if let error = error {
                completion(false, nil, error)
                return
            }
            
            // 상태 코드 확인
            let statusWord = (UInt16(sw1) << 8) | UInt16(sw2)
            let success = statusWord == 0x9000
            
            print("SELECT 응답: SW=0x\(String(format: "%04X", statusWord))")
            if !data.isEmpty {
                print("응답 데이터: \(data.hexString)")
            }
            
            completion(success, data, nil)
        }
    }
    
    // 사용 예시: NDEF 애플리케이션 선택
    func selectNDEFApplication(_ tag: NFCISO7816Tag) {
        // NDEF Application AID: D2760000850101
        let ndefAID = Data([0xD2, 0x76, 0x00, 0x00, 0x85, 0x01, 0x01])
        
        selectApplication(tag, aid: ndefAID) { success, data, error in
            if success {
                print("NDEF 애플리케이션 선택 성공")
            } else {
                print("NDEF 애플리케이션 선택 실패")
            }
        }
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
