import CoreNFC
import UIKit

class NFCReader: NSObject, NFCNDEFReaderSessionDelegate {
    var ndefSession: NFCNDEFReaderSession?
    var onNDEFDetected: (([NFCNDEFMessage]) -> Void)?
    
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
        // NDEF 메시지 배열을 받음
        // 대부분의 태그는 하나의 메시지만 포함
        print("감지된 메시지 수: \(messages.count)")
        
        for message in messages {
            print("레코드 수: \(message.records.count)")
        }
        
        // 콜백으로 메시지 전달
        onNDEFDetected?(messages)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, 
                       didInvalidateWithError error: Error) { }
}
