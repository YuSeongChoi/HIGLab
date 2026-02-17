// PDFViewerView.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// PDF 뷰어: 문서 표시, 페이지 이동, 확대/축소

import SwiftUI
import PDFKit

// MARK: - PDF 뷰어 뷰
struct PDFViewerView: View {
    
    // MARK: - 속성
    
    /// PDF 문서
    let pdfDocument: PDFDocument
    
    // MARK: - 환경 객체
    
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @EnvironmentObject var annotationManager: AnnotationManager
    
    // MARK: - 상태
    
    /// 현재 페이지 인덱스
    @State private var currentPageIndex = 0
    
    /// 확대 비율
    @State private var scaleFactor: CGFloat = 1.0
    
    /// 썸네일 패널 표시 여부
    @State private var showThumbnails = false
    
    /// 검색 패널 표시 여부
    @State private var showSearch = false
    
    /// 주석 도구 표시 여부
    @State private var showAnnotationTools = false
    
    /// 북마크 목록 표시 여부
    @State private var showBookmarks = false
    
    /// 페이지 이동 시트 표시 여부
    @State private var showGoToPage = false
    
    /// 이동할 페이지 번호 (텍스트 입력)
    @State private var goToPageText = ""
    
    // MARK: - 뷰 본문
    
    var body: some View {
        NavigationSplitView {
            // 사이드바: 썸네일 또는 북마크
            sidebarContent
                .navigationSplitViewColumnWidth(min: 150, ideal: 200, max: 250)
        } detail: {
            // 메인: PDF 뷰어
            mainContent
        }
        .toolbar {
            toolbarContent
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleThumbnailPanel)) { _ in
            showThumbnails.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleSearchPanel)) { _ in
            showSearch.toggle()
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleBookmark)) { _ in
            bookmarkManager.toggleBookmark(at: currentPageIndex)
        }
        .onReceive(NotificationCenter.default.publisher(for: .goToNextBookmark)) { _ in
            goToNextBookmark()
        }
        .onReceive(NotificationCenter.default.publisher(for: .goToPreviousBookmark)) { _ in
            goToPreviousBookmark()
        }
        .sheet(isPresented: $showSearch) {
            SearchView(pdfDocument: pdfDocument) { selection in
                goToSelection(selection)
                showSearch = false
            }
        }
        .sheet(isPresented: $showGoToPage) {
            goToPageSheet
        }
    }
    
    // MARK: - 사이드바 콘텐츠
    
    /// 사이드바 (썸네일/북마크)
    @ViewBuilder
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            // 탭 선택기
            Picker("보기", selection: $showBookmarks) {
                Text("썸네일").tag(false)
                Text("북마크").tag(true)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            // 콘텐츠
            if showBookmarks {
                bookmarkListView
            } else {
                ThumbnailView(
                    pdfDocument: pdfDocument,
                    currentPageIndex: $currentPageIndex
                )
            }
        }
    }
    
    // MARK: - 메인 콘텐츠
    
    /// 메인 PDF 뷰어
    private var mainContent: some View {
        VStack(spacing: 0) {
            // PDF 뷰
            PDFKitView(
                pdfDocument: pdfDocument,
                currentPageIndex: $currentPageIndex,
                scaleFactor: $scaleFactor,
                annotationManager: annotationManager
            )
            
            // 주석 도구 바
            if showAnnotationTools {
                annotationToolbar
            }
            
            // 하단 페이지 네비게이션
            pageNavigationBar
        }
    }
    
    // MARK: - 툴바
    
    /// 툴바 콘텐츠
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // 좌측: 뷰 옵션
        ToolbarItemGroup(placement: .primaryAction) {
            // 확대/축소
            Menu {
                ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0], id: \.self) { scale in
                    Button("\(Int(scale * 100))%") {
                        scaleFactor = scale
                    }
                }
            } label: {
                Label("\(Int(scaleFactor * 100))%", systemImage: "magnifyingglass")
            }
            
            // 북마크 토글
            Button {
                bookmarkManager.toggleBookmark(at: currentPageIndex)
            } label: {
                Label(
                    "북마크",
                    systemImage: bookmarkManager.isBookmarked(pageIndex: currentPageIndex)
                        ? "bookmark.fill"
                        : "bookmark"
                )
            }
            
            // 주석 도구
            Button {
                showAnnotationTools.toggle()
            } label: {
                Label("주석", systemImage: "pencil.tip.crop.circle")
            }
            
            // 검색
            Button {
                showSearch.toggle()
            } label: {
                Label("검색", systemImage: "magnifyingglass")
            }
        }
        
        // 제목
        ToolbarItem(placement: .principal) {
            VStack {
                Text(pdfDocument.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text("페이지 \(currentPageIndex + 1) / \(pdfDocument.pageCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 북마크 목록
    
    /// 북마크 리스트 뷰
    private var bookmarkListView: some View {
        Group {
            if bookmarkManager.bookmarks.isEmpty {
                ContentUnavailableView(
                    "북마크 없음",
                    systemImage: "bookmark",
                    description: Text("페이지에서 북마크 버튼을 눌러 추가하세요")
                )
            } else {
                List(bookmarkManager.bookmarks) { bookmark in
                    Button {
                        currentPageIndex = bookmark.pageIndex
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(bookmark.title)
                                .font(.headline)
                            
                            HStack {
                                Text("페이지 \(bookmark.displayPageNumber)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                Text(bookmark.formattedDate)
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                            
                            if let note = bookmark.note, !note.isEmpty {
                                Text(note)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) {
                            bookmarkManager.remove(id: bookmark.id)
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 주석 도구 바
    
    /// 주석 도구 바
    private var annotationToolbar: some View {
        AnnotationView(annotationManager: annotationManager)
            .padding()
            .background(.ultraThinMaterial)
    }
    
    // MARK: - 페이지 네비게이션 바
    
    /// 하단 페이지 네비게이션
    private var pageNavigationBar: some View {
        HStack {
            // 이전 페이지
            Button {
                goToPreviousPage()
            } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(currentPageIndex == 0)
            
            Spacer()
            
            // 페이지 번호 (탭하면 이동)
            Button {
                goToPageText = "\(currentPageIndex + 1)"
                showGoToPage = true
            } label: {
                Text("\(currentPageIndex + 1) / \(pdfDocument.pageCount)")
                    .font(.headline)
                    .monospacedDigit()
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // 다음 페이지
            Button {
                goToNextPage()
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(currentPageIndex >= pdfDocument.pageCount - 1)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
    
    // MARK: - 페이지 이동 시트
    
    /// 페이지 이동 시트
    private var goToPageSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("페이지 번호", text: $goToPageText)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                } header: {
                    Text("이동할 페이지 (1-\(pdfDocument.pageCount))")
                }
            }
            .navigationTitle("페이지 이동")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        showGoToPage = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("이동") {
                        if let page = Int(goToPageText),
                           page >= 1,
                           page <= pdfDocument.pageCount {
                            currentPageIndex = page - 1
                        }
                        showGoToPage = false
                    }
                }
            }
        }
        .presentationDetents([.height(200)])
    }
    
    // MARK: - 네비게이션 메서드
    
    /// 이전 페이지로 이동
    private func goToPreviousPage() {
        if currentPageIndex > 0 {
            currentPageIndex -= 1
        }
    }
    
    /// 다음 페이지로 이동
    private func goToNextPage() {
        if currentPageIndex < pdfDocument.pageCount - 1 {
            currentPageIndex += 1
        }
    }
    
    /// 다음 북마크로 이동
    private func goToNextBookmark() {
        if let nextPage = bookmarkManager.nextBookmark(after: currentPageIndex) {
            currentPageIndex = nextPage
        }
    }
    
    /// 이전 북마크로 이동
    private func goToPreviousBookmark() {
        if let prevPage = bookmarkManager.previousBookmark(before: currentPageIndex) {
            currentPageIndex = prevPage
        }
    }
    
    /// 선택 영역으로 이동
    private func goToSelection(_ selection: PDFSelection) {
        guard let page = selection.pages.first,
              let index = pdfDocument.index(for: page) else { return }
        currentPageIndex = index
    }
}

// MARK: - PDFKit 래퍼 뷰
/// PDFView를 SwiftUI에서 사용하기 위한 래퍼
#if os(iOS)
struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument
    @Binding var currentPageIndex: Int
    @Binding var scaleFactor: CGFloat
    let annotationManager: AnnotationManager
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.delegate = context.coordinator
        
        // 페이지 변경 알림 등록
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        
        return pdfView
    }
    
    func updateUIView(_ pdfView: PDFView, context: Context) {
        // 페이지 이동
        if let page = pdfDocument.page(at: currentPageIndex),
           pdfView.currentPage != page {
            pdfView.go(to: page)
        }
        
        // 확대 비율 적용
        pdfView.scaleFactor = scaleFactor * pdfView.scaleFactorForSizeToFit
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        var parent: PDFKitView
        
        init(_ parent: PDFKitView) {
            self.parent = parent
        }
        
        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let currentPage = pdfView.currentPage,
                  let index = pdfView.document?.index(for: currentPage) else { return }
            
            DispatchQueue.main.async {
                self.parent.currentPageIndex = index
            }
        }
    }
}
#elseif os(macOS)
struct PDFKitView: NSViewRepresentable {
    let pdfDocument: PDFDocument
    @Binding var currentPageIndex: Int
    @Binding var scaleFactor: CGFloat
    let annotationManager: AnnotationManager
    
    func makeNSView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = pdfDocument
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.delegate = context.coordinator
        
        // 페이지 변경 알림 등록
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(Coordinator.pageChanged(_:)),
            name: .PDFViewPageChanged,
            object: pdfView
        )
        
        return pdfView
    }
    
    func updateNSView(_ pdfView: PDFView, context: Context) {
        // 페이지 이동
        if let page = pdfDocument.page(at: currentPageIndex),
           pdfView.currentPage != page {
            pdfView.go(to: page)
        }
        
        // 확대 비율 적용
        pdfView.scaleFactor = scaleFactor * pdfView.scaleFactorForSizeToFit
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PDFViewDelegate {
        var parent: PDFKitView
        
        init(_ parent: PDFKitView) {
            self.parent = parent
        }
        
        @objc func pageChanged(_ notification: Notification) {
            guard let pdfView = notification.object as? PDFView,
                  let currentPage = pdfView.currentPage,
                  let index = pdfView.document?.index(for: currentPage) else { return }
            
            DispatchQueue.main.async {
                self.parent.currentPageIndex = index
            }
        }
    }
}
#endif

// MARK: - 프리뷰
#Preview {
    // 샘플 PDF로 프리뷰
    if let url = Bundle.main.url(forResource: "sample", withExtension: "pdf"),
       let document = PDFDocument(url: url) {
        PDFViewerView(pdfDocument: document)
            .environmentObject(BookmarkManager())
            .environmentObject(AnnotationManager())
    } else {
        Text("샘플 PDF 없음")
    }
}
