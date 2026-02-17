import SwiftUI

// MARK: - 비밀 상세 뷰
/// 비밀 항목의 상세 정보를 표시하고 편집하는 뷰
///
/// ## 기능:
/// - 민감 정보 표시/숨김 토글
/// - 클립보드 복사 (자동 삭제 옵션)
/// - 필드 편집
/// - 암호화 상태 관리

struct SecretDetailView: View {
    
    // MARK: - 속성
    
    /// 표시할 비밀 항목
    let secret: SecretItem
    
    /// 업데이트 콜백
    let onUpdate: (SecretItem) -> Void
    
    /// 삭제 콜백
    let onDelete: () -> Void
    
    // MARK: - 환경 및 상태
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: SecretDetailViewModel
    
    /// 편집 모드
    @State private var isEditing = false
    
    /// 민감 정보 표시 여부
    @State private var isContentRevealed = false
    
    /// 삭제 확인 알림
    @State private var showDeleteConfirmation = false
    
    /// 복사 완료 토스트
    @State private var showCopyToast = false
    @State private var copiedFieldName = ""
    
    /// 암호화 진행 중
    @State private var isEncrypting = false
    
    // MARK: - 초기화
    
    init(
        secret: SecretItem,
        onUpdate: @escaping (SecretItem) -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.secret = secret
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self._viewModel = StateObject(wrappedValue: SecretDetailViewModel(secret: secret))
    }
    
    // MARK: - 바디
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더 카드
                    headerCard
                    
                    // 메인 콘텐츠
                    mainContentSection
                    
                    // 커스텀 필드
                    if !viewModel.editingSecret.customFields.isEmpty {
                        customFieldsSection
                    }
                    
                    // 태그
                    if !viewModel.editingSecret.tags.isEmpty || isEditing {
                        tagsSection
                    }
                    
                    // 메모
                    if viewModel.editingSecret.notes != nil || isEditing {
                        notesSection
                    }
                    
                    // 메타데이터
                    metadataSection
                    
                    // 위험 영역
                    dangerZone
                }
                .padding()
            }
            .navigationTitle(isEditing ? "편집" : "상세 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
            .confirmationDialog(
                "이 비밀을 삭제하시겠습니까?",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    onDelete()
                    dismiss()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("삭제된 항목은 복구할 수 없습니다.")
            }
            .overlay {
                if showCopyToast {
                    copyToastOverlay
                }
            }
        }
    }
    
    // MARK: - 헤더 카드
    
    private var headerCard: some View {
        VStack(spacing: 16) {
            // 카테고리 아이콘
            ZStack {
                Circle()
                    .fill(viewModel.editingSecret.category.color.gradient)
                    .frame(width: 80, height: 80)
                
                Image(systemName: viewModel.editingSecret.category.iconName)
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            
            // 제목
            if isEditing {
                TextField("제목", text: $viewModel.editingSecret.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, 32)
            } else {
                HStack {
                    Text(viewModel.editingSecret.title)
                        .font(.title2.bold())
                    
                    if viewModel.editingSecret.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                    }
                }
            }
            
            // 카테고리 선택 (편집 모드)
            if isEditing {
                Picker("카테고리", selection: $viewModel.editingSecret.category) {
                    ForEach(SecretItem.Category.allCases) { category in
                        Label(category.rawValue, systemImage: category.iconName)
                            .tag(category)
                    }
                }
                .pickerStyle(.menu)
            } else {
                Text(viewModel.editingSecret.category.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 상태 배지
            HStack(spacing: 8) {
                if viewModel.editingSecret.isEncrypted {
                    statusBadge(icon: "lock.fill", text: "암호화됨", color: .green)
                }
                
                if viewModel.editingSecret.isPinned {
                    statusBadge(icon: "pin.fill", text: "고정됨", color: .orange)
                }
                
                if viewModel.editingSecret.isExpired {
                    statusBadge(icon: "exclamationmark.circle.fill", text: "만료됨", color: .red)
                } else if viewModel.editingSecret.isExpiringSoon {
                    statusBadge(icon: "clock.fill", text: "만료 예정", color: .orange)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private func statusBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
            Text(text)
        }
        .font(.caption)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.2))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
    
    // MARK: - 메인 콘텐츠 섹션
    
    private var mainContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "내용", icon: "doc.text")
            
            if isEditing {
                TextEditor(text: $viewModel.editingSecret.content)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(isContentRevealed ? viewModel.displayContent : viewModel.maskedContent)
                            .font(.body.monospaced())
                            .textSelection(.enabled)
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            // 표시/숨김 토글
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    isContentRevealed.toggle()
                                }
                            } label: {
                                Image(systemName: isContentRevealed ? "eye.slash" : "eye")
                                    .foregroundStyle(.secondary)
                            }
                            
                            // 복사
                            Button {
                                copyToClipboard(viewModel.displayContent, fieldName: "내용")
                            } label: {
                                Image(systemName: "doc.on.doc")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }
    
    // MARK: - 커스텀 필드 섹션
    
    private var customFieldsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "추가 정보", icon: "list.bullet.rectangle")
            
            ForEach(viewModel.editingSecret.customFields.indices, id: \.self) { index in
                customFieldRow(at: index)
            }
            
            // 필드 추가 버튼 (편집 모드)
            if isEditing {
                Button {
                    viewModel.addCustomField()
                } label: {
                    Label("필드 추가", systemImage: "plus.circle")
                        .font(.subheadline)
                }
                .padding(.top, 8)
            }
        }
    }
    
    private func customFieldRow(at index: Int) -> some View {
        let field = viewModel.editingSecret.customFields[index]
        
        return VStack(alignment: .leading, spacing: 4) {
            if isEditing {
                HStack {
                    TextField("필드명", text: $viewModel.editingSecret.customFields[index].name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Button {
                        viewModel.removeCustomField(at: index)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
                
                TextField("값", text: $viewModel.editingSecret.customFields[index].value)
                    .textFieldStyle(.roundedBorder)
            } else {
                Text(field.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text(field.fieldType.shouldMask && !isContentRevealed
                         ? String(repeating: "•", count: min(field.value.count, 12))
                         : field.value)
                        .font(.body.monospaced())
                    
                    Spacer()
                    
                    Button {
                        copyToClipboard(field.value, fieldName: field.name)
                    } label: {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - 태그 섹션
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "태그", icon: "tag")
            
            if isEditing {
                TextField("태그 (쉼표로 구분)", text: $viewModel.tagsString)
                    .textFieldStyle(.roundedBorder)
            } else {
                FlowLayout(spacing: 8) {
                    ForEach(viewModel.editingSecret.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.2))
                            .foregroundStyle(.blue)
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // MARK: - 메모 섹션
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "메모", icon: "note.text")
            
            if isEditing {
                TextEditor(text: Binding(
                    get: { viewModel.editingSecret.notes ?? "" },
                    set: { viewModel.editingSecret.notes = $0.isEmpty ? nil : $0 }
                ))
                .frame(minHeight: 80)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else if let notes = viewModel.editingSecret.notes {
                Text(notes)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    
    // MARK: - 메타데이터 섹션
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "정보", icon: "info.circle")
            
            VStack(spacing: 0) {
                metadataRow("생성일", value: viewModel.editingSecret.createdAt.formatted())
                Divider()
                metadataRow("수정일", value: viewModel.editingSecret.modifiedAt.formatted())
                
                if let lastAccessed = viewModel.editingSecret.lastAccessedAt {
                    Divider()
                    metadataRow("최근 열람", value: lastAccessed.formatted(.relative(presentation: .named)))
                }
                
                Divider()
                metadataRow("열람 횟수", value: "\(viewModel.editingSecret.accessCount)회")
                
                if viewModel.editingSecret.isEncrypted {
                    Divider()
                    metadataRow("암호화", value: "AES-256-GCM")
                }
                
                if let expiresAt = viewModel.editingSecret.expiresAt {
                    Divider()
                    metadataRow("만료일", value: expiresAt.formatted())
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private func metadataRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
        .padding()
    }
    
    // MARK: - 위험 영역
    
    private var dangerZone: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "위험 영역", icon: "exclamationmark.triangle")
            
            VStack(spacing: 0) {
                // 암호화 토글
                Button {
                    Task {
                        await viewModel.toggleEncryption()
                    }
                } label: {
                    HStack {
                        Label(
                            viewModel.editingSecret.isEncrypted ? "복호화" : "암호화",
                            systemImage: viewModel.editingSecret.isEncrypted ? "lock.open" : "lock"
                        )
                        Spacer()
                        if isEncrypting {
                            ProgressView()
                        } else {
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .disabled(isEncrypting)
                .padding()
                
                Divider()
                
                // 보관함 이동
                Button {
                    viewModel.editingSecret.isArchived.toggle()
                    saveChanges()
                } label: {
                    HStack {
                        Label(
                            viewModel.editingSecret.isArchived ? "보관함에서 복원" : "보관함으로 이동",
                            systemImage: viewModel.editingSecret.isArchived ? "arrow.uturn.left" : "archivebox"
                        )
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
                
                Divider()
                
                // 삭제
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    HStack {
                        Label("영구 삭제", systemImage: "trash")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding()
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(isEditing ? "취소" : "닫기") {
                if isEditing {
                    viewModel.resetChanges()
                    isEditing = false
                } else {
                    dismiss()
                }
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            if isEditing {
                Button("저장") {
                    saveChanges()
                    isEditing = false
                }
                .disabled(viewModel.editingSecret.title.isEmpty)
            } else {
                Menu {
                    Button {
                        isEditing = true
                    } label: {
                        Label("편집", systemImage: "pencil")
                    }
                    
                    Button {
                        viewModel.editingSecret.isFavorite.toggle()
                        saveChanges()
                    } label: {
                        Label(
                            viewModel.editingSecret.isFavorite ? "즐겨찾기 해제" : "즐겨찾기",
                            systemImage: viewModel.editingSecret.isFavorite ? "star.slash" : "star"
                        )
                    }
                    
                    Button {
                        viewModel.editingSecret.isPinned.toggle()
                        saveChanges()
                    } label: {
                        Label(
                            viewModel.editingSecret.isPinned ? "고정 해제" : "고정",
                            systemImage: viewModel.editingSecret.isPinned ? "pin.slash" : "pin"
                        )
                    }
                    
                    Divider()
                    
                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    // MARK: - 복사 토스트
    
    private var copyToastOverlay: some View {
        VStack {
            Spacer()
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("\(copiedFieldName) 복사됨")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.bottom, 32)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    // MARK: - 헬퍼
    
    private func copyToClipboard(_ text: String, fieldName: String) {
        UIPasteboard.general.string = text
        copiedFieldName = fieldName
        
        withAnimation {
            showCopyToast = true
        }
        
        // 60초 후 클립보드 자동 삭제 (보안)
        DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
            if UIPasteboard.general.string == text {
                UIPasteboard.general.string = nil
            }
        }
        
        // 토스트 숨기기
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showCopyToast = false
            }
        }
    }
    
    private func saveChanges() {
        viewModel.editingSecret.modifiedAt = Date()
        onUpdate(viewModel.editingSecret)
    }
}

// MARK: - 섹션 헤더
struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        Label(title, systemImage: icon)
            .font(.headline)
            .foregroundStyle(.primary)
    }
}

// MARK: - 플로우 레이아웃 (태그용)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        return layout(sizes: sizes, proposal: proposal).size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        let offsets = layout(sizes: sizes, proposal: proposal).offsets
        
        for (subview, offset) in zip(subviews, offsets) {
            subview.place(at: CGPoint(x: bounds.minX + offset.x, y: bounds.minY + offset.y), proposal: .unspecified)
        }
    }
    
    private func layout(sizes: [CGSize], proposal: ProposedViewSize) -> (offsets: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var offsets: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            
            offsets.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
        
        return (offsets, CGSize(width: maxWidth, height: currentY + lineHeight))
    }
}

// MARK: - ViewModel
@MainActor
class SecretDetailViewModel: ObservableObject {
    @Published var editingSecret: SecretItem
    @Published var displayContent: String
    
    private let originalSecret: SecretItem
    private let cryptoService = CryptoService.shared
    
    var maskedContent: String {
        String(repeating: "•", count: min(displayContent.count, 20))
    }
    
    var tagsString: String {
        get { editingSecret.tags.joined(separator: ", ") }
        set { editingSecret.tags = newValue.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) } }
    }
    
    init(secret: SecretItem) {
        self.originalSecret = secret
        self.editingSecret = secret
        
        // 암호화된 경우 복호화
        if secret.isEncrypted {
            do {
                let decrypted = try cryptoService.decryptSecretContent(secret)
                self.displayContent = decrypted.content
            } catch {
                self.displayContent = "[복호화 실패]"
            }
        } else {
            self.displayContent = secret.content
        }
    }
    
    func resetChanges() {
        editingSecret = originalSecret
    }
    
    func addCustomField() {
        editingSecret.customFields.append(
            SecretItem.CustomField(name: "", value: "")
        )
    }
    
    func removeCustomField(at index: Int) {
        guard editingSecret.customFields.indices.contains(index) else { return }
        editingSecret.customFields.remove(at: index)
    }
    
    func toggleEncryption() async {
        do {
            if editingSecret.isEncrypted {
                editingSecret = try cryptoService.decryptSecretContent(editingSecret)
                displayContent = editingSecret.content
            } else {
                editingSecret = try cryptoService.encryptSecretContent(editingSecret)
            }
        } catch {
            // 에러 처리
        }
    }
}

// MARK: - 미리보기
#Preview {
    SecretDetailView(
        secret: .sample,
        onUpdate: { _ in },
        onDelete: { }
    )
}
