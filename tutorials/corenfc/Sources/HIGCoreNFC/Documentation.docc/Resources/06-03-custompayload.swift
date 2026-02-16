import CoreNFC
import Foundation

class NFCWriter {
    
    /// 커스텀 페이로드 직접 생성
    func createCustomPayload(
        format: NFCTypeNameFormat,
        type: String,
        identifier: Data = Data(),
        payload: Data
    ) -> NFCNDEFPayload {
        return NFCNDEFPayload(
            format: format,
            type: type.data(using: .utf8) ?? Data(),
            identifier: identifier,
            payload: payload
        )
    }
    
    // External 타입 (앱 고유 데이터)
    func createExternalRecord(domain: String, type: String, data: Data) -> NFCNDEFPayload {
        let typeString = "\(domain):\(type)"
        return NFCNDEFPayload(
            format: .nfcExternal,
            type: typeString.data(using: .utf8) ?? Data(),
            identifier: Data(),
            payload: data
        )
    }
    
    // Media 타입 (MIME 데이터)
    func createMediaRecord(mimeType: String, data: Data) -> NFCNDEFPayload {
        return NFCNDEFPayload(
            format: .media,
            type: mimeType.data(using: .utf8) ?? Data(),
            identifier: Data(),
            payload: data
        )
    }
    
    // 사용 예시
    func createCustomRecords() {
        // JSON 데이터
        let json = ["id": "12345", "name": "Product"]
        if let jsonData = try? JSONSerialization.data(withJSONObject: json) {
            let mediaPayload = createMediaRecord(
                mimeType: "application/json",
                data: jsonData
            )
            print("JSON 레코드 생성: \(mediaPayload.payload.count) bytes")
        }
        
        // 앱 고유 데이터
        let appData = "custom-data".data(using: .utf8)!
        let externalPayload = createExternalRecord(
            domain: "com.example.myapp",
            type: "config",
            data: appData
        )
        print("External 레코드 생성 완료")
    }
}
