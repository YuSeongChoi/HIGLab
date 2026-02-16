import CoreNFC

class ISO7816Reader {
    
    /// READ BINARY 명령으로 데이터 읽기
    func readBinary(
        _ tag: NFCISO7816Tag,
        offset: UInt16,
        length: UInt8,
        completion: @escaping (Data?, Error?) -> Void
    ) {
        // READ BINARY 명령
        // CLA: 0x00
        // INS: 0xB0
        // P1: 오프셋 상위 바이트
        // P2: 오프셋 하위 바이트
        // Le: 읽을 바이트 수
        guard let apdu = NFCISO7816APDU(
            instructionClass: 0x00,
            instructionCode: 0xB0,
            p1Parameter: UInt8((offset >> 8) & 0xFF),
            p2Parameter: UInt8(offset & 0xFF),
            data: Data(),
            expectedResponseLength: Int(length)
        ) else {
            completion(nil, nil)
            return
        }
        
        tag.sendCommand(apdu: apdu) { data, sw1, sw2, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            let statusWord = (UInt16(sw1) << 8) | UInt16(sw2)
            
            switch statusWord {
            case 0x9000:
                // 성공
                completion(data, nil)
                
            case 0x6282:
                // 파일 끝에 도달 (데이터는 유효)
                completion(data, nil)
                
            case 0x6A82:
                // 파일을 찾을 수 없음
                print("파일을 찾을 수 없습니다.")
                completion(nil, nil)
                
            default:
                print("READ BINARY 실패: 0x\(String(format: "%04X", statusWord))")
                completion(nil, nil)
            }
        }
    }
    
    /// 파일 전체 읽기
    func readEntireFile(
        _ tag: NFCISO7816Tag,
        maxLength: Int = 256,
        completion: @escaping (Data?) -> Void
    ) {
        var allData = Data()
        var offset: UInt16 = 0
        
        func readNextChunk() {
            let remaining = maxLength - allData.count
            let chunkSize = min(remaining, 255)
            
            guard chunkSize > 0 else {
                completion(allData)
                return
            }
            
            readBinary(tag, offset: offset, length: UInt8(chunkSize)) { data, error in
                if let data = data, !data.isEmpty {
                    allData.append(data)
                    offset += UInt16(data.count)
                    
                    if data.count < chunkSize {
                        // 파일 끝
                        completion(allData)
                    } else {
                        readNextChunk()
                    }
                } else {
                    completion(allData.isEmpty ? nil : allData)
                }
            }
        }
        
        readNextChunk()
    }
}
