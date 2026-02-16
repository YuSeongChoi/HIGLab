import CoreNFC
import Foundation

class URLTextParser {
    
    func parseURLRecord(_ record: NFCNDEFPayload) -> URL? {
        // Well-Known URI 타입 확인
        guard record.typeNameFormat == .nfcWellKnown,
              String(data: record.type, encoding: .utf8) == "U" else {
            return nil
        }
        
        // 편의 메서드로 URL 추출
        // 자동으로 프리픽스 코드를 해석함
        return record.wellKnownTypeURIPayload()
    }
    
    // 사용 예시
    func processURLRecord(_ record: NFCNDEFPayload) {
        if let url = parseURLRecord(record) {
            print("URL: \(url.absoluteString)")
            print("Scheme: \(url.scheme ?? "none")")
            print("Host: \(url.host ?? "none")")
        }
    }
}
