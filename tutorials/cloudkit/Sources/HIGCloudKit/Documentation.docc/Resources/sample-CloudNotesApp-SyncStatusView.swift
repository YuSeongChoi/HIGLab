// SyncStatusView.swift
// CloudNotes - 동기화 상태 표시 뷰
//
// 현재 동기화 상태를 시각적으로 보여주는 오버레이 뷰입니다.

import SwiftUI

// MARK: - SyncStatusView

/// 동기화 상태 인디케이터 뷰
/// 화면 하단에 현재 동기화 상태를 표시합니다.
struct SyncStatusView: View {
    
    // MARK: - 환경
    
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    // MARK: - 상태
    
    /// 뷰 표시 여부 (애니메이션용)
    @State private var isVisible = false
    
    /// 자동 숨김 타이머 태스크
    @State private var hideTask: Task<Void, Never>?
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if shouldShowStatus {
                statusBadge
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity
                    ))
            }
        }
        .animation(.spring(duration: 0.3), value: shouldShowStatus)
        .onChange(of: cloudKitManager.syncState) { _, newState in
            handleStateChange(newState)
        }
    }
    
    // MARK: - 계산 속성
    
    /// 상태 표시 여부
    private var shouldShowStatus: Bool {
        // 동기화 중이거나 오류 상태일 때 표시
        switch cloudKitManager.syncState {
        case .syncing:
            return true
        case .error:
            return isVisible
        case .synced:
            return isVisible  // 잠시 표시 후 숨김
        case .offline:
            return true
        case .idle:
            return false
        }
    }
    
    // MARK: - 서브뷰
    
    /// 상태 배지
    private var statusBadge: some View {
        HStack(spacing: 8) {
            // 아이콘
            statusIcon
            
            // 메시지
            Text(statusMessage)
                .font(.subheadline)
                .fontWeight(.medium)
            
            // 재시도 버튼 (에러 시)
            if cloudKitManager.syncState.hasError {
                Button {
                    retrySync()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.subheadline.weight(.semibold))
                }
                .buttonStyle(.plain)
            }
        }
        .foregroundStyle(statusForegroundColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(statusBackgroundColor)
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
    }
    
    /// 상태 아이콘
    @ViewBuilder
    private var statusIcon: some View {
        switch cloudKitManager.syncState {
        case .syncing:
            ProgressView()
                .controlSize(.small)
                .tint(statusForegroundColor)
        case .synced:
            Image(systemName: "checkmark.circle.fill")
        case .error:
            Image(systemName: "exclamationmark.circle.fill")
        case .offline:
            Image(systemName: "wifi.slash")
        case .idle:
            EmptyView()
        }
    }
    
    /// 상태 메시지
    private var statusMessage: String {
        if !networkMonitor.isConnected {
            return "오프라인"
        }
        
        switch cloudKitManager.syncState {
        case .syncing(let message):
            return message
        case .synced:
            return "동기화 완료"
        case .error(let error):
            // 간략한 에러 메시지
            return errorMessage(for: error)
        case .offline:
            return "오프라인"
        case .idle:
            return ""
        }
    }
    
    /// 전경색
    private var statusForegroundColor: Color {
        switch cloudKitManager.syncState {
        case .syncing:
            return .primary
        case .synced:
            return .white
        case .error:
            return .white
        case .offline:
            return .white
        case .idle:
            return .primary
        }
    }
    
    /// 배경색
    private var statusBackgroundColor: Color {
        switch cloudKitManager.syncState {
        case .syncing:
            return Color(.systemBackground)
        case .synced:
            return .green
        case .error:
            return .red
        case .offline:
            return .orange
        case .idle:
            return Color(.systemBackground)
        }
    }
    
    // MARK: - 헬퍼
    
    /// 상태 변경 처리
    private func handleStateChange(_ state: SyncState) {
        // 기존 타이머 취소
        hideTask?.cancel()
        
        switch state {
        case .synced:
            // 동기화 완료 시 잠시 표시 후 숨김
            isVisible = true
            hideTask = Task {
                try? await Task.sleep(for: .seconds(2))
                if !Task.isCancelled {
                    await MainActor.run {
                        isVisible = false
                    }
                }
            }
        case .error:
            // 에러 시 계속 표시
            isVisible = true
        case .syncing:
            isVisible = true
        default:
            break
        }
    }
    
    /// 에러 메시지 추출
    private func errorMessage(for error: Error) -> String {
        if let cloudKitError = error as? CloudKitError {
            return cloudKitError.localizedDescription
        }
        
        // 일반적인 에러 메시지 간소화
        let description = error.localizedDescription
        if description.count > 30 {
            return "동기화 오류"
        }
        return description
    }
    
    /// 동기화 재시도
    private func retrySync() {
        Task {
            try? await cloudKitManager.fetchNotes()
        }
    }
}

// MARK: - SyncStatusDetailView

/// 상세 동기화 상태 뷰 (설정 또는 디버그용)
struct SyncStatusDetailView: View {
    
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    var body: some View {
        Form {
            // 연결 상태
            Section("연결 상태") {
                LabeledContent("네트워크") {
                    HStack {
                        Image(systemName: networkMonitor.isConnected ? "wifi" : "wifi.slash")
                        Text(networkMonitor.isConnected ? "연결됨" : "연결 안됨")
                    }
                    .foregroundStyle(networkMonitor.isConnected ? .green : .red)
                }
                
                LabeledContent("iCloud") {
                    HStack {
                        Image(systemName: accountStatusIcon)
                        Text(accountStatusText)
                    }
                    .foregroundStyle(accountStatusColor)
                }
            }
            
            // 동기화 상태
            Section("동기화") {
                LabeledContent("상태") {
                    HStack {
                        Image(systemName: cloudKitManager.syncState.iconName)
                        Text(cloudKitManager.syncState.description)
                    }
                    .foregroundStyle(cloudKitManager.syncState.color)
                }
                
                if let lastSync = cloudKitManager.lastSyncDate {
                    LabeledContent("마지막 동기화") {
                        Text(lastSync, style: .relative)
                    }
                }
                
                LabeledContent("저장된 노트") {
                    Text("\(cloudKitManager.notes.count)개")
                }
            }
            
            // 액션
            Section {
                Button {
                    Task {
                        try? await cloudKitManager.fetchNotes()
                    }
                } label: {
                    Label("지금 동기화", systemImage: "arrow.clockwise")
                }
                .disabled(cloudKitManager.syncState.isSyncing)
            }
        }
        .navigationTitle("동기화 상태")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 계정 상태 표시
    private var accountStatusIcon: String {
        switch cloudKitManager.accountStatus {
        case .available: return "checkmark.icloud"
        case .noAccount: return "person.crop.circle.badge.xmark"
        case .restricted: return "lock.icloud"
        default: return "icloud.slash"
        }
    }
    
    private var accountStatusText: String {
        switch cloudKitManager.accountStatus {
        case .available: return "사용 가능"
        case .noAccount: return "계정 없음"
        case .restricted: return "제한됨"
        case .couldNotDetermine: return "확인 불가"
        case .temporarilyUnavailable: return "일시 불가"
        @unknown default: return "알 수 없음"
        }
    }
    
    private var accountStatusColor: Color {
        switch cloudKitManager.accountStatus {
        case .available: return .green
        default: return .red
        }
    }
}

// MARK: - 미리보기

#Preview("동기화 중") {
    SyncStatusView()
        .environmentObject(CloudKitManager.shared)
        .environmentObject(NetworkMonitor.shared)
}

#Preview("상세 상태") {
    NavigationStack {
        SyncStatusDetailView()
            .environmentObject(CloudKitManager.shared)
            .environmentObject(NetworkMonitor.shared)
    }
}
