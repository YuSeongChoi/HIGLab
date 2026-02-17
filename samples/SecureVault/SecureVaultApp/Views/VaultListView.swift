import SwiftUI

// MARK: - 비밀 금고 목록 뷰
/// 저장된 모든 비밀 항목을 표시하고 관리하는 메인 목록 뷰
///
/// ## 기능:
/// - 카테고리별 섹션 구분
/// - 검색 및 필터링
/// - 정렬 옵션
/// - 스와이프 액션 (삭제, 즐겨찾기)
/// - 다중 선택 모드

struct VaultListView: View {
    
    // MARK: - 환경 및 상태
    
    @EnvironmentObject private var biometricService: BiometricService
    @StateObject private var viewModel = VaultListViewModel()
    
    /// 검색어
    @State private var searchText = ""
    
    /// 선택된 항목
    @State private var selectedSecret: SecretItem?
    
    /// 새 항목 추가 시트
    @State private var showingAddSheet = false
    
    /// 설정 시트
    @State private var showingSettings = false
    
    /// 필터 시트
    @State private var showingFilters = false
    
    /// 편집 모드
    @State private var editMode: EditMode = .inactive
    
    /// 선택된 항목들 (다중 선택용)
    @State private var selectedSecrets: Set<UUID> = []
    
    /// 정렬 옵션
    @State private var sortOption: SecretItem.SortOption = .modifiedAt
    @State private var sortDirection: SecretItem.SortDirection = .descending
    
    /// 필터 조건
    @State private var filterCriteria = SecretItem.FilterCriteria.default
    
    // MARK: - 바디
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.secrets.isEmpty && searchText.isEmpty {
                    emptyStateView
                } else {
                    secretListView
                }
            }
            .navigationTitle("SecureVault")
            .searchable(text: $searchText, prompt: "비밀 항목 검색")
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingAddSheet) {
                AddSecretView { newSecret in
                    viewModel.addSecret(newSecret)
                }
            }
            .sheet(item: $selectedSecret) { secret in
                SecretDetailView(secret: secret) { updatedSecret in
                    viewModel.updateSecret(updatedSecret)
                } onDelete: {
                    viewModel.deleteSecret(id: secret.id)
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterSheetView(
                    criteria: $filterCriteria,
                    sortOption: $sortOption,
                    sortDirection: $sortDirection,
                    availableTags: viewModel.allTags
                )
            }
            .alert("오류", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "알 수 없는 오류가 발생했습니다")
            }
            .environment(\.editMode, $editMode)
            .onChange(of: searchText) { _, newValue in
                filterCriteria.searchQuery = newValue
            }
        }
    }
    
    // MARK: - 비밀 목록
    
    private var secretListView: some View {
        List(selection: $selectedSecrets) {
            // 통계 헤더 (편집 모드가 아닐 때만)
            if editMode == .inactive && !filteredSecrets.isEmpty {
                statisticsHeader
            }
            
            // 고정된 항목
            let pinned = filteredSecrets.filter { $0.isPinned }
            if !pinned.isEmpty {
                Section {
                    ForEach(pinned) { secret in
                        SecretRowView(secret: secret)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                handleSecretTap(secret)
                            }
                            .swipeActions(edge: .trailing) {
                                deleteSwipeAction(for: secret)
                            }
                            .swipeActions(edge: .leading) {
                                favoriteSwipeAction(for: secret)
                                pinSwipeAction(for: secret)
                            }
                    }
                } header: {
                    Label("고정됨", systemImage: "pin.fill")
                }
            }
            
            // 카테고리별 섹션
            ForEach(SecretItem.Category.allCases, id: \.self) { category in
                let categorySecrets = filteredSecrets.filter {
                    $0.category == category && !$0.isPinned
                }
                
                if !categorySecrets.isEmpty {
                    Section {
                        ForEach(categorySecrets) { secret in
                            SecretRowView(secret: secret)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    handleSecretTap(secret)
                                }
                                .swipeActions(edge: .trailing) {
                                    deleteSwipeAction(for: secret)
                                }
                                .swipeActions(edge: .leading) {
                                    favoriteSwipeAction(for: secret)
                                    pinSwipeAction(for: secret)
                                }
                        }
                    } header: {
                        Label(category.rawValue, systemImage: category.iconName)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            viewModel.loadSecrets()
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("비밀이 없습니다", systemImage: "lock.shield")
        } description: {
            Text("첫 번째 비밀을 추가하여\n안전하게 보관하세요")
        } actions: {
            Button {
                showingAddSheet = true
            } label: {
                Label("비밀 추가", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    // MARK: - 통계 헤더
    
    private var statisticsHeader: some View {
        Section {
            HStack(spacing: 16) {
                StatBadge(
                    value: filteredSecrets.count,
                    label: "전체",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                StatBadge(
                    value: filteredSecrets.filter { $0.isFavorite }.count,
                    label: "즐겨찾기",
                    icon: "star.fill",
                    color: .yellow
                )
                
                StatBadge(
                    value: filteredSecrets.filter { $0.isEncrypted }.count,
                    label: "암호화됨",
                    icon: "lock.fill",
                    color: .green
                )
            }
            .padding(.vertical, 8)
        }
        .listRowBackground(Color.clear)
    }
    
    // MARK: - 툴바
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            if editMode == .active {
                Button("완료") {
                    editMode = .inactive
                    selectedSecrets.removeAll()
                }
            } else {
                Menu {
                    Button {
                        showingFilters = true
                    } label: {
                        Label("필터", systemImage: "line.3.horizontal.decrease.circle")
                    }
                    
                    Divider()
                    
                    Picker("정렬", selection: $sortOption) {
                        ForEach(SecretItem.SortOption.allCases) { option in
                            Label(option.rawValue, systemImage: option.iconName)
                                .tag(option)
                        }
                    }
                    
                    Picker("방향", selection: $sortDirection) {
                        Text("오름차순").tag(SecretItem.SortDirection.ascending)
                        Text("내림차순").tag(SecretItem.SortDirection.descending)
                    }
                } label: {
                    Image(systemName: filterCriteria.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            HStack(spacing: 16) {
                if editMode == .inactive {
                    Button {
                        editMode = .active
                    } label: {
                        Image(systemName: "checkmark.circle")
                    }
                }
                
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        
        // 다중 선택 시 하단 툴바
        if editMode == .active && !selectedSecrets.isEmpty {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Button(role: .destructive) {
                        viewModel.deleteSecrets(ids: selectedSecrets)
                        selectedSecrets.removeAll()
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                    
                    Spacer()
                    
                    Text("\(selectedSecrets.count)개 선택됨")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        // 내보내기 등 추가 액션
                    } label: {
                        Label("더보기", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    // MARK: - 스와이프 액션
    
    private func deleteSwipeAction(for secret: SecretItem) -> some View {
        Button(role: .destructive) {
            viewModel.deleteSecret(id: secret.id)
        } label: {
            Label("삭제", systemImage: "trash")
        }
    }
    
    private func favoriteSwipeAction(for secret: SecretItem) -> some View {
        Button {
            var updated = secret
            updated.isFavorite.toggle()
            viewModel.updateSecret(updated)
        } label: {
            Label(
                secret.isFavorite ? "즐겨찾기 해제" : "즐겨찾기",
                systemImage: secret.isFavorite ? "star.slash" : "star"
            )
        }
        .tint(.yellow)
    }
    
    private func pinSwipeAction(for secret: SecretItem) -> some View {
        Button {
            var updated = secret
            updated.isPinned.toggle()
            viewModel.updateSecret(updated)
        } label: {
            Label(
                secret.isPinned ? "고정 해제" : "고정",
                systemImage: secret.isPinned ? "pin.slash" : "pin"
            )
        }
        .tint(.orange)
    }
    
    // MARK: - 헬퍼
    
    /// 필터 및 정렬 적용된 비밀 목록
    private var filteredSecrets: [SecretItem] {
        viewModel.secrets
            .filtered(by: filterCriteria)
            .sorted(by: sortOption, direction: sortDirection)
    }
    
    /// 항목 탭 처리
    private func handleSecretTap(_ secret: SecretItem) {
        if editMode == .active {
            if selectedSecrets.contains(secret.id) {
                selectedSecrets.remove(secret.id)
            } else {
                selectedSecrets.insert(secret.id)
            }
        } else {
            selectedSecret = secret
            viewModel.recordAccess(for: secret.id)
        }
    }
}

// MARK: - 비밀 항목 행 뷰
struct SecretRowView: View {
    let secret: SecretItem
    
    var body: some View {
        HStack(spacing: 12) {
            // 카테고리 아이콘
            ZStack {
                Circle()
                    .fill(secret.category.color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: secret.category.iconName)
                    .font(.system(size: 18))
                    .foregroundStyle(secret.category.color)
            }
            
            // 제목 및 정보
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(secret.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if secret.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.yellow)
                    }
                    
                    if secret.isEncrypted {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    }
                }
                
                Text(secret.maskedContentPreview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // 상태 표시
            VStack(alignment: .trailing, spacing: 4) {
                if secret.isExpired {
                    Label("만료됨", systemImage: "exclamationmark.circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.red)
                } else if secret.isExpiringSoon {
                    Label("만료 예정", systemImage: "clock.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
                
                Text(secret.modifiedAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 통계 배지
struct StatBadge: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text("\(value)")
                    .font(.headline)
            }
            .foregroundStyle(color)
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 필터 시트 뷰
struct FilterSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var criteria: SecretItem.FilterCriteria
    @Binding var sortOption: SecretItem.SortOption
    @Binding var sortDirection: SecretItem.SortDirection
    let availableTags: Set<String>
    
    var body: some View {
        NavigationStack {
            Form {
                // 카테고리 필터
                Section("카테고리") {
                    ForEach(SecretItem.Category.allCases) { category in
                        Toggle(isOn: Binding(
                            get: { criteria.categories.contains(category) },
                            set: { isOn in
                                if isOn {
                                    criteria.categories.insert(category)
                                } else {
                                    criteria.categories.remove(category)
                                }
                            }
                        )) {
                            Label(category.rawValue, systemImage: category.iconName)
                        }
                    }
                }
                
                // 상태 필터
                Section("상태") {
                    Toggle("즐겨찾기만", isOn: $criteria.isFavoriteOnly)
                    Toggle("고정된 항목만", isOn: $criteria.isPinnedOnly)
                    Toggle("보관함 포함", isOn: $criteria.includeArchived)
                    Toggle("만료된 항목만", isOn: $criteria.showExpiredOnly)
                    Toggle("만료 예정만", isOn: $criteria.showExpiringSoonOnly)
                }
                
                // 태그 필터
                if !availableTags.isEmpty {
                    Section("태그") {
                        ForEach(Array(availableTags).sorted(), id: \.self) { tag in
                            Toggle(isOn: Binding(
                                get: { criteria.tags.contains(tag) },
                                set: { isOn in
                                    if isOn {
                                        criteria.tags.insert(tag)
                                    } else {
                                        criteria.tags.remove(tag)
                                    }
                                }
                            )) {
                                Label(tag, systemImage: "tag")
                            }
                        }
                    }
                }
                
                // 정렬
                Section("정렬") {
                    Picker("정렬 기준", selection: $sortOption) {
                        ForEach(SecretItem.SortOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    
                    Picker("정렬 방향", selection: $sortDirection) {
                        Text("오름차순").tag(SecretItem.SortDirection.ascending)
                        Text("내림차순").tag(SecretItem.SortDirection.descending)
                    }
                }
                
                // 초기화
                Section {
                    Button("필터 초기화", role: .destructive) {
                        criteria = .default
                    }
                }
            }
            .navigationTitle("필터 및 정렬")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - ViewModel
@MainActor
class VaultListViewModel: ObservableObject {
    @Published var secrets: [SecretItem] = []
    @Published var showError = false
    @Published var errorMessage: String?
    
    private let keychainService = KeychainService.shared
    
    var allTags: Set<String> {
        secrets.allTags
    }
    
    init() {
        loadSecrets()
    }
    
    func loadSecrets() {
        do {
            secrets = try keychainService.loadSecrets()
        } catch let error as SecurityError {
            showError(error)
        } catch {
            showError(SecurityError.unknown(underlying: error))
        }
    }
    
    func addSecret(_ secret: SecretItem) {
        do {
            _ = try keychainService.addSecret(secret)
            secrets.append(secret)
        } catch let error as SecurityError {
            showError(error)
        } catch {
            showError(SecurityError.unknown(underlying: error))
        }
    }
    
    func updateSecret(_ secret: SecretItem) {
        do {
            _ = try keychainService.updateSecret(secret)
            if let index = secrets.firstIndex(where: { $0.id == secret.id }) {
                secrets[index] = secret
            }
        } catch let error as SecurityError {
            showError(error)
        } catch {
            showError(SecurityError.unknown(underlying: error))
        }
    }
    
    func deleteSecret(id: UUID) {
        do {
            try keychainService.deleteSecret(id: id)
            secrets.removeAll { $0.id == id }
        } catch let error as SecurityError {
            showError(error)
        } catch {
            showError(SecurityError.unknown(underlying: error))
        }
    }
    
    func deleteSecrets(ids: Set<UUID>) {
        do {
            try keychainService.deleteSecrets(ids: ids)
            secrets.removeAll { ids.contains($0.id) }
        } catch let error as SecurityError {
            showError(error)
        } catch {
            showError(SecurityError.unknown(underlying: error))
        }
    }
    
    func recordAccess(for id: UUID) {
        try? keychainService.recordAccess(for: id)
    }
    
    private func showError(_ error: SecurityError) {
        errorMessage = error.errorDescription
        showError = true
    }
}

// MARK: - 미리보기
#Preview {
    VaultListView()
        .environmentObject(BiometricService.authenticatedPreview)
}
