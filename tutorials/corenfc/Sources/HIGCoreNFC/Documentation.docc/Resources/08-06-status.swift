import CoreNFC

// ISO 7816 상태 코드 (SW1-SW2)
struct ISO7816StatusCode {
    let sw1: UInt8
    let sw2: UInt8
    
    var value: UInt16 {
        (UInt16(sw1) << 8) | UInt16(sw2)
    }
    
    var isSuccess: Bool {
        value == 0x9000
    }
    
    var description: String {
        switch value {
        // 성공
        case 0x9000:
            return "성공"
            
        // 경고 (처리됨)
        case 0x6200:
            return "경고: 상태 변경 없음"
        case 0x6281:
            return "경고: 반환된 데이터가 손상되었을 수 있음"
        case 0x6282:
            return "경고: 파일 끝에 도달"
        case 0x6283:
            return "경고: 선택된 파일이 유효하지 않음"
            
        // 실행 오류
        case 0x6300:
            return "인증 실패"
        case 0x63C0...0x63CF:
            let remaining = value & 0x0F
            return "인증 실패 (남은 시도: \(remaining)회)"
            
        // 체크 오류
        case 0x6400:
            return "실행 오류: 상태 변경 없음"
        case 0x6581:
            return "실행 오류: 메모리 오류"
            
        // 잘못된 길이
        case 0x6700:
            return "잘못된 길이"
            
        // 기능 미지원
        case 0x6800:
            return "CLA의 기능이 지원되지 않음"
        case 0x6881:
            return "논리 채널 미지원"
        case 0x6882:
            return "보안 메시징 미지원"
            
        // 명령 불허
        case 0x6900:
            return "명령 불허"
        case 0x6982:
            return "보안 상태 불충족"
        case 0x6983:
            return "인증 방법 차단됨"
        case 0x6984:
            return "참조 데이터 무효"
        case 0x6985:
            return "사용 조건 불충족"
        case 0x6986:
            return "명령 순서 오류"
            
        // 잘못된 파라미터
        case 0x6A00:
            return "P1-P2 오류"
        case 0x6A80:
            return "데이터 필드 파라미터 오류"
        case 0x6A81:
            return "기능 미지원"
        case 0x6A82:
            return "파일/앱을 찾을 수 없음"
        case 0x6A83:
            return "레코드를 찾을 수 없음"
        case 0x6A84:
            return "파일에 메모리 부족"
        case 0x6A86:
            return "P1-P2 오류"
        case 0x6A88:
            return "참조 데이터를 찾을 수 없음"
            
        // 잘못된 명령
        case 0x6D00:
            return "알 수 없는 INS"
        case 0x6E00:
            return "알 수 없는 CLA"
        case 0x6F00:
            return "알 수 없는 오류"
            
        default:
            return "알 수 없는 상태: 0x\(String(format: "%04X", value))"
        }
    }
}

// 사용 예시
func handleResponse(sw1: UInt8, sw2: UInt8) {
    let status = ISO7816StatusCode(sw1: sw1, sw2: sw2)
    print("상태: \(status.description)")
    
    if status.isSuccess {
        print("명령 성공!")
    } else {
        print("명령 실패: 0x\(String(format: "%04X", status.value))")
    }
}
