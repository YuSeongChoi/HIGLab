import Foundation
import CoreNFC

@Observable
final class NFCManager: NSObject {
    private var session: NFCNDEFReaderSession?
    
    private(set) var isAvailable = NFCNDEFReaderSession.readingAvailable
    private(set) var lastReadMessage: String?
    private(set) var isScanning = false
    
    var onRead: ((String) -> Void)?
    
    func startReading() {
        guard isAvailable else { return }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "NFC 태그를 iPhone에 가까이 대세요"
        session?.begin()
        isScanning = true
    }
    
    func write(_ text: String) {
        guard isAvailable else { return }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "쓸 NFC 태그를 가까이 대세요"
        session?.begin()
        isScanning = true
        
        // Write payload stored for delegate
        pendingWriteText = text
    }
    
    private var pendingWriteText: String?
}

extension NFCManager: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let record = messages.first?.records.first,
              let payload = String(data: record.payload, encoding: .utf8) else { return }
        
        DispatchQueue.main.async {
            self.lastReadMessage = payload
            self.onRead?(payload)
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard let tag = tags.first else { return }
        
        session.connect(to: tag) { error in
            if error != nil {
                session.invalidate(errorMessage: "연결 실패")
                return
            }
            
            tag.queryNDEFStatus { status, _, error in
                guard status == .readWrite, let text = self.pendingWriteText else {
                    // Read mode
                    tag.readNDEF { message, _ in
                        if let record = message?.records.first,
                           let payload = String(data: record.payload, encoding: .utf8) {
                            DispatchQueue.main.async {
                                self.lastReadMessage = payload
                            }
                        }
                        session.invalidate()
                    }
                    return
                }
                
                // Write mode
                let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: text, locale: Locale(identifier: "ko"))!
                let message = NFCNDEFMessage(records: [payload])
                
                tag.writeNDEF(message) { error in
                    if error != nil {
                        session.invalidate(errorMessage: "쓰기 실패")
                    } else {
                        session.alertMessage = "쓰기 완료!"
                        session.invalidate()
                    }
                    self.pendingWriteText = nil
                }
            }
        }
    }
}
