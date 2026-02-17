import SwiftUI

// MARK: - 참여자 뷰
// SharePlay 세션의 참여자 목록과 관련 기능 제공

struct ParticipantsView: View {
    @EnvironmentObject var sharePlayManager: SharePlayManager
    @EnvironmentObject var groupStateObserver: GroupStateObserver
    
    /// 선택된 참여자 (상세 정보 표시용)
    @State private var selectedParticipant: WatchPartyParticipant?
    
    /// 참여자 상세 시트 표시
    @State private var showingParticipantDetail = false
    
    var body: some View {
        Group {
            if sharePlayManager.sessionState.isActive {
                activeSessionView
            } else {
                emptyStateView
            }
        }
        .navigationTitle("참여자")
        .sheet(isPresented: $showingParticipantDetail) {
            if let participant = selectedParticipant {
                ParticipantDetailSheet(participant: participant)
            }
        }
    }
    
    // MARK: - 활성 세션 뷰
    private var activeSessionView: some View {
        List {
            // 세션 정보 섹션
            Section {
                sessionInfoCard
            }
            
            // 참여자 목록 섹션
            Section {
                ForEach(sharePlayManager.participants) { participant in
                    ParticipantListRow(participant: participant)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedParticipant = participant
                            showingParticipantDetail = true
                        }
                }
            } header: {
                HStack {
                    Text("참여자")
                    Spacer()
                    Text("\(sharePlayManager.participants.count)명")
                        .foregroundStyle(.secondary)
                }
            }
            
            // 활동 기록 섹션
            if !sharePlayManager.chatMessages.isEmpty {
                Section {
                    activityLogView
                } header: {
                    Text("최근 활동")
                }
            }
        }
    }
    
    // MARK: - 세션 정보 카드
    private var sessionInfoCard: some View {
        VStack(spacing: 16) {
            HStack {
                // SharePlay 아이콘
                Image(systemName: "shareplay")
                    .font(.largeTitle)
                    .foregroundStyle(AppTheme.gradient)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("SharePlay 세션")
                        .font(.headline)
                    
                    Text(sharePlayManager.sessionState.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            // 현재 재생 중인 비디오
            if let video = sharePlayManager.playbackState.video {
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("현재 시청 중")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(video.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // 재생 상태 표시
                    Image(systemName: sharePlayManager.playbackState.isPlaying ? "play.fill" : "pause.fill")
                        .font(.title3)
                        .foregroundStyle(AppTheme.primaryColor)
                }
            }
            
            // 세션 종료 버튼
            Button(role: .destructive) {
                sharePlayManager.endSession()
            } label: {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text("세션 종료")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - 활동 기록 뷰
    private var activityLogView: some View {
        ForEach(sharePlayManager.chatMessages.suffix(5).reversed()) { message in
            HStack {
                Image(systemName: "bubble.left.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading) {
                    Text(message.senderName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(message.text)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Text(formatTime(message.timestamp))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
    
    // MARK: - 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text("참여자 없음")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("FaceTime 통화 중 SharePlay를 시작하면\n참여자 목록이 여기에 표시됩니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // SharePlay 시작 안내
            if groupStateObserver.isSharePlayAvailable {
                VStack(spacing: 12) {
                    Image(systemName: "shareplay")
                        .font(.title)
                        .foregroundStyle(AppTheme.gradient)
                    
                    Text("비디오를 선택하고 SharePlay 버튼을 눌러\n함께 시청을 시작하세요.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(AppTheme.cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "video.fill")
                        .font(.title)
                        .foregroundStyle(.secondary)
                    
                    Text("FaceTime 통화를 시작하세요")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(AppTheme.cardBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
            }
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - 유틸리티
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - 참여자 목록 행
struct ParticipantListRow: View {
    let participant: WatchPartyParticipant
    
    var body: some View {
        HStack(spacing: 12) {
            // 아바타
            ZStack {
                Circle()
                    .fill(AppTheme.gradient)
                    .frame(width: 44, height: 44)
                
                Image(systemName: participant.avatarName)
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(participant.displayName)
                        .font(.headline)
                    
                    if participant.role == .host {
                        Image(systemName: "crown.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                }
                
                HStack(spacing: 6) {
                    // 상태 인디케이터
                    Circle()
                        .fill(statusColor(for: participant.status))
                        .frame(width: 8, height: 8)
                    
                    Text(participant.role.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // 상태 아이콘
            Image(systemName: participant.status.iconName)
                .foregroundStyle(statusColor(for: participant.status))
        }
        .padding(.vertical, 4)
    }
    
    private func statusColor(for status: ParticipantStatus) -> Color {
        switch status {
        case .active: return .green
        case .away: return .yellow
        case .disconnected: return .gray
        case .buffering: return .blue
        }
    }
}

// MARK: - 참여자 상세 시트
struct ParticipantDetailSheet: View {
    let participant: WatchPartyParticipant
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 프로필
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.gradient)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: participant.avatarName)
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                    }
                    
                    VStack(spacing: 4) {
                        HStack {
                            Text(participant.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            if participant.role == .host {
                                Image(systemName: "crown.fill")
                                    .foregroundStyle(.yellow)
                            }
                        }
                        
                        Text(participant.role.displayName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 상태 정보
                List {
                    Section {
                        HStack {
                            Label("상태", systemImage: participant.status.iconName)
                            Spacer()
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(Color(participant.status.colorName))
                                    .frame(width: 8, height: 8)
                                Text(participant.status.rawValue.capitalized)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        HStack {
                            Label("참여 시간", systemImage: "clock")
                            Spacer()
                            Text(formatDate(participant.joinedAt))
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Label("마지막 활동", systemImage: "hand.tap")
                            Spacer()
                            Text(formatRelativeTime(participant.lastActiveAt))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    // 권한 정보
                    Section {
                        HStack {
                            Label("재생 제어", systemImage: "play.circle")
                            Spacer()
                            Image(systemName: participant.role.canControlPlayback ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(participant.role.canControlPlayback ? .green : .red)
                        }
                        
                        HStack {
                            Label("참여자 관리", systemImage: "person.badge.key")
                            Spacer()
                            Image(systemName: participant.role.canManageParticipants ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(participant.role.canManageParticipants ? .green : .red)
                        }
                    } header: {
                        Text("권한")
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("참여자 정보")
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatRelativeTime(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ParticipantsView()
            .environmentObject(SharePlayManager())
            .environmentObject(GroupStateObserver())
    }
}
