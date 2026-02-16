import CoreNFC

// APDU (Application Protocol Data Unit) 구조
//
// Command APDU:
// +-----+-----+----+----+------+------+------+
// | CLA | INS | P1 | P2 | Lc   | Data | Le   |
// +-----+-----+----+----+------+------+------+
// | 1B  | 1B  | 1B | 1B | 0-3B | Lc B | 0-3B |
//
// Response APDU:
// +------+-----+-----+
// | Data | SW1 | SW2 |
// +------+-----+-----+

class ISO7816Reader {
    
    /// APDU 명령 생성
    func createAPDU(
        instructionClass: UInt8,     // CLA: 명령 클래스
        instructionCode: UInt8,       // INS: 명령 코드
        p1Parameter: UInt8,           // P1: 파라미터 1
        p2Parameter: UInt8,           // P2: 파라미터 2
        data: Data = Data(),          // 명령 데이터
        expectedResponseLength: Int = -1  // Le: 예상 응답 길이 (-1 = 생략)
    ) -> NFCISO7816APDU? {
        
        return NFCISO7816APDU(
            instructionClass: instructionClass,
            instructionCode: instructionCode,
            p1Parameter: p1Parameter,
            p2Parameter: p2Parameter,
            data: data,
            expectedResponseLength: expectedResponseLength
        )
    }
    
    // 주요 명령 코드
    struct APDUCommands {
        // SELECT 명령
        static let SELECT_INS: UInt8 = 0xA4
        
        // READ BINARY 명령
        static let READ_BINARY_INS: UInt8 = 0xB0
        
        // UPDATE BINARY 명령
        static let UPDATE_BINARY_INS: UInt8 = 0xD6
        
        // GET DATA 명령
        static let GET_DATA_INS: UInt8 = 0xCA
        
        // VERIFY 명령 (PIN 확인)
        static let VERIFY_INS: UInt8 = 0x20
        
        // INTERNAL AUTHENTICATE
        static let INTERNAL_AUTH_INS: UInt8 = 0x88
    }
}
