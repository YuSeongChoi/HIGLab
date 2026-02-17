// SearchView.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// 검색 뷰: PDF 내 텍스트 검색

import SwiftUI
import PDFKit

// MARK: - 검색 뷰
struct SearchView: View {
    
    // MARK: - 속성
    
    /// PDF 문서
    let pdfDocument: PDFDocument
    
    /// 검색 결과 선택 콜백
    let onSelect: (PDFSelection) -> Void
    
    // MARK: - 상태
    
    /// 검색어
    @State private var searchText = ""
    
    /// 검색 결과
    @State private var searchResults: [SearchResult] = []
    
    /// 검색 중 여부
    @State private var isSearching = false
    
    /// 검색 작업
    @State private var searchTask: Task<Void, Never>?
    
    /// 현재 선택된 결과 인덱스
    @State private var selectedResultIndex: Int?
    
    // MARK: - 환경
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 뷰 본문
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 검색 필드
                searchField
                
                Divider()
                
                // 검색 결과 또는 상태 메시지
                resultContent
            }
            .navigationTitle("검색")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
        .onDisappear {
            // 검색 취소
            searchTask?.cancel()
        }
    }
    
    // MARK: - 검색 필드
    
    /// 검색 입력 필드
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            
            TextField("검색어를 입력하세요", text: $searchText)
                .textFieldStyle(.plain)
                #if os(iOS)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                #endif
                .onSubmit {
                    performSearch()
                }
                .onChange(of: searchText) { _, newValue in
                    // 디바운스 검색
                    debounceSearch(query: newValue)
                }
            
            // 검색 중 표시 또는 지우기 버튼
            if isSearching {
                ProgressView()
                    .scaleEffect(0.8)
            } else if !searchText.isEmpty {
                Button {
                    searchText = ""
                    searchResults = []
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    // MARK: - 결과 콘텐츠
    
    /// 검색 결과 표시 영역
    @ViewBuilder
    private var resultContent: some View {
        if searchText.isEmpty {
            // 초기 상태
            emptyStateView(
                icon: "text.magnifyingglass",
                title: "텍스트 검색",
                message: "PDF 문서 내의 텍스트를 검색합니다"
            )
        } else if isSearching {
            // 검색 중
            VStack(spacing: 16) {
                ProgressView()
                Text("검색 중...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if searchResults.isEmpty {
            // 결과 없음
            emptyStateView(
                icon: "magnifyingglass",
                title: "결과 없음",
                message: "'\(searchText)'에 대한 검색 결과가 없습니다"
            )
        } else {
            // 결과 목록
            resultListView
        }
    }
    
    // MARK: - 빈 상태 뷰
    
    /// 빈 상태 표시
    private func emptyStateView(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.headline)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - 결과 목록
    
    /// 검색 결과 리스트
    private var resultListView: some View {
        VStack(spacing: 0) {
            // 결과 개수
            HStack {
                Text("\(searchResults.count)개의 결과")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // 이전/다음 버튼
                if let selectedIndex = selectedResultIndex {
                    HStack(spacing: 16) {
                        Button {
                            navigateToPrevious()
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        .disabled(selectedIndex == 0)
                        
                        Text("\(selectedIndex + 1)/\(searchResults.count)")
                            .font(.caption)
                            .monospacedDigit()
                        
                        Button {
                            navigateToNext()
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .disabled(selectedIndex >= searchResults.count - 1)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            
            // 결과 리스트
            List(Array(searchResults.enumerated()), id: \.element.id) { index, result in
                Button {
                    selectedResultIndex = index
                    onSelect(result.selection)
                } label: {
                    SearchResultRow(result: result, searchText: searchText)
                }
                .buttonStyle(.plain)
                .listRowBackground(
                    selectedResultIndex == index
                        ? Color.accentColor.opacity(0.1)
                        : Color.clear
                )
            }
            .listStyle(.plain)
        }
    }
    
    // MARK: - 검색 로직
    
    /// 디바운스 검색 (입력 후 0.3초 대기)
    private func debounceSearch(query: String) {
        searchTask?.cancel()
        
        guard !query.isEmpty else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3초
            
            if !Task.isCancelled {
                await MainActor.run {
                    performSearch()
                }
            }
        }
    }
    
    /// 검색 수행
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        searchResults = []
        selectedResultIndex = nil
        
        Task {
            let results = await searchDocument(for: searchText)
            
            await MainActor.run {
                searchResults = results
                isSearching = false
                
                // 첫 번째 결과 자동 선택
                if !results.isEmpty {
                    selectedResultIndex = 0
                }
            }
        }
    }
    
    /// 문서 검색 (백그라운드)
    private func searchDocument(for query: String) async -> [SearchResult] {
        let selections = pdfDocument.findString(
            query,
            withOptions: .caseInsensitive
        )
        
        // 최대 결과 수 제한
        let limitedSelections = selections.prefix(AppConstants.maxSearchResults)
        
        return limitedSelections.enumerated().compactMap { index, selection in
            guard let page = selection.pages.first,
                  let pageIndex = pdfDocument.index(for: page) else { return nil }
            
            // 컨텍스트 추출 (선택 주변 텍스트)
            let context = extractContext(for: selection, on: page)
            
            return SearchResult(
                id: index,
                selection: selection,
                pageIndex: pageIndex,
                matchedText: selection.string ?? query,
                context: context
            )
        }
    }
    
    /// 선택 영역 주변 컨텍스트 추출
    private func extractContext(for selection: PDFSelection, on page: PDFPage) -> String {
        guard let pageText = page.string else { return "" }
        guard let matchedText = selection.string else { return "" }
        
        // 매칭 텍스트 위치 찾기
        if let range = pageText.range(of: matchedText, options: .caseInsensitive) {
            // 앞뒤 30자 추출
            let contextStart = pageText.index(
                range.lowerBound,
                offsetBy: -30,
                limitedBy: pageText.startIndex
            ) ?? pageText.startIndex
            
            let contextEnd = pageText.index(
                range.upperBound,
                offsetBy: 30,
                limitedBy: pageText.endIndex
            ) ?? pageText.endIndex
            
            var context = String(pageText[contextStart..<contextEnd])
            
            // 앞뒤 ... 추가
            if contextStart != pageText.startIndex {
                context = "..." + context
            }
            if contextEnd != pageText.endIndex {
                context = context + "..."
            }
            
            return context.replacingOccurrences(of: "\n", with: " ")
        }
        
        return ""
    }
    
    // MARK: - 네비게이션
    
    /// 이전 결과로 이동
    private func navigateToPrevious() {
        guard let current = selectedResultIndex, current > 0 else { return }
        selectedResultIndex = current - 1
        onSelect(searchResults[current - 1].selection)
    }
    
    /// 다음 결과로 이동
    private func navigateToNext() {
        guard let current = selectedResultIndex,
              current < searchResults.count - 1 else { return }
        selectedResultIndex = current + 1
        onSelect(searchResults[current + 1].selection)
    }
}

// MARK: - 검색 결과 모델
/// 검색 결과 항목
struct SearchResult: Identifiable {
    let id: Int
    let selection: PDFSelection
    let pageIndex: Int
    let matchedText: String
    let context: String
    
    /// 표시용 페이지 번호 (1-based)
    var displayPageNumber: Int {
        pageIndex + 1
    }
}

// MARK: - 검색 결과 행
/// 검색 결과 리스트 행
struct SearchResultRow: View {
    let result: SearchResult
    let searchText: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // 페이지 번호
            HStack {
                Image(systemName: "doc.text")
                    .foregroundStyle(.blue)
                
                Text("페이지 \(result.displayPageNumber)")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            // 컨텍스트 (매칭 부분 강조)
            highlightedText(result.context, highlight: searchText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
    
    /// 검색어 강조 텍스트
    private func highlightedText(_ text: String, highlight: String) -> Text {
        guard !highlight.isEmpty else { return Text(text) }
        
        var result = Text("")
        var remainingText = text
        
        while let range = remainingText.range(of: highlight, options: .caseInsensitive) {
            // 매칭 전 텍스트
            let before = String(remainingText[..<range.lowerBound])
            result = result + Text(before)
            
            // 매칭 텍스트 (강조)
            let matched = String(remainingText[range])
            result = result + Text(matched)
                .foregroundColor(.blue)
                .fontWeight(.semibold)
            
            // 나머지 텍스트
            remainingText = String(remainingText[range.upperBound...])
        }
        
        // 남은 텍스트 추가
        result = result + Text(remainingText)
        
        return result
    }
}

// MARK: - 프리뷰
#Preview {
    if let url = Bundle.main.url(forResource: "sample", withExtension: "pdf"),
       let document = PDFDocument(url: url) {
        SearchView(pdfDocument: document) { selection in
            print("Selected: \(selection)")
        }
    } else {
        Text("샘플 PDF 없음")
    }
}
