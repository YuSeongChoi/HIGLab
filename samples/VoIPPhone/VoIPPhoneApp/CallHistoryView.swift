import SwiftUI

// MARK: - 통화 기록 뷰
// 과거 통화 내역을 표시하는 목록 화면

/// 통화 기록 뷰
struct CallHistoryView: View {
    @EnvironmentObject var historyStore: CallHistoryStore
    @EnvironmentObject var contactStore: ContactStore
    @EnvironmentObject var callManager: CallManager
    
    /// 필터 옵션
    @State private var filter: HistoryFilter = .all
    
    /// 선택된 기록 (상세 시트)
    @State private var selectedEntry: CallHistoryEntry?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 필터 세그먼트
                filterPicker
                
                // 기록 목록
                historyList
            }
            .navigationTitle("최근 기록")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            .sheet(item: $selectedEntry) { entry in
                CallDetailSheet(entry: entry)
                    .environmentObject(callManager)
                    .presentationDetents([.medium])
            }
        }
    }
    
    // MARK: - 필터 선택
    
    /// 필터 피커
    private var filterPicker: some View {
        Picker("필터", selection: $filter) {
            ForEach(HistoryFilter.allCases, id: \.self) { option in
                Text(option.title).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding()
    }
    
    /// 필터링된 기록
    private var filteredEntries: [CallHistoryEntry] {
        switch filter {
        case .all:
            return historyStore.entries
        case .missed:
            return historyStore.missedCalls
        case .outgoing:
            return historyStore.entries.filter { $0.direction == .outgoing }
        }
    }
    
    // MARK: - 기록 목록
    
    /// 기록 목록 뷰
    private var historyList: some View {
        Group {
            if filteredEntries.isEmpty {
                emptyStateView
            } else {
                List {
                    ForEach(filteredEntries) { entry in
                        CallHistoryRow(
                            entry: entry,
                            contact: contactStore.findContact(byPhoneNumber: entry.phoneNumber)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedEntry = entry
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                historyStore.deleteEntry(entry)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                callManager.startCall(to: entry.phoneNumber)
                            } label: {
                                Label("전화", systemImage: "phone.fill")
                            }
                            .tint(.green)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    /// 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("통화 기록이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("전화를 걸거나 받으면\n여기에 기록됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - 필터 옵션

/// 기록 필터 열거형
enum HistoryFilter: CaseIterable {
    case all
    case missed
    case outgoing
    
    var title: String {
        switch self {
        case .all: return "전체"
        case .missed: return "부재중"
        case .outgoing: return "발신"
        }
    }
}

// MARK: - 통화 상세 시트

/// 통화 상세 정보 시트
struct CallDetailSheet: View {
    let entry: CallHistoryEntry
    @EnvironmentObject var callManager: CallManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 상대방 정보
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary)
                        )
                    
                    Text(entry.displayName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    if entry.contactName != nil {
                        Text(entry.phoneNumber)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 통화 정보
                GroupBox {
                    VStack(spacing: 16) {
                        infoRow(label: "유형", value: entry.direction.displayText)
                        Divider()
                        infoRow(label: "결과", value: entry.result.displayText)
                        Divider()
                        infoRow(label: "시간", value: entry.detailedTimestamp)
                        if let _ = entry.duration {
                            Divider()
                            infoRow(label: "통화 시간", value: entry.formattedDuration)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 액션 버튼
                HStack(spacing: 20) {
                    // 전화 버튼
                    Button(action: {
                        dismiss()
                        callManager.startCall(to: entry.phoneNumber)
                    }) {
                        Label("전화 걸기", systemImage: "phone.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                    }
                    
                    // 메시지 버튼
                    Button(action: {}) {
                        Label("메시지", systemImage: "message.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 24)
            .navigationTitle("통화 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    /// 정보 행 뷰
    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    CallHistoryView()
        .environmentObject(CallHistoryStore.shared)
        .environmentObject(ContactStore.shared)
        .environmentObject(CallManager.shared)
}
