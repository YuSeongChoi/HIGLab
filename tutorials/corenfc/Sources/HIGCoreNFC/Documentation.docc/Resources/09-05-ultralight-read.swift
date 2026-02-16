import CoreNFC

class MIFAREReader: NSObject, NFCTagReaderSessionDelegate {
    var tagSession: NFCTagReaderSession?
    
    // MIFARE Ultralight 명령
    struct UltralightCommands {
        static let READ: UInt8 = 0x30       // 4페이지 읽기
        static let WRITE: UInt8 = 0xA2      // 1페이지 쓰기
        static let GET_VERSION: UInt8 = 0x60
        static let FAST_READ: UInt8 = 0x3A  // 연속 읽기
    }
    
    func readUltralightPages(_ tag: NFCMiFareTag, 
                              session: NFCTagReaderSession) {
        guard tag.mifareFamily == .ultralight else {
            session.invalidate(errorMessage: "Ultralight 태그가 아닙니다.")
            return
        }
        
        // MIFARE Ultralight 구조
        // - 페이지 0-1: UID
        // - 페이지 2: Lock bytes
        // - 페이지 3: OTP (One-Time Programmable)
        // - 페이지 4+: 사용자 데이터
        
        readPage(tag, pageNumber: 4) { data, error in
            if let data = data {
                print("Page 4 데이터: \(data.hexString)")
                
                // NDEF 메시지가 있는 경우
                if data.count >= 4 && data[0] == 0x03 {
                    let ndefLength = data[1]
                    print("NDEF 메시지 길이: \(ndefLength) bytes")
                }
            }
            
            session.alertMessage = "읽기 완료!"
            session.invalidate()
        }
    }
    
    private func readPage(
        _ tag: NFCMiFareTag,
        pageNumber: UInt8,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        // READ 명령: 0x30 + 페이지 번호
        // 4페이지(16바이트) 반환
        let command = Data([UltralightCommands.READ, pageNumber])
        
        tag.sendMiFareCommand(commandPacket: command) { data, error in
            completion(data, error)
        }
    }
    
    // 모든 페이지 읽기
    func readAllPages(_ tag: NFCMiFareTag, 
                       completion: @escaping ([Data]) -> Void) {
        var pages: [Data] = []
        
        func readNextPage(index: UInt8) {
            guard index < 20 else {  // Ultralight: 최대 20페이지
                completion(pages)
                return
            }
            
            readPage(tag, pageNumber: index) { data, error in
                if let data = data {
                    // 4페이지씩 반환되므로 첫 4바이트만 사용
                    pages.append(data.prefix(4))
                    readNextPage(index: index + 1)
                } else {
                    completion(pages)
                }
            }
        }
        
        readNextPage(index: 0)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, 
                          didDetect tags: [NFCTag]) {
        guard case let .miFare(tag) = tags.first else { return }
        
        session.connect(to: tags.first!) { error in
            if error == nil {
                self.readUltralightPages(tag, session: session)
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
