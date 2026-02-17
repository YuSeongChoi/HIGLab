// ContentView.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// 메인 콘텐츠 뷰: 파일 선택 및 뷰어 표시

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

// MARK: - 메인 콘텐츠 뷰
struct ContentView: View {
    
    // MARK: - 환경 객체
    
    @EnvironmentObject var bookmarkManager: BookmarkManager
    @EnvironmentObject var annotationManager: AnnotationManager
    
    // MARK: - 상태
    
    /// 현재 열린 PDF 문서
    @State private var pdfDocument: PDFDocument?
    
    /// 파일 선택 시트 표시 여부
    @State private var isShowingFilePicker = false
    
    /// 드래그 앤 드롭 강조 표시
    @State private var isDropTargeted = false
    
    /// 로딩 상태
    @State private var isLoading = false
    
    /// 에러 메시지
    @State private var errorMessage: String?
    
    /// 에러 알림 표시 여부
    @State private var isShowingError = false
    
    // MARK: - 뷰 본문
    
    var body: some View {
        Group {
            if let document = pdfDocument {
                // PDF 뷰어 표시
                PDFViewerView(pdfDocument: document)
            } else {
                // 파일 선택 화면
                fileSelectionView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .openDocument)) { notification in
            // macOS 메뉴에서 파일 열기
            if let url = notification.object as? URL {
                loadDocument(from: url)
            }
        }
        .alert("오류", isPresented: $isShowingError) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "알 수 없는 오류가 발생했습니다.")
        }
    }
    
    // MARK: - 파일 선택 뷰
    
    /// 초기 파일 선택 화면
    private var fileSelectionView: some View {
        VStack(spacing: 24) {
            // 앱 아이콘 및 제목
            VStack(spacing: 12) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)
                
                Text("PDFReader")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("PDF 파일을 열어 읽기, 검색, 주석 달기")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // 드래그 앤 드롭 영역
            dropZone
            
            // 파일 선택 버튼
            Button {
                isShowingFilePicker = true
            } label: {
                Label("PDF 파일 선택", systemImage: "folder")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            
            // 최근 파일 목록
            recentFilesSection
        }
        .padding(40)
        .fileImporter(
            isPresented: $isShowingFilePicker,
            allowedContentTypes: [.pdf],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .overlay {
            if isLoading {
                loadingOverlay
            }
        }
    }
    
    // MARK: - 드롭 영역
    
    /// 드래그 앤 드롭 영역
    private var dropZone: some View {
        RoundedRectangle(cornerRadius: 16)
            .strokeBorder(
                isDropTargeted ? Color.blue : Color.gray.opacity(0.4),
                style: StrokeStyle(lineWidth: 2, dash: [8])
            )
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isDropTargeted ? Color.blue.opacity(0.1) : Color.clear)
            )
            .frame(width: 300, height: 150)
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "arrow.down.doc")
                        .font(.system(size: 32))
                        .foregroundStyle(isDropTargeted ? .blue : .gray)
                    
                    Text("PDF 파일을 여기에 드롭")
                        .font(.subheadline)
                        .foregroundStyle(isDropTargeted ? .blue : .secondary)
                }
            }
            .onDrop(of: [.pdf, .fileURL], isTargeted: $isDropTargeted) { providers in
                handleDrop(providers: providers)
            }
    }
    
    // MARK: - 로딩 오버레이
    
    /// 로딩 중 표시
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                
                Text("PDF 로딩 중...")
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .ignoresSafeArea()
    }
    
    // MARK: - 최근 파일 섹션
    
    /// 최근 열어본 파일 목록
    private var recentFilesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            let recentFiles = RecentFilesManager.shared.recentFiles
            
            if !recentFiles.isEmpty {
                Text("최근 파일")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                ForEach(recentFiles.prefix(5), id: \.path) { url in
                    Button {
                        loadDocument(from: url)
                    } label: {
                        HStack {
                            Image(systemName: "doc.fill")
                                .foregroundStyle(.blue)
                            
                            Text(url.lastPathComponent)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .frame(maxWidth: 300)
    }
    
    // MARK: - 파일 처리 메서드
    
    /// 파일 임포터 결과 처리
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            if let url = urls.first {
                loadDocument(from: url)
            }
        case .failure(let error):
            showError("파일을 열 수 없습니다: \(error.localizedDescription)")
        }
    }
    
    /// 드롭 처리
    private func handleDrop(providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first else { return false }
        
        // PDF 파일 타입 확인
        if provider.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.pdf.identifier, options: nil) { item, error in
                DispatchQueue.main.async {
                    if let error = error {
                        showError("파일 로드 실패: \(error.localizedDescription)")
                        return
                    }
                    
                    if let data = item as? Data {
                        loadDocument(from: data)
                    } else if let url = item as? URL {
                        loadDocument(from: url)
                    }
                }
            }
            return true
        }
        
        // 파일 URL 처리
        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, error in
                DispatchQueue.main.async {
                    if let error = error {
                        showError("파일 로드 실패: \(error.localizedDescription)")
                        return
                    }
                    
                    if let urlData = item as? Data,
                       let url = URL(dataRepresentation: urlData, relativeTo: nil) {
                        loadDocument(from: url)
                    }
                }
            }
            return true
        }
        
        return false
    }
    
    /// URL에서 문서 로드
    private func loadDocument(from url: URL) {
        isLoading = true
        
        // 보안 스코프 접근 시작
        let shouldStopAccessing = url.startAccessingSecurityScopedResource()
        
        defer {
            if shouldStopAccessing {
                url.stopAccessingSecurityScopedResource()
            }
            isLoading = false
        }
        
        // PDF 문서 로드
        guard let document = PDFDocument(url: url) else {
            showError("PDF 파일을 읽을 수 없습니다.")
            return
        }
        
        // 상태 업데이트
        pdfDocument = document
        annotationManager.pdfDocument = document
        bookmarkManager.loadBookmarks(for: url)
        
        // 최근 파일에 추가
        RecentFilesManager.shared.addRecentFile(url)
    }
    
    /// Data에서 문서 로드
    private func loadDocument(from data: Data) {
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        guard let document = PDFDocument(data: data) else {
            showError("PDF 데이터를 읽을 수 없습니다.")
            return
        }
        
        pdfDocument = document
        annotationManager.pdfDocument = document
    }
    
    /// 에러 표시
    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
    }
}

// MARK: - 최근 파일 관리자
/// 최근 열어본 파일 목록 관리
class RecentFilesManager {
    static let shared = RecentFilesManager()
    
    private let key = "PDFReader.RecentFiles"
    private let maxFiles = AppConstants.maxRecentFiles
    
    private init() {}
    
    /// 최근 파일 목록
    var recentFiles: [URL] {
        guard let bookmarks = UserDefaults.standard.array(forKey: key) as? [Data] else {
            return []
        }
        
        return bookmarks.compactMap { data in
            var isStale = false
            return try? URL(
                resolvingBookmarkData: data,
                options: [],
                relativeTo: nil,
                bookmarkDataIsStale: &isStale
            )
        }
    }
    
    /// 최근 파일에 추가
    func addRecentFile(_ url: URL) {
        var files = recentFiles
        
        // 중복 제거
        files.removeAll { $0 == url }
        
        // 맨 앞에 추가
        files.insert(url, at: 0)
        
        // 최대 개수 제한
        if files.count > maxFiles {
            files = Array(files.prefix(maxFiles))
        }
        
        // 북마크 데이터로 변환하여 저장
        let bookmarks = files.compactMap { fileURL -> Data? in
            try? fileURL.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
        }
        
        UserDefaults.standard.set(bookmarks, forKey: key)
    }
    
    /// 목록 초기화
    func clearRecentFiles() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - 프리뷰
#Preview {
    ContentView()
        .environmentObject(BookmarkManager())
        .environmentObject(AnnotationManager())
}
