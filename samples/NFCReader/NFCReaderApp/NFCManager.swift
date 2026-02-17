import Foundation
import CoreNFC
import Combine

// MARK: - NFC 매니저

/// Core NFC를 사용하여 NFC 태그를 읽고 쓰는 기능을 관리하는 클래스
@MainActor
class NFCManager: NSObject, ObservableObject {
    // MARK: - Published 프로퍼티
    
    /// 스캔 상태
    @Published private(set) var scanState: ScanState = .idle
    
    /// 마지막으로 스캔된 메시지
    @Published private(set) var lastScannedMessage: NDEFMessage?
    
    /// 오류 메시지
    @Published var errorMessage: String?
    
    /// NFC 지원 여부
    @Published private(set) var isNFCSupported: Bool = false
    
    // MARK: - Private 프로퍼티
    
    /// NDEF 리더 세션
    private var readerSession: NFCNDEFReaderSession?
    
    /// 쓰기 모드 여부
    private var isWriteMode: Bool = false
    
    /// 쓸 레코드
    private var recordsToWrite: [NDEFRecord]?
    
    /// 스캔 완료 콜백
    private var scanCompletion: ((Result<NDEFMessage, NFCError>) -> Void)?
    
    // MARK: - 스캔 상태 열거형
    
    enum ScanState: Equatable {
        case idle           // 대기 중
        case scanning       // 스캔 중
        case writing        // 쓰기 중
        case success        // 성공
        case error(String)  // 오류
        
        var isActive: Bool {
            switch self {
            case .scanning, .writing:
                return true
            default:
                return false
            }
        }
    }
    
    // MARK: - NFC 오류 열거형
    
    enum NFCError: LocalizedError {
        case notSupported
        case sessionInvalidated
        case tagNotFound
        case tagNotWritable
        case connectionFailed
        case writeFailed(String)
        case readFailed(String)
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .notSupported:
                return "이 기기에서는 NFC를 지원하지 않습니다"
            case .sessionInvalidated:
                return "NFC 세션이 종료되었습니다"
            case .tagNotFound:
                return "NFC 태그를 찾을 수 없습니다"
            case .tagNotWritable:
                return "이 태그는 쓰기가 불가능합니다"
            case .connectionFailed:
                return "태그 연결에 실패했습니다"
            case .writeFailed(let reason):
                return "태그 쓰기 실패: \(reason)"
            case .readFailed(let reason):
                return "태그 읽기 실패: \(reason)"
            case .unknown:
                return "알 수 없는 오류가 발생했습니다"
            }
        }
    }
    
    // MARK: - 초기화
    
    override init() {
        super.init()
        checkNFCSupport()
    }
    
    /// NFC 지원 여부 확인
    private func checkNFCSupport() {
        isNFCSupported = NFCNDEFReaderSession.readingAvailable
    }
    
    // MARK: - 태그 읽기
    
    /// NFC 태그 스캔 시작
    func startScanning() {
        guard isNFCSupported else {
            errorMessage = NFCError.notSupported.localizedDescription
            scanState = .error(NFCError.notSupported.localizedDescription)
            return
        }
        
        // 기존 세션 정리
        readerSession?.invalidate()
        
        isWriteMode = false
        recordsToWrite = nil
        scanState = .scanning
        
        // 새 리더 세션 생성
        readerSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: true
        )
        
        readerSession?.alertMessage = AppConstants.Messages.scanReady
        readerSession?.begin()
    }
    
    /// 스캔 및 콜백 반환
    func scan() async throws -> NDEFMessage {
        return try await withCheckedThrowingContinuation { continuation in
            scanCompletion = { result in
                switch result {
                case .success(let message):
                    continuation.resume(returning: message)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
            startScanning()
        }
    }
    
    // MARK: - 태그 쓰기
    
    /// NFC 태그에 데이터 쓰기 시작
    func startWriting(records: [NDEFRecord]) {
        guard isNFCSupported else {
            errorMessage = NFCError.notSupported.localizedDescription
            scanState = .error(NFCError.notSupported.localizedDescription)
            return
        }
        
        // 기존 세션 정리
        readerSession?.invalidate()
        
        isWriteMode = true
        recordsToWrite = records
        scanState = .writing
        
        // 새 리더 세션 생성 (쓰기용)
        readerSession = NFCNDEFReaderSession(
            delegate: self,
            queue: nil,
            invalidateAfterFirstRead: false  // 쓰기 후 invalidate
        )
        
        readerSession?.alertMessage = AppConstants.Messages.writeReady
        readerSession?.begin()
    }
    
    /// URL 쓰기 편의 메서드
    func writeURL(_ url: String) {
        let records = NDEFMessageBuilder.websiteMessage(url: url)
        startWriting(records: records)
    }
    
    /// 텍스트 쓰기 편의 메서드
    func writeText(_ text: String) {
        let records = NDEFMessageBuilder.textMessage(text)
        startWriting(records: records)
    }
    
    /// 연락처 쓰기 편의 메서드
    func writeContact(name: String, phone: String?, email: String?, organization: String?) {
        let records = NDEFMessageBuilder.businessCardMessage(
            name: name,
            phone: phone,
            email: email,
            organization: organization
        )
        startWriting(records: records)
    }
    
    // MARK: - 세션 제어
    
    /// 스캔 세션 중지
    func stopScanning() {
        readerSession?.invalidate()
        readerSession = nil
        scanState = .idle
    }
    
    /// 상태 초기화
    func resetState() {
        scanState = .idle
        errorMessage = nil
    }
}

// MARK: - NFCNDEFReaderSessionDelegate

extension NFCManager: NFCNDEFReaderSessionDelegate {
    /// 세션 시작됨
    nonisolated func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        Task { @MainActor in
            print("NFC 세션 활성화됨")
        }
    }
    
    /// NDEF 메시지 감지됨
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        Task { @MainActor in
            handleDetectedMessages(messages, session: session)
        }
    }
    
    /// 태그 감지됨 (iOS 13+)
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        Task { @MainActor in
            await handleDetectedTags(tags, session: session)
        }
    }
    
    /// 세션 무효화됨
    nonisolated func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Task { @MainActor in
            handleSessionInvalidation(error: error)
        }
    }
    
    // MARK: - 메시지 처리
    
    /// 감지된 NDEF 메시지 처리
    private func handleDetectedMessages(_ messages: [NFCNDEFMessage], session: NFCNDEFReaderSession) {
        guard let nfcMessage = messages.first else {
            scanState = .error(NFCError.tagNotFound.localizedDescription)
            return
        }
        
        let parsedMessage = parseNFCMessage(nfcMessage)
        lastScannedMessage = parsedMessage
        scanState = .success
        
        scanCompletion?(.success(parsedMessage))
        scanCompletion = nil
    }
    
    /// 감지된 태그 처리
    private func handleDetectedTags(_ tags: [NFCNDEFTag], session: NFCNDEFReaderSession) async {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: NFCError.tagNotFound.localizedDescription)
            return
        }
        
        do {
            // 태그 연결
            try await session.connect(to: tag)
            
            // 태그 상태 조회
            let (status, capacity) = try await tag.queryNDEFStatus()
            
            if isWriteMode {
                // 쓰기 모드
                await handleWriteMode(tag: tag, status: status, capacity: capacity, session: session)
            } else {
                // 읽기 모드
                await handleReadMode(tag: tag, status: status, capacity: capacity, session: session)
            }
            
        } catch {
            session.invalidate(errorMessage: NFCError.connectionFailed.localizedDescription)
            scanState = .error(NFCError.connectionFailed.localizedDescription)
        }
    }
    
    /// 읽기 모드 처리
    private func handleReadMode(
        tag: NFCNDEFTag,
        status: NFCNDEFStatus,
        capacity: Int,
        session: NFCNDEFReaderSession
    ) async {
        do {
            let nfcMessage = try await tag.readNDEF()
            
            var parsedMessage = parseNFCMessage(nfcMessage)
            // 태그 정보 추가
            parsedMessage = NDEFMessage(
                id: parsedMessage.id,
                records: parsedMessage.records,
                tagType: identifyTagType(tag),
                tagIdentifier: getTagIdentifier(tag),
                isWritable: status == .readWrite,
                capacity: capacity,
                usedSize: calculateMessageSize(nfcMessage)
            )
            
            lastScannedMessage = parsedMessage
            scanState = .success
            
            session.alertMessage = AppConstants.Messages.success
            session.invalidate()
            
            scanCompletion?(.success(parsedMessage))
            scanCompletion = nil
            
        } catch {
            let errorString = NFCError.readFailed(error.localizedDescription).localizedDescription
            session.invalidate(errorMessage: errorString)
            scanState = .error(errorString)
            
            scanCompletion?(.failure(.readFailed(error.localizedDescription)))
            scanCompletion = nil
        }
    }
    
    /// 쓰기 모드 처리
    private func handleWriteMode(
        tag: NFCNDEFTag,
        status: NFCNDEFStatus,
        capacity: Int,
        session: NFCNDEFReaderSession
    ) async {
        // 쓰기 가능 여부 확인
        guard status == .readWrite else {
            let errorString = NFCError.tagNotWritable.localizedDescription
            session.invalidate(errorMessage: errorString)
            scanState = .error(errorString)
            return
        }
        
        guard let records = recordsToWrite else {
            session.invalidate(errorMessage: "쓸 데이터가 없습니다")
            return
        }
        
        // NDEF 메시지 생성
        let nfcRecords = records.map { record -> NFCNDEFPayload in
            NFCNDEFPayload(
                format: NFCTypeNameFormat(rawValue: record.tnf.rawValue) ?? .unknown,
                type: record.type,
                identifier: record.identifier,
                payload: record.payload
            )
        }
        
        let nfcMessage = NFCNDEFMessage(records: nfcRecords)
        
        // 용량 확인
        let messageSize = calculateMessageSize(nfcMessage)
        guard messageSize <= capacity else {
            let errorString = "메시지 크기(\(messageSize)B)가 태그 용량(\(capacity)B)을 초과합니다"
            session.invalidate(errorMessage: errorString)
            scanState = .error(errorString)
            return
        }
        
        do {
            // 태그에 쓰기
            try await tag.writeNDEF(nfcMessage)
            
            session.alertMessage = AppConstants.Messages.success
            session.invalidate()
            scanState = .success
            
        } catch {
            let errorString = NFCError.writeFailed(error.localizedDescription).localizedDescription
            session.invalidate(errorMessage: errorString)
            scanState = .error(errorString)
        }
    }
    
    /// 세션 무효화 처리
    private func handleSessionInvalidation(error: Error) {
        readerSession = nil
        
        let nfcError = error as? NFCReaderError
        
        // 사용자가 취소한 경우는 오류로 처리하지 않음
        if nfcError?.code == .readerSessionInvalidationErrorUserCanceled {
            scanState = .idle
            return
        }
        
        // 첫 번째 읽기 후 자동 종료는 오류가 아님
        if nfcError?.code == .readerSessionInvalidationErrorFirstNDEFTagRead {
            // 이미 처리됨
            return
        }
        
        // 기타 오류
        if scanState.isActive {
            errorMessage = error.localizedDescription
            scanState = .error(error.localizedDescription)
            
            scanCompletion?(.failure(.sessionInvalidated))
            scanCompletion = nil
        }
    }
    
    // MARK: - 유틸리티 메서드
    
    /// NFC 메시지 파싱
    private func parseNFCMessage(_ nfcMessage: NFCNDEFMessage) -> NDEFMessage {
        let records = nfcMessage.records.map { nfcRecord -> NDEFRecord in
            NDEFRecord(
                tnf: TNFType(rawValue: nfcRecord.typeNameFormat.rawValue) ?? .unknown,
                type: nfcRecord.type,
                identifier: nfcRecord.identifier,
                payload: nfcRecord.payload
            )
        }
        
        return NDEFMessage(records: records)
    }
    
    /// 태그 타입 식별
    private func identifyTagType(_ tag: NFCNDEFTag) -> NFCTagType {
        // 태그 타입 식별 로직
        // 실제 구현에서는 태그의 특성을 더 자세히 분석
        return .type2  // 기본값
    }
    
    /// 태그 식별자 가져오기
    private func getTagIdentifier(_ tag: NFCNDEFTag) -> Data? {
        // 태그 식별자 추출
        // ISO7816 태그의 경우 UID 사용
        return nil
    }
    
    /// 메시지 크기 계산
    private func calculateMessageSize(_ message: NFCNDEFMessage) -> Int {
        var size = 0
        for record in message.records {
            size += record.payload.count
            size += record.type.count
            size += record.identifier.count
            size += 3  // 헤더 바이트
        }
        return size
    }
}
