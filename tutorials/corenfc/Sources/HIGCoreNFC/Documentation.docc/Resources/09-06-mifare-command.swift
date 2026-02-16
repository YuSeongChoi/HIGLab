import CoreNFC

class MIFAREReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    /// MIFARE 네이티브 명령 전송
    func sendMIFARECommand(
        _ tag: NFCMiFareTag,
        command: Data,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        tag.sendMiFareCommand(commandPacket: command) { responseData, error in
            if let error = error {
                print("MIFARE 명령 실패: \(error)")
                completion(nil, error)
                return
            }
            
            print("응답: \(responseData.hexString)")
            completion(responseData, nil)
        }
    }
    
    // MIFARE Ultralight: 버전 정보 읽기
    func getVersion(_ tag: NFCMiFareTag, 
                     completion: @escaping (MIFAREVersion?) -> Void) {
        let command = Data([0x60])  // GET_VERSION
        
        sendMIFARECommand(tag, command: command) { data, error in
            guard let data = data, data.count >= 8 else {
                completion(nil)
                return
            }
            
            let version = MIFAREVersion(
                vendorID: data[1],
                productType: data[2],
                productSubType: data[3],
                majorVersion: data[4],
                minorVersion: data[5],
                storageSize: data[6],
                protocolType: data[7]
            )
            
            completion(version)
        }
    }
    
    // MIFARE DESFire: ISO 7816 명령도 지원
    func sendDESFireCommand(
        _ tag: NFCMiFareTag,
        apdu: NFCISO7816APDU,
        completion: @escaping (Data?, UInt8, UInt8, Error?) -> Void
    ) {
        // DESFire는 ISO 7816 명령도 지원
        tag.sendMiFareISO7816Command(apdu) { data, sw1, sw2, error in
            completion(data, sw1, sw2, error)
        }
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        guard case let .miFare(tag) = tags.first else { return }
        
        session.connect(to: tags.first!) { error in
            if error == nil {
                // 버전 정보 읽기
                self.getVersion(tag) { version in
                    if let v = version {
                        print("MIFARE 버전: \(v)")
                    }
                    session.invalidate()
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

struct MIFAREVersion: CustomStringConvertible {
    let vendorID: UInt8
    let productType: UInt8
    let productSubType: UInt8
    let majorVersion: UInt8
    let minorVersion: UInt8
    let storageSize: UInt8
    let protocolType: UInt8
    
    var description: String {
        """
        Vendor: 0x\(String(format: "%02X", vendorID))
        Product: \(productType).\(productSubType)
        Version: \(majorVersion).\(minorVersion)
        Storage: \(storageSize)
        Protocol: \(protocolType)
        """
    }
}

extension Data {
    var hexString: String {
        map { String(format: "%02X", $0) }.joined()
    }
}
