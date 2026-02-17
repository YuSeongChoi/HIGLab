// FileTransferService.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// 대용량 파일 전송 서비스: 청크 분할, 진행률, 재시도

import Foundation
import Observation
import CryptoKit

/// 파일 전송 서비스
/// 대용량 파일을 청크로 분할하여 전송하고 진행률을 추적합니다
@Observable
final class FileTransferService: @unchecked Sendable {
    
    // MARK: - 상태
    
    /// 현재 전송 중인 파일 목록
    private(set) var activeTransfers: [TransferFile] = []
    
    /// 완료된 전송 기록
    private(set) var completedTransfers: [TransferFile] = []
    
    /// 수신 대기 중인 파일 제안
    private(set) var pendingOffers: [TransferFile] = []
    
    /// 전송 오류
    private(set) var lastError: ConnectionError?
    
    // MARK: - 의존성
    
    private var wifiAwareManager: WiFiAwareManager?
    
    /// 임시 파일 저장 디렉토리
    private let tempDirectory: URL
    
    /// 수신 파일 저장 디렉토리
    private let receivedDirectory: URL
    
    /// 전송 큐
    private let transferQueue = DispatchQueue(label: "com.directshare.transfer", qos: .userInitiated)
    
    /// 진행 중인 청크 버퍼
    private var chunkBuffers: [UUID: [FileChunk]] = [:]
    
    /// 전송 진행률 콜백
    var onProgressUpdate: ((TransferFile) -> Void)?
    
    /// 전송 완료 콜백
    var onTransferComplete: ((TransferFile, Bool) -> Void)?
    
    /// 파일 수신 제안 콜백
    var onFileOfferReceived: ((TransferFile, Peer) -> Void)?
    
    // MARK: - 초기화
    
    init() {
        // 임시 디렉토리 설정
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        tempDirectory = cachesDir.appendingPathComponent("DirectShare/temp", isDirectory: true)
        receivedDirectory = cachesDir.appendingPathComponent("DirectShare/received", isDirectory: true)
        
        // 디렉토리 생성
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: receivedDirectory, withIntermediateDirectories: true)
    }
    
    /// Wi-Fi Aware 매니저 설정
    func setWiFiAwareManager(_ manager: WiFiAwareManager) {
        self.wifiAwareManager = manager
        
        // 메시지 수신 핸들러 등록
        manager.onMessageReceived = { [weak self] peer, message in
            self?.handleMessage(message, from: peer)
        }
    }
    
    // MARK: - 파일 전송
    
    /// 피어에게 파일 전송 시작
    func sendFile(_ file: TransferFile, to peer: Peer) async throws {
        guard peer.connectionState.isConnected else {
            throw ConnectionError.peerNotFound
        }
        
        guard let manager = wifiAwareManager else {
            throw ConnectionError.unknown("WiFiAwareManager not set")
        }
        
        var transferFile = file
        transferFile.status = .preparing
        transferFile.direction = .sending
        transferFile.startTime = Date()
        
        // 활성 전송에 추가
        await MainActor.run {
            activeTransfers.append(transferFile)
        }
        
        // 파일 체크섬 계산
        let checksum = try await calculateChecksum(for: file)
        
        // 파일 제안 메시지 전송
        let metadata = TransferMetadata(from: file, checksum: checksum)
        let offerPayload = FileOfferPayload(
            metadata: metadata,
            senderName: DeviceInfo.deviceName,
            totalFiles: 1,
            currentIndex: 0
        )
        
        let payloadData = try JSONEncoder().encode(offerPayload)
        let offerMessage = PeerMessage(type: .fileOffer, payload: payloadData)
        
        try await manager.send(offerMessage, to: peer)
        print("📤 파일 제안 전송: \(file.fileName)")
        
        // 수락 대기 (실제로는 메시지 핸들러에서 처리)
        // 여기서는 데모용으로 바로 전송 시작
        try await startFileTransfer(transferFile, to: peer)
    }
    
    /// 실제 파일 데이터 전송 시작
    private func startFileTransfer(_ file: TransferFile, to peer: Peer) async throws {
        guard let fileURL = file.localURL else {
            throw ConnectionError.transferFailed("파일 URL이 없습니다")
        }
        
        guard let manager = wifiAwareManager else {
            throw ConnectionError.unknown("WiFiAwareManager not set")
        }
        
        // 파일 상태 업데이트
        await updateTransferStatus(file.id, status: .transferring)
        
        // 파일 데이터 읽기
        let fileHandle = try FileHandle(forReadingFrom: fileURL)
        defer { try? fileHandle.close() }
        
        let totalSize = file.fileSize
        let chunkSize = AppConstants.chunkSize
        let totalChunks = Int(ceil(Double(totalSize) / Double(chunkSize)))
        
        var chunkIndex = 0
        var offset: Int64 = 0
        
        while offset < totalSize {
            // 청크 읽기
            try fileHandle.seek(toOffset: UInt64(offset))
            guard let chunkData = try fileHandle.read(upToCount: chunkSize) else {
                break
            }
            
            let isLast = offset + Int64(chunkData.count) >= totalSize
            
            // 청크 메시지 생성
            let chunk = FileChunk(
                fileId: file.id,
                chunkIndex: chunkIndex,
                totalChunks: totalChunks,
                data: chunkData,
                offset: offset,
                isLast: isLast
            )
            
            let chunkPayload = try JSONEncoder().encode(chunk)
            let chunkMessage = PeerMessage(type: .fileData, payload: chunkPayload)
            
            // 청크 전송
            try await manager.send(chunkMessage, to: peer)
            
            // 진행률 업데이트
            offset += Int64(chunkData.count)
            await updateTransferProgress(file.id, bytesTransferred: offset)
            
            chunkIndex += 1
            
            // 전송 속도 조절 (네트워크 혼잡 방지)
            try await Task.sleep(for: .milliseconds(10))
        }
        
        // 완료 메시지 전송
        let completeMessage = PeerMessage(type: .fileComplete, payload: file.id.uuidString.data(using: .utf8))
        try await manager.send(completeMessage, to: peer)
        
        // 상태 업데이트
        await updateTransferStatus(file.id, status: .completed)
        
        print("✅ 파일 전송 완료: \(file.fileName)")
    }
    
    /// 파일 수신 수락
    func acceptFileOffer(_ file: TransferFile, from peer: Peer) async throws {
        guard let manager = wifiAwareManager else {
            throw ConnectionError.unknown("WiFiAwareManager not set")
        }
        
        // 수신 준비
        var receivingFile = file
        receivingFile.status = .preparing
        receivingFile.direction = .receiving
        receivingFile.startTime = Date()
        
        await MainActor.run {
            pendingOffers.removeAll { $0.id == file.id }
            activeTransfers.append(receivingFile)
        }
        
        // 수신 버퍼 초기화
        chunkBuffers[file.id] = []
        
        // 수락 메시지 전송
        let acceptMessage = PeerMessage(type: .fileAccept, payload: file.id.uuidString.data(using: .utf8))
        try await manager.send(acceptMessage, to: peer)
        
        print("📥 파일 수신 수락: \(file.fileName)")
    }
    
    /// 파일 수신 거부
    func rejectFileOffer(_ file: TransferFile, from peer: Peer) async throws {
        guard let manager = wifiAwareManager else {
            throw ConnectionError.unknown("WiFiAwareManager not set")
        }
        
        await MainActor.run {
            pendingOffers.removeAll { $0.id == file.id }
        }
        
        // 거부 메시지 전송
        let rejectMessage = PeerMessage(type: .fileReject, payload: file.id.uuidString.data(using: .utf8))
        try await manager.send(rejectMessage, to: peer)
        
        print("❌ 파일 수신 거부: \(file.fileName)")
    }
    
    /// 전송 취소
    func cancelTransfer(_ file: TransferFile, peer: Peer? = nil) async throws {
        await updateTransferStatus(file.id, status: .cancelled)
        
        // 취소 메시지 전송
        if let peer = peer, let manager = wifiAwareManager {
            let cancelMessage = PeerMessage(type: .fileCancel, payload: file.id.uuidString.data(using: .utf8))
            try? await manager.send(cancelMessage, to: peer)
        }
        
        // 버퍼 정리
        chunkBuffers.removeValue(forKey: file.id)
        
        print("🚫 전송 취소: \(file.fileName)")
    }
    
    // MARK: - 메시지 처리
    
    /// 수신된 메시지 처리
    private func handleMessage(_ message: PeerMessage, from peer: Peer) {
        Task {
            do {
                switch message.type {
                case .fileOffer:
                    try await handleFileOffer(message, from: peer)
                case .fileAccept:
                    handleFileAccept(message, from: peer)
                case .fileReject:
                    handleFileReject(message, from: peer)
                case .fileData:
                    try await handleFileData(message, from: peer)
                case .fileComplete:
                    try await handleFileComplete(message, from: peer)
                case .fileCancel:
                    handleFileCancel(message, from: peer)
                default:
                    break
                }
            } catch {
                print("❌ 메시지 처리 오류: \(error)")
            }
        }
    }
    
    /// 파일 제안 처리
    private func handleFileOffer(_ message: PeerMessage, from peer: Peer) async throws {
        guard let payload = message.payload else { return }
        
        let offerPayload = try JSONDecoder().decode(FileOfferPayload.self, from: payload)
        let metadata = offerPayload.metadata
        
        // TransferFile 생성
        let file = TransferFile(
            id: metadata.fileId,
            fileName: metadata.fileName,
            fileSize: metadata.fileSize,
            mimeType: metadata.mimeType,
            status: .pending,
            direction: .receiving
        )
        
        await MainActor.run {
            pendingOffers.append(file)
        }
        
        onFileOfferReceived?(file, peer)
        print("📨 파일 제안 수신: \(file.fileName) from \(peer.deviceName)")
    }
    
    /// 파일 수락 처리
    private func handleFileAccept(_ message: PeerMessage, from peer: Peer) {
        guard let payload = message.payload,
              let fileIdString = String(data: payload, encoding: .utf8),
              let fileId = UUID(uuidString: fileIdString) else { return }
        
        Task {
            await updateTransferStatus(fileId, status: .transferring)
        }
        print("✅ 파일 수락됨: \(fileId)")
    }
    
    /// 파일 거부 처리
    private func handleFileReject(_ message: PeerMessage, from peer: Peer) {
        guard let payload = message.payload,
              let fileIdString = String(data: payload, encoding: .utf8),
              let fileId = UUID(uuidString: fileIdString) else { return }
        
        Task {
            await updateTransferStatus(fileId, status: .failed)
        }
        print("❌ 파일 거부됨: \(fileId)")
    }
    
    /// 파일 데이터 청크 처리
    private func handleFileData(_ message: PeerMessage, from peer: Peer) async throws {
        guard let payload = message.payload else { return }
        
        let chunk = try JSONDecoder().decode(FileChunk.self, from: payload)
        
        // 버퍼에 청크 추가
        var chunks = chunkBuffers[chunk.fileId] ?? []
        chunks.append(chunk)
        chunkBuffers[chunk.fileId] = chunks
        
        // 진행률 업데이트
        let bytesReceived = chunks.reduce(0) { $0 + Int64($1.data.count) }
        await updateTransferProgress(chunk.fileId, bytesTransferred: bytesReceived)
        
        // 상태를 전송중으로 변경
        await updateTransferStatus(chunk.fileId, status: .transferring)
    }
    
    /// 파일 전송 완료 처리
    private func handleFileComplete(_ message: PeerMessage, from peer: Peer) async throws {
        guard let payload = message.payload,
              let fileIdString = String(data: payload, encoding: .utf8),
              let fileId = UUID(uuidString: fileIdString) else { return }
        
        // 청크 조립
        guard let chunks = chunkBuffers[fileId] else {
            print("❌ 청크를 찾을 수 없음: \(fileId)")
            return
        }
        
        // 청크 정렬 및 데이터 조립
        let sortedChunks = chunks.sorted { $0.chunkIndex < $1.chunkIndex }
        var fileData = Data()
        for chunk in sortedChunks {
            fileData.append(chunk.data)
        }
        
        // 파일 저장
        if let transfer = activeTransfers.first(where: { $0.id == fileId }) {
            let fileURL = receivedDirectory.appendingPathComponent(transfer.fileName)
            try fileData.write(to: fileURL)
            print("💾 파일 저장됨: \(fileURL.path)")
        }
        
        // 정리
        chunkBuffers.removeValue(forKey: fileId)
        await updateTransferStatus(fileId, status: .completed)
        
        print("✅ 파일 수신 완료: \(fileId)")
    }
    
    /// 파일 전송 취소 처리
    private func handleFileCancel(_ message: PeerMessage, from peer: Peer) {
        guard let payload = message.payload,
              let fileIdString = String(data: payload, encoding: .utf8),
              let fileId = UUID(uuidString: fileIdString) else { return }
        
        chunkBuffers.removeValue(forKey: fileId)
        
        Task {
            await updateTransferStatus(fileId, status: .cancelled)
        }
        print("🚫 전송 취소 수신: \(fileId)")
    }
    
    // MARK: - 상태 업데이트
    
    /// 전송 상태 업데이트
    @MainActor
    private func updateTransferStatus(_ fileId: UUID, status: TransferStatus) {
        if let index = activeTransfers.firstIndex(where: { $0.id == fileId }) {
            activeTransfers[index].status = status
            
            if status == .completed || status == .failed || status == .cancelled {
                activeTransfers[index].endTime = Date()
                let completed = activeTransfers.remove(at: index)
                completedTransfers.append(completed)
                onTransferComplete?(completed, status == .completed)
            }
            
            onProgressUpdate?(activeTransfers[index])
        }
    }
    
    /// 전송 진행률 업데이트
    @MainActor
    private func updateTransferProgress(_ fileId: UUID, bytesTransferred: Int64) {
        if let index = activeTransfers.firstIndex(where: { $0.id == fileId }) {
            activeTransfers[index].bytesTransferred = bytesTransferred
            onProgressUpdate?(activeTransfers[index])
        }
    }
    
    // MARK: - 유틸리티
    
    /// 파일 체크섬 계산 (SHA256)
    private func calculateChecksum(for file: TransferFile) async throws -> String {
        guard let url = file.localURL else {
            throw ConnectionError.transferFailed("파일 URL이 없습니다")
        }
        
        let fileHandle = try FileHandle(forReadingFrom: url)
        defer { try? fileHandle.close() }
        
        var hasher = SHA256()
        
        while let chunk = try fileHandle.read(upToCount: 1024 * 1024) {
            if chunk.isEmpty { break }
            hasher.update(data: chunk)
        }
        
        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    /// 임시 파일 정리
    func cleanupTempFiles() {
        try? FileManager.default.removeItem(at: tempDirectory)
        try? FileManager.default.createDirectory(at: tempDirectory, withIntermediateDirectories: true)
    }
    
    /// 전송 기록 초기화
    func clearHistory() {
        completedTransfers.removeAll()
    }
}
