import CoreNFC
import UIKit

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var ndefSession: NFCNDEFReaderSession?
    var onNDEFDetected: (([NFCNDEFMessage]) -> Void)?
    var onError: ((Error) -> Void)?
    var onSessionActive: (() -> Void)?
    
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
    
    func stopScanning() {
        ndefSession?.invalidate()
        ndefSession = nil
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // 세션이 활성화되어 태그 스캔 준비 완료
        print("NFC 세션 활성화됨 - 태그를 스캔하세요")
        onSessionActive?()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) {
        onNDEFDetected?(messages)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) {
        if let nfcError = error as? NFCReaderError {
            switch nfcError.code {
            case .readerSessionInvalidationErrorUserCanceled,
                 .readerSessionInvalidationErrorFirstNDEFTagRead:
                break
            default:
                onError?(error)
            }
        }
        ndefSession = nil
    }
}
