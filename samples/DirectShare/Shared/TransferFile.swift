// TransferFile.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// 전송할 파일의 메타데이터 및 상태 모델

import Foundation
import UniformTypeIdentifiers

/// 파일 전송 상태
enum TransferStatus: String, Codable, Sendable {
    case pending = "대기중"
    case preparing = "준비중"
    case transferring = "전송중"
    case completed = "완료"
    case failed = "실패"
    case cancelled = "취소됨"
}

/// 전송 방향
enum TransferDirection: String, Codable, Sendable {
    case sending = "송신"
    case receiving = "수신"
}

/// 전송할 파일 정보
struct TransferFile: Identifiable, Sendable {
    let id: UUID
    let fileName: String
    let fileSize: Int64
    let mimeType: String
    let localURL: URL?
    
    // 전송 상태
    var status: TransferStatus
    var direction: TransferDirection
    var bytesTransferred: Int64
    var startTime: Date?
    var endTime: Date?
    
    /// 전송 진행률 (0.0 ~ 1.0)
    var progress: Double {
        guard fileSize > 0 else { return 0 }
        return Double(bytesTransferred) / Double(fileSize)
    }
    
    /// 전송 속도 (bytes per second)
    var transferSpeed: Double {
        guard let start = startTime else { return 0 }
        let elapsed = Date().timeIntervalSince(start)
        guard elapsed > 0 else { return 0 }
        return Double(bytesTransferred) / elapsed
    }
    
    /// 예상 남은 시간 (초)
    var estimatedTimeRemaining: TimeInterval? {
        guard transferSpeed > 0 else { return nil }
        let remaining = fileSize - bytesTransferred
        return Double(remaining) / transferSpeed
    }
    
    /// 파일 크기를 읽기 쉬운 형식으로 변환
    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file)
    }
    
    /// 전송된 크기를 읽기 쉬운 형식으로 변환
    var formattedTransferred: String {
        ByteCountFormatter.string(fromByteCount: bytesTransferred, countStyle: .file)
    }
    
    /// 전송 속도를 읽기 쉬운 형식으로 변환
    var formattedSpeed: String {
        let speedPerSec = Int64(transferSpeed)
        return ByteCountFormatter.string(fromByteCount: speedPerSec, countStyle: .file) + "/s"
    }
    
    /// 남은 시간을 읽기 쉬운 형식으로 변환
    var formattedTimeRemaining: String {
        guard let remaining = estimatedTimeRemaining else { return "계산중..." }
        
        if remaining < 60 {
            return "\(Int(remaining))초 남음"
        } else if remaining < 3600 {
            let minutes = Int(remaining / 60)
            let seconds = Int(remaining.truncatingRemainder(dividingBy: 60))
            return "\(minutes)분 \(seconds)초 남음"
        } else {
            let hours = Int(remaining / 3600)
            let minutes = Int((remaining.truncatingRemainder(dividingBy: 3600)) / 60)
            return "\(hours)시간 \(minutes)분 남음"
        }
    }
    
    init(
        id: UUID = UUID(),
        fileName: String,
        fileSize: Int64,
        mimeType: String = "application/octet-stream",
        localURL: URL? = nil,
        status: TransferStatus = .pending,
        direction: TransferDirection = .sending,
        bytesTransferred: Int64 = 0
    ) {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
        self.mimeType = mimeType
        self.localURL = localURL
        self.status = status
        self.direction = direction
        self.bytesTransferred = bytesTransferred
        self.startTime = nil
        self.endTime = nil
    }
    
    /// URL에서 TransferFile 생성
    static func from(url: URL) throws -> TransferFile {
        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .contentTypeKey])
        let size = Int64(resourceValues.fileSize ?? 0)
        let contentType = resourceValues.contentType ?? UTType.data
        
        return TransferFile(
            fileName: url.lastPathComponent,
            fileSize: size,
            mimeType: contentType.preferredMIMEType ?? "application/octet-stream",
            localURL: url,
            direction: .sending
        )
    }
}

/// 파일 전송 메타데이터 (네트워크 전송용)
struct TransferMetadata: Codable, Sendable {
    let fileId: UUID
    let fileName: String
    let fileSize: Int64
    let mimeType: String
    let checksum: String?
    
    init(from file: TransferFile, checksum: String? = nil) {
        self.fileId = file.id
        self.fileName = file.fileName
        self.fileSize = file.fileSize
        self.mimeType = file.mimeType
        self.checksum = checksum
    }
}
