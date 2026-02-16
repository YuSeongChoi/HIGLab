import CoreNFC
import UIKit

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var ndefSession: NFCNDEFReaderSession?
    
    func createSession() {
        // NFCNDEFReaderSession 생성
        ndefSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,  // nil이면 메인 큐 사용
            invalidateAfterFirstRead: true  // 첫 태그 읽기 후 세션 종료
        )
        
        // invalidateAfterFirstRead 옵션:
        // - true: 단일 태그 읽기 (간단한 사용)
        // - false: 여러 태그 연속 읽기 또는 쓰기 작업
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) { }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) { }
}
