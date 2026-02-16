import CoreNFC
import UIKit

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var ndefSession: NFCNDEFReaderSession?
    var onNDEFDetected: (([NFCNDEFMessage]) -> Void)?
    var onError: ((Error) -> Void)?
    
    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else { return }
        
        ndefSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        ndefSession?.alertMessage = "NFC 태그를 iPhone 상단에 가까이 대세요."
        ndefSession?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) {
        onNDEFDetected?(messages)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) {
        // 에러 타입 확인
        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled:
                // 사용자가 취소함 - 정상 종료
                print("사용자가 스캔을 취소했습니다.")
                
            case .readerSessionInvalidationErrorFirstNDEFTagRead:
                // 첫 태그 읽기 후 정상 종료
                print("태그 읽기 완료")
                
            case .readerSessionInvalidationErrorSessionTimeout:
                print("세션 시간 초과")
                
            default:
                print("NFC 에러: \(nfcError.localizedDescription)")
                onError?(error)
            }
        }
        
        ndefSession = nil
    }
}
