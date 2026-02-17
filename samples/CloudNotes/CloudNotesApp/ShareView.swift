// ShareView.swift
// CloudNotes - 노트 공유 화면
//
// CloudKit 기반 노트 공유 기능을 제공합니다.

import SwiftUI
import CloudKit

// MARK: - ShareView

/// 노트 공유 뷰
/// CloudKit 공유 및 일반 공유 기능을 제공합니다.
struct ShareView: View {
    
    // MARK: - 환경
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var cloudKitManager: CloudKitManager
    
    // MARK: - 속성
    
    /// 공유할 노트
    let note: Note
    
    // MARK: - 상태
    
    /// 공유 유형
    @State private var shareType: ShareType = .text
    
    /// CloudKit 공유 생성 중
    @State private var isCreatingShare = false
    
    /// 생성된 공유 링크
    @State private var shareURL: URL?
    
    /// 에러 표시
    @State private var showingError = false
    @State private var errorMessage = ""
    
    /// 복사 완료 토스트
    @State private var showCopiedToast = false
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // 노트 미리보기
                notePreviewSection
                
                // 공유 옵션
                shareOptionsSection
                
                // CloudKit 공유 (실시간 협업)
                cloudKitShareSection
            }
            .navigationTitle("공유")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .alert("오류", isPresented: $showingError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .overlay {
                if showCopiedToast {
                    copiedToastView
                }
            }
        }
    }
    
    // MARK: - 섹션
    
    /// 노트 미리보기 섹션
    private var notePreviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 8) {
                Text(note.title.isEmpty ? "제목 없음" : note.title)
                    .font(.headline)
                
                if !note.content.isEmpty {
                    Text(note.content)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
                
                Text("수정: \(note.modifiedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
    }
    
    /// 공유 옵션 섹션
    private var shareOptionsSection: some View {
        Section("공유 방법") {
            // 텍스트 공유
            ShareLink(item: shareText) {
                Label("텍스트로 공유", systemImage: "text.bubble")
            }
            
            // 클립보드 복사
            Button {
                copyToClipboard()
            } label: {
                Label("클립보드에 복사", systemImage: "doc.on.doc")
            }
            
            // 파일로 내보내기
            ShareLink(
                item: shareText,
                preview: SharePreview(
                    note.title.isEmpty ? "노트" : note.title,
                    image: Image(systemName: "note.text")
                )
            ) {
                Label("파일로 내보내기", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    /// CloudKit 공유 섹션
    private var cloudKitShareSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("iCloud로 공유")
                            .font(.headline)
                        Text("다른 사람과 실시간으로 협업할 수 있습니다")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                if let shareURL = shareURL {
                    // 공유 링크 생성됨
                    VStack(alignment: .leading, spacing: 8) {
                        Text("공유 링크:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack {
                            Text(shareURL.absoluteString)
                                .font(.caption.monospaced())
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Spacer()
                            
                            Button {
                                UIPasteboard.general.url = shareURL
                                showCopiedToastBriefly()
                            } label: {
                                Image(systemName: "doc.on.doc")
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        ShareLink(item: shareURL) {
                            Label("링크 공유하기", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                    }
                } else {
                    // 공유 링크 생성 버튼
                    Button {
                        createCloudKitShare()
                    } label: {
                        HStack {
                            if isCreatingShare {
                                ProgressView()
                                    .controlSize(.small)
                            }
                            Text(isCreatingShare ? "링크 생성 중..." : "공유 링크 만들기")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(isCreatingShare || note.recordID == nil)
                    
                    if note.recordID == nil {
                        Text("노트가 iCloud에 저장된 후에 공유할 수 있습니다")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }
            }
            .padding(.vertical, 4)
        } header: {
            Text("실시간 협업")
        } footer: {
            Text("iCloud 공유는 상대방도 iCloud 계정이 필요합니다. 공유된 노트는 실시간으로 동기화됩니다.")
        }
    }
    
    /// 복사 완료 토스트
    private var copiedToastView: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("복사됨")
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Capsule().fill(.green))
            .padding(.bottom, 100)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.spring(duration: 0.3), value: showCopiedToast)
    }
    
    // MARK: - 계산 속성
    
    /// 공유할 텍스트
    private var shareText: String {
        var text = ""
        
        if !note.title.isEmpty {
            text += "# \(note.title)\n\n"
        }
        
        text += note.content
        
        text += "\n\n---\nCloudNotes에서 작성됨"
        
        return text
    }
    
    // MARK: - 액션
    
    /// 클립보드에 복사
    private func copyToClipboard() {
        UIPasteboard.general.string = shareText
        showCopiedToastBriefly()
    }
    
    /// 복사 토스트 잠시 표시
    private func showCopiedToastBriefly() {
        withAnimation {
            showCopiedToast = true
        }
        
        Task {
            try? await Task.sleep(for: .seconds(1.5))
            withAnimation {
                showCopiedToast = false
            }
        }
    }
    
    /// CloudKit 공유 생성
    private func createCloudKitShare() {
        isCreatingShare = true
        
        Task {
            do {
                let share = try await cloudKitManager.createShare(for: note)
                
                await MainActor.run {
                    self.shareURL = share.url
                    self.isCreatingShare = false
                }
            } catch {
                await MainActor.run {
                    self.isCreatingShare = false
                    self.errorMessage = "공유 링크 생성 실패: \(error.localizedDescription)"
                    self.showingError = true
                }
            }
        }
    }
}

// MARK: - ShareType

/// 공유 유형
enum ShareType: String, CaseIterable {
    case text = "텍스트"
    case file = "파일"
    case cloudKit = "iCloud"
}

// MARK: - CloudKitSharingController

/// CloudKit 공유 컨트롤러 (UIKit 브릿지)
/// 시스템 공유 UI를 표시합니다.
struct CloudKitSharingController: UIViewControllerRepresentable {
    
    let share: CKShare
    let container: CKContainer
    
    func makeUIViewController(context: Context) -> UICloudSharingController {
        let controller = UICloudSharingController(share: share, container: container)
        controller.availablePermissions = [.allowReadOnly, .allowReadWrite]
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
}

// MARK: - 미리보기

#Preview {
    ShareView(note: .sample)
        .environmentObject(CloudKitManager.shared)
}
