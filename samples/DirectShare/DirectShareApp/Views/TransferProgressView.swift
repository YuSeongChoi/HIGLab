// TransferProgressView.swift
// DirectShare - Wi-Fi Aware 직접 파일 공유
// 파일 전송 진행률 표시

import SwiftUI

/// 파일 전송 진행률 뷰
struct TransferProgressView: View {
    @Environment(FileTransferService.self) private var transferService
    @Environment(WiFiAwareManager.self) private var wifiManager
    
    /// 선택된 전송 (상세 정보용)
    @State private var selectedTransfer: TransferFile?
    
    /// 취소 확인 알림 표시
    @State private var showCancelAlert = false
    
    var body: some View {
        Group {
            if transferService.activeTransfers.isEmpty && transferService.pendingOffers.isEmpty {
                emptyStateView
            } else {
                transferListView
            }
        }
        .alert("전송 취소", isPresented: $showCancelAlert) {
            Button("취소", role: .cancel) {}
            Button("확인", role: .destructive) {
                cancelSelectedTransfer()
            }
        } message: {
            if let transfer = selectedTransfer {
                Text("\(transfer.fileName) 전송을 취소하시겠습니까?")
            }
        }
    }
    
    // MARK: - 서브뷰
    
    /// 전송 없을 때 표시
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("전송 중인 파일 없음", systemImage: "arrow.up.arrow.down.circle")
        } description: {
            Text("연결된 기기로 파일을 보내거나 받으면 여기에 표시됩니다")
        } actions: {
            if !wifiManager.discoveredPeers.isEmpty {
                Text("연결된 기기에서 '파일 보내기'를 선택하세요")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    /// 전송 목록
    private var transferListView: some View {
        List {
            // 수신 대기 중인 파일 제안
            if !transferService.pendingOffers.isEmpty {
                Section("수신 대기") {
                    ForEach(transferService.pendingOffers) { file in
                        PendingOfferRow(file: file)
                    }
                }
            }
            
            // 진행 중인 전송
            if !transferService.activeTransfers.isEmpty {
                Section("전송 중") {
                    ForEach(transferService.activeTransfers) { file in
                        ActiveTransferRow(file: file)
                            .swipeActions(edge: .trailing) {
                                Button("취소", role: .destructive) {
                                    selectedTransfer = file
                                    showCancelAlert = true
                                }
                            }
                    }
                }
            }
        }
    }
    
    /// 선택된 전송 취소
    private func cancelSelectedTransfer() {
        guard let transfer = selectedTransfer else { return }
        
        Task {
            try? await transferService.cancelTransfer(transfer)
        }
        
        selectedTransfer = nil
    }
}

// MARK: - 진행 중인 전송 행

/// 진행 중인 파일 전송 표시
struct ActiveTransferRow: View {
    let file: TransferFile
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 파일 정보
            HStack {
                Image(systemName: fileIcon)
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .frame(width: 32)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(file.fileName)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text(file.direction == .sending ? "보내는 중" : "받는 중")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // 전송 속도
                VStack(alignment: .trailing, spacing: 2) {
                    Text(file.formattedSpeed)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                    
                    Text(file.formattedTimeRemaining)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 진행률 바
            VStack(alignment: .leading, spacing: 4) {
                ProgressView(value: file.progress)
                    .tint(progressColor)
                
                HStack {
                    Text("\(file.formattedTransferred) / \(file.formattedSize)")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(file.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(progressColor)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    /// 파일 아이콘
    private var fileIcon: String {
        let ext = (file.fileName as NSString).pathExtension.lowercased()
        
        switch ext {
        case "jpg", "jpeg", "png", "gif", "heic":
            return "photo"
        case "mp4", "mov", "m4v":
            return "video"
        case "mp3", "m4a", "wav":
            return "music.note"
        case "pdf":
            return "doc.text"
        case "zip", "tar", "gz":
            return "doc.zipper"
        default:
            return "doc"
        }
    }
    
    /// 진행률 색상
    private var progressColor: Color {
        switch file.status {
        case .transferring:
            return .blue
        case .preparing:
            return .orange
        case .completed:
            return .green
        case .failed, .cancelled:
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - 대기 중인 수신 행

/// 수신 대기 중인 파일 제안 표시
struct PendingOfferRow: View {
    @Environment(FileTransferService.self) private var transferService
    @Environment(WiFiAwareManager.self) private var wifiManager
    
    let file: TransferFile
    
    var body: some View {
        HStack(spacing: 12) {
            // 파일 아이콘
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "arrow.down.circle")
                    .font(.title3)
                    .foregroundStyle(.orange)
            }
            
            // 파일 정보
            VStack(alignment: .leading, spacing: 2) {
                Text(file.fileName)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(file.formattedSize)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // 수락/거부 버튼
            HStack(spacing: 8) {
                Button {
                    rejectFile()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                
                Button {
                    acceptFile()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }
    
    /// 파일 수락
    private func acceptFile() {
        // 연결된 피어 중 첫 번째를 사용 (실제로는 전송자 피어를 추적해야 함)
        guard let peer = wifiManager.discoveredPeers.first(where: { $0.connectionState.isConnected }) else {
            return
        }
        
        Task {
            try? await transferService.acceptFileOffer(file, from: peer)
        }
    }
    
    /// 파일 거부
    private func rejectFile() {
        guard let peer = wifiManager.discoveredPeers.first(where: { $0.connectionState.isConnected }) else {
            return
        }
        
        Task {
            try? await transferService.rejectFileOffer(file, from: peer)
        }
    }
}

// MARK: - 전송 상세 뷰

/// 전송 상세 정보 시트
struct TransferDetailView: View {
    let file: TransferFile
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("파일 정보") {
                    LabeledContent("파일 이름", value: file.fileName)
                    LabeledContent("파일 크기", value: file.formattedSize)
                    LabeledContent("MIME 타입", value: file.mimeType)
                }
                
                Section("전송 상태") {
                    LabeledContent("상태", value: file.status.rawValue)
                    LabeledContent("방향", value: file.direction.rawValue)
                    LabeledContent("진행률", value: "\(Int(file.progress * 100))%")
                    LabeledContent("전송된 크기", value: file.formattedTransferred)
                    
                    if file.status == .transferring {
                        LabeledContent("전송 속도", value: file.formattedSpeed)
                        LabeledContent("남은 시간", value: file.formattedTimeRemaining)
                    }
                }
                
                Section("시간 정보") {
                    if let startTime = file.startTime {
                        LabeledContent("시작 시간", value: startTime, format: .dateTime)
                    }
                    
                    if let endTime = file.endTime {
                        LabeledContent("완료 시간", value: endTime, format: .dateTime)
                    }
                }
            }
            .navigationTitle("전송 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 원형 진행률 뷰

/// 원형 진행률 표시
struct CircularProgressView: View {
    let progress: Double
    let lineWidth: CGFloat
    let size: CGFloat
    
    init(progress: Double, lineWidth: CGFloat = 4, size: CGFloat = 60) {
        self.progress = progress
        self.lineWidth = lineWidth
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // 배경 원
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: lineWidth)
            
            // 진행률 원
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progress < 1 ? Color.blue : Color.green,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.3), value: progress)
            
            // 퍼센트 텍스트
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .semibold, design: .rounded))
                .foregroundStyle(progress < 1 ? .primary : .green)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - 전송 알림 뷰

/// 파일 전송 알림 오버레이
struct TransferNotificationView: View {
    let file: TransferFile
    let peerName: String
    var onAccept: () -> Void
    var onReject: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "arrow.down.doc")
                    .font(.title)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(peerName)이(가) 파일을 보내려고 합니다")
                        .font(.headline)
                    
                    Text("\(file.fileName) (\(file.formattedSize))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(spacing: 12) {
                Button(role: .cancel) {
                    onReject()
                } label: {
                    Text("거부")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Button {
                    onAccept()
                } label: {
                    Text("수락")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
        .padding()
    }
}

#Preview("Transfer Progress") {
    TransferProgressView()
        .environment(FileTransferService())
        .environment(WiFiAwareManager())
}

#Preview("Circular Progress") {
    VStack(spacing: 20) {
        CircularProgressView(progress: 0.25)
        CircularProgressView(progress: 0.5, size: 80)
        CircularProgressView(progress: 0.75, lineWidth: 6, size: 100)
        CircularProgressView(progress: 1.0)
    }
}
