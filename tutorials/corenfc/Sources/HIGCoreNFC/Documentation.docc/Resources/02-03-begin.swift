import CoreNFC
import UIKit

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var ndefSession: NFCNDEFReaderSession?
    
    func startScanning() {
        // NFC 지원 여부 확인
        guard NFCNDEFReaderSession.readingAvailable else {
            print("이 기기는 NFC를 지원하지 않습니다.")
            return
        }
        
        // 세션 생성
        ndefSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        
        // 스캔 UI에 표시될 메시지 설정
        ndefSession?.alertMessage = "NFC 태그를 iPhone 상단에 가까이 대세요."
        
        // 스캔 시작!
        ndefSession?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didDetectNDEFs messages: [NFCNDEFMessage]) { }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) { }
}
