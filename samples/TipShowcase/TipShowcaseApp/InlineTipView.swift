import SwiftUI
import TipKit

// MARK: - 인라인 팁 예제 뷰
// TipView를 사용하여 화면에 직접 팁을 삽입하는 방법을 시연합니다.
// 인라인 팁은 화면의 일부로 자연스럽게 표시됩니다.

struct InlineTipView: View {
    
    // MARK: - 팁 인스턴스
    
    /// 즐겨찾기 팁
    private let favoriteTip = FavoriteTip()
    
    /// 검색 팁
    private let searchTip = SearchTip()
    
    /// 필터 팁
    private let filterTip = FilterTip()
    
    /// 정렬 팁
    private let sortingTip = SortingTip()
    
    /// 피드백 팁
    private let feedbackTip = FeedbackTip()
    
    // MARK: - 상태
    
    @State private var isFavorite = false
    @State private var searchText = ""
    @State private var selectedFilter = FilterOption.all
    @State private var selectedSort = SortOption.newest
    @State private var showActionResult = false
    @State private var actionResultMessage = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - 소개 섹션
                    introSection
                    
                    // MARK: - 기본 인라인 팁
                    basicTipSection
                    
                    // MARK: - 검색 팁 섹션
                    searchTipSection
                    
                    // MARK: - 필터 및 정렬 섹션
                    filterSortSection
                    
                    // MARK: - 액션 팁 섹션
                    actionTipSection
                    
                    // MARK: - 팁 스타일 커스터마이징
                    customStyleSection
                    
                    // MARK: - API 설명
                    apiExplanationSection
                }
                .padding()
            }
            .navigationTitle("인라인 팁")
            .alert("액션 결과", isPresented: $showActionResult) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(actionResultMessage)
            }
        }
    }
    
    // MARK: - 소개 섹션
    
    private var introSection: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                FeatureRow(
                    icon: "text.bubble.fill",
                    title: "TipView",
                    description: "화면에 인라인으로 팁을 표시합니다. 팁은 UI의 일부로 자연스럽게 통합됩니다.",
                    iconColor: .blue
                )
                
                Divider()
                
                Text("인라인 팁은 사용자의 현재 컨텍스트에서 관련 기능을 소개하는 데 적합합니다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 기본 인라인 팁 섹션
    
    private var basicTipSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("기본 인라인 팁", subtitle: "TipView 기본 사용법")
            
            // 즐겨찾기 팁
            TipView(favoriteTip)
                .tipBackground(Color.blue.opacity(0.1))
            
            // 연관 버튼
            HStack {
                Spacer()
                
                Button {
                    isFavorite.toggle()
                    
                    // 팁 무효화 - actionPerformed 이유 사용
                    if isFavorite {
                        favoriteTip.invalidate(reason: .actionPerformed)
                        
                        // 이벤트 기록
                        Task {
                            await TipEventRecorder.recordFavoriteToggled()
                        }
                        
                        // 파라미터 업데이트
                        FeatureDiscoveryParameters.hasUsedFavorites = true
                    }
                } label: {
                    Label(
                        isFavorite ? "즐겨찾기됨" : "즐겨찾기",
                        systemImage: isFavorite ? "heart.fill" : "heart"
                    )
                    .font(.headline)
                    .foregroundStyle(isFavorite ? .red : .primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isFavorite ? Color.red : Color.gray, lineWidth: 1)
                    )
                }
                
                Spacer()
            }
        }
    }
    
    // MARK: - 검색 팁 섹션
    
    private var searchTipSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("검색 팁", subtitle: "검색 기능 발견 안내")
            
            // 검색 팁
            TipView(searchTip)
                .tipBackground(Color.purple.opacity(0.1))
            
            // 검색 필드
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("검색어를 입력하세요", text: $searchText)
                    .textFieldStyle(.plain)
                    .onSubmit {
                        performSearch()
                    }
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 검색 버튼
            Button("검색") {
                performSearch()
            }
            .buttonStyle(.borderedProminent)
            .disabled(searchText.isEmpty)
        }
    }
    
    // MARK: - 필터 및 정렬 섹션
    
    private var filterSortSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("필터 & 정렬 팁", subtitle: "목록 정리 기능 안내")
            
            // 필터 팁
            TipView(filterTip)
                .tipBackground(Color.orange.opacity(0.1))
            
            // 정렬 팁
            TipView(sortingTip)
                .tipBackground(Color.green.opacity(0.1))
            
            // 필터 선택
            HStack(spacing: 12) {
                ForEach(FilterOption.allCases) { option in
                    FilterChip(
                        title: option.title,
                        isSelected: selectedFilter == option,
                        action: {
                            selectedFilter = option
                            filterTip.invalidate(reason: .actionPerformed)
                            FeatureDiscoveryParameters.hasUsedFilters = true
                            
                            Task {
                                await TipEventRecorder.recordFilterApplied()
                            }
                        }
                    )
                }
            }
            
            // 정렬 선택
            Menu {
                ForEach(SortOption.allCases) { option in
                    Button {
                        selectedSort = option
                        sortingTip.invalidate(reason: .actionPerformed)
                        FeatureDiscoveryParameters.hasUsedSorting = true
                    } label: {
                        HStack {
                            Text(option.title)
                            if selectedSort == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(selectedSort.title)
                    Spacer()
                    Image(systemName: "chevron.down")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
    
    // MARK: - 액션 팁 섹션
    
    private var actionTipSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("액션 버튼 팁", subtitle: "사용자 선택이 가능한 팁")
            
            // 피드백 팁 (액션 포함)
            TipView(feedbackTip) { action in
                handleTipAction(action)
            }
            .tipBackground(Color.indigo.opacity(0.1))
            
            // 코드 예제
            CodeSnippet(
                """
                TipView(feedbackTip) { action in
                    switch action.id {
                    case "rate":
                        openAppStore()
                    case "feedback":
                        showFeedbackForm()
                    case "later":
                        dismissTip()
                    default:
                        break
                    }
                }
                """
            )
        }
    }
    
    // MARK: - 커스텀 스타일 섹션
    
    private var customStyleSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("팁 스타일 커스터마이징", subtitle: "tipBackground 수정자 사용")
            
            // 다양한 배경 스타일 예제
            VStack(spacing: 12) {
                // 기본 스타일
                ExampleTipView(
                    title: "기본 스타일",
                    icon: "star.fill",
                    backgroundColor: .clear
                )
                
                // 파란색 배경
                ExampleTipView(
                    title: "파란색 배경",
                    icon: "heart.fill",
                    backgroundColor: .blue.opacity(0.1)
                )
                
                // 그라데이션 배경 (Material)
                ExampleTipView(
                    title: "Material 배경",
                    icon: "sparkles",
                    backgroundColor: nil,
                    useMaterial: true
                )
            }
            
            // 코드 예제
            CodeSnippet(
                """
                TipView(myTip)
                    .tipBackground(Color.blue.opacity(0.1))
                
                // 또는 Material 사용
                TipView(myTip)
                    .tipBackground(.ultraThinMaterial)
                """
            )
        }
    }
    
    // MARK: - API 설명 섹션
    
    private var apiExplanationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader("관련 TipKit API", subtitle: "인라인 팁에 사용되는 주요 API")
            
            CardContainer {
                VStack(alignment: .leading, spacing: 16) {
                    APIRow(
                        name: "TipView",
                        description: "팁을 화면에 표시하는 SwiftUI 뷰"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: ".tipBackground()",
                        description: "팁의 배경 스타일을 커스터마이징"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "Tip.invalidate(reason:)",
                        description: "팁을 프로그래매틱하게 닫기"
                    )
                    
                    Divider()
                    
                    APIRow(
                        name: "Tip.actions",
                        description: "팁에 액션 버튼 추가"
                    )
                }
            }
        }
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 검색 실행
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        // 팁 무효화
        searchTip.invalidate(reason: .actionPerformed)
        
        // 파라미터 업데이트
        FeatureDiscoveryParameters.hasUsedSearch = true
        
        // 이벤트 기록
        Task {
            await TipEventRecorder.recordSearchPerformed()
        }
        
        // 결과 표시
        actionResultMessage = "'\(searchText)' 검색 완료!"
        showActionResult = true
    }
    
    /// 팁 액션 처리
    private func handleTipAction(_ action: Tip.Action) {
        switch action.id {
        case "rate":
            actionResultMessage = "앱스토어 별점 페이지로 이동합니다."
            TipStatistics.shared.recordActionClick()
        case "feedback":
            actionResultMessage = "피드백 양식을 표시합니다."
            TipStatistics.shared.recordActionClick()
        case "later":
            actionResultMessage = "나중에 다시 알려드릴게요."
            TipStatistics.shared.recordDismiss()
        default:
            actionResultMessage = "알 수 없는 액션: \(action.id)"
        }
        
        showActionResult = true
        feedbackTip.invalidate(reason: .actionPerformed)
    }
}

// MARK: - 필터 옵션

enum FilterOption: String, CaseIterable, Identifiable {
    case all = "전체"
    case favorites = "즐겨찾기"
    case recent = "최근"
    
    var id: String { rawValue }
    var title: String { rawValue }
}

// MARK: - 정렬 옵션

enum SortOption: String, CaseIterable, Identifiable {
    case newest = "최신순"
    case oldest = "오래된순"
    case name = "이름순"
    case popular = "인기순"
    
    var id: String { rawValue }
    var title: String { rawValue }
}

// MARK: - 필터 칩 뷰

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color(.secondarySystemBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - 예제 팁 뷰

struct ExampleTipView: View {
    let title: String
    let icon: String
    let backgroundColor: Color?
    var useMaterial: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("팁 스타일 예제입니다")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background {
            if useMaterial {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            } else if let color = backgroundColor {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
        }
    }
}

// MARK: - API 설명 행

struct APIRow: View {
    let name: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundStyle(.blue)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - 프리뷰

#Preview {
    InlineTipView()
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
