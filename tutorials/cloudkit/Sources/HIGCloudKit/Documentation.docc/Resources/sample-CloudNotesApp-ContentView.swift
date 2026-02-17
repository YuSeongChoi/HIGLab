// ContentView.swift
// CloudNotes - 메인 노트 리스트 화면
//
// 노트 목록을 표시하고 CRUD 기능을 제공합니다.

import SwiftUI
import CloudKit

// MARK: - ContentView

/// 메인 노트 리스트 뷰
struct ContentView: View {
    
    // MARK: - 환경
    
    @EnvironmentObject var cloudKitManager: CloudKitManager
    @EnvironmentObject var networkMonitor: NetworkMonitor
    
    // MARK: - 상태
    
    /// 선택된 노트 (편집용)
    @State private var selectedNote: Note?
    
    /// 새 노트 편집 시트 표시 여부
    @State private var showingNewNoteSheet = false
    
    /// 검색 텍스트
    @State private var searchText = ""
    
    /// 삭제 확인 알림 표시 여부
    @State private var showingDeleteAlert = false
    
    /// 삭제할 노트들
    @State private var notesToDelete: [Note] = []
    
    // MARK: - 계산 속성
    
    /// 검색 필터링된 노트 목록
    var filteredNotes: [Note] {
        if searchText.isEmpty {
            return cloudKitManager.notes
        } else {
            return cloudKitManager.notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ZStack {
                if cloudKitManager.notes.isEmpty && !cloudKitManager.syncState.isSyncing {
                    // 빈 상태 뷰
                    emptyStateView
                } else {
                    // 노트 리스트
                    noteListView
                }
            }
            .navigationTitle("CloudNotes")
            .toolbar {
                toolbarContent
            }
            .searchable(text: $searchText, prompt: "노트 검색")
            .refreshable {
                // 당겨서 새로고침
                try? await cloudKitManager.fetchNotes()
            }
            .sheet(isPresented: $showingNewNoteSheet) {
                // 새 노트 편집 시트
                NoteEditorView(note: nil)
            }
            .sheet(item: $selectedNote) { note in
                // 기존 노트 편집 시트
                NoteEditorView(note: note)
            }
            .alert("노트 삭제", isPresented: $showingDeleteAlert) {
                Button("취소", role: .cancel) {
                    notesToDelete = []
                }
                Button("삭제", role: .destructive) {
                    Task {
                        try? await cloudKitManager.delete(notesToDelete)
                        notesToDelete = []
                    }
                }
            } message: {
                Text("\(notesToDelete.count)개의 노트를 삭제하시겠습니까?")
            }
            .overlay(alignment: .bottom) {
                // 동기화 상태 표시
                SyncStatusView()
                    .padding()
            }
        }
    }
    
    // MARK: - 서브뷰
    
    /// 노트 리스트 뷰
    private var noteListView: some View {
        List {
            ForEach(filteredNotes) { note in
                NoteRowView(note: note)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedNote = note
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            notesToDelete = [note]
                            showingDeleteAlert = true
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        ShareLink(item: note.content) {
                            Label("공유", systemImage: "square.and.arrow.up")
                        }
                        .tint(.blue)
                    }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    /// 빈 상태 뷰
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "note.text")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("노트가 없습니다")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("새 노트를 만들어 시작하세요.\niCloud로 모든 기기에 동기화됩니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showingNewNoteSheet = true
            } label: {
                Label("새 노트 만들기", systemImage: "plus")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding()
    }
    
    /// 툴바 콘텐츠
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 왼쪽: 동기화 상태
        ToolbarItem(placement: .topBarLeading) {
            HStack(spacing: 4) {
                Image(systemName: cloudKitManager.syncState.iconName)
                    .symbolEffect(.rotate, isActive: cloudKitManager.syncState.isSyncing)
                    .foregroundStyle(cloudKitManager.syncState.color)
                
                if !networkMonitor.isConnected {
                    Image(systemName: "wifi.slash")
                        .foregroundStyle(.orange)
                }
            }
        }
        
        // 오른쪽: 새 노트 버튼
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingNewNoteSheet = true
            } label: {
                Image(systemName: "square.and.pencil")
            }
        }
    }
}

// MARK: - NoteRowView

/// 노트 리스트 항목 뷰
struct NoteRowView: View {
    
    let note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 제목
            Text(note.title.isEmpty ? "제목 없음" : note.title)
                .font(.headline)
                .lineLimit(1)
            
            // 내용 미리보기
            if !note.content.isEmpty {
                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            // 수정 일시
            Text(note.modifiedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 미리보기

#Preview("노트 있음") {
    ContentView()
        .environmentObject(CloudKitManager.shared)
        .environmentObject(NetworkMonitor.shared)
}

#Preview("빈 상태") {
    ContentView()
        .environmentObject(CloudKitManager.shared)
        .environmentObject(NetworkMonitor.shared)
}
