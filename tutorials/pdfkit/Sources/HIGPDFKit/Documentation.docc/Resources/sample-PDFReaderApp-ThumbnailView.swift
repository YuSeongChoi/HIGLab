// ThumbnailView.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// 썸네일 뷰: PDF 페이지 미리보기 그리드

import SwiftUI
import PDFKit

// MARK: - 썸네일 뷰
struct ThumbnailView: View {
    
    // MARK: - 속성
    
    /// PDF 문서
    let pdfDocument: PDFDocument
    
    /// 현재 선택된 페이지 인덱스
    @Binding var currentPageIndex: Int
    
    // MARK: - 환경 객체
    
    @EnvironmentObject var bookmarkManager: BookmarkManager
    
    // MARK: - 상태
    
    /// 썸네일 캐시
    @State private var thumbnailCache: [Int: ThumbnailImage] = [:]
    
    /// 로딩 중인 페이지
    @State private var loadingPages: Set<Int> = []
    
    // MARK: - 상수
    
    /// 썸네일 크기
    private let thumbnailSize = AppConstants.thumbnailSize
    
    /// 그리드 열 설정
    private let columns = [
        GridItem(.adaptive(minimum: 100, maximum: 150), spacing: 12)
    ]
    
    // MARK: - 뷰 본문
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(0..<pdfDocument.pageCount, id: \.self) { pageIndex in
                        thumbnailItem(for: pageIndex)
                            .id(pageIndex)
                    }
                }
                .padding()
            }
            .onChange(of: currentPageIndex) { _, newIndex in
                // 현재 페이지로 스크롤
                withAnimation {
                    scrollProxy.scrollTo(newIndex, anchor: .center)
                }
            }
            .onAppear {
                // 초기 스크롤
                scrollProxy.scrollTo(currentPageIndex, anchor: .center)
            }
        }
    }
    
    // MARK: - 썸네일 아이템
    
    /// 개별 썸네일 아이템
    @ViewBuilder
    private func thumbnailItem(for pageIndex: Int) -> some View {
        Button {
            currentPageIndex = pageIndex
        } label: {
            VStack(spacing: 8) {
                // 썸네일 이미지
                thumbnailImageView(for: pageIndex)
                    .overlay(alignment: .topTrailing) {
                        // 북마크 표시
                        if bookmarkManager.isBookmarked(pageIndex: pageIndex) {
                            Image(systemName: "bookmark.fill")
                                .foregroundStyle(.yellow)
                                .padding(4)
                                .background(.ultraThinMaterial, in: Circle())
                                .padding(4)
                        }
                    }
                
                // 페이지 번호
                Text("\(pageIndex + 1)")
                    .font(.caption)
                    .foregroundStyle(
                        currentPageIndex == pageIndex ? .primary : .secondary
                    )
            }
        }
        .buttonStyle(.plain)
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(currentPageIndex == pageIndex ? Color.accentColor.opacity(0.2) : Color.clear)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    currentPageIndex == pageIndex ? Color.accentColor : Color.clear,
                    lineWidth: 2
                )
        )
        .onAppear {
            loadThumbnail(for: pageIndex)
        }
    }
    
    // MARK: - 썸네일 이미지 뷰
    
    /// 썸네일 이미지 표시
    @ViewBuilder
    private func thumbnailImageView(for pageIndex: Int) -> some View {
        Group {
            if let thumbnail = thumbnailCache[pageIndex] {
                // 캐시된 썸네일
                #if os(iOS)
                Image(uiImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                #elseif os(macOS)
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                #endif
            } else if loadingPages.contains(pageIndex) {
                // 로딩 중
                ProgressView()
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height)
            } else {
                // 플레이스홀더
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: thumbnailSize.width, height: thumbnailSize.height)
                    .overlay {
                        Image(systemName: "doc")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
        }
        .frame(width: thumbnailSize.width, height: thumbnailSize.height)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - 썸네일 로딩
    
    /// 썸네일 비동기 로딩
    private func loadThumbnail(for pageIndex: Int) {
        // 이미 캐시되었거나 로딩 중이면 스킵
        guard thumbnailCache[pageIndex] == nil,
              !loadingPages.contains(pageIndex) else { return }
        
        loadingPages.insert(pageIndex)
        
        // 백그라운드에서 썸네일 생성
        Task.detached(priority: .userInitiated) {
            let thumbnail = await generateThumbnail(for: pageIndex)
            
            await MainActor.run {
                loadingPages.remove(pageIndex)
                if let thumbnail = thumbnail {
                    thumbnailCache[pageIndex] = thumbnail
                }
            }
        }
    }
    
    /// 썸네일 생성
    private func generateThumbnail(for pageIndex: Int) async -> ThumbnailImage? {
        guard let page = pdfDocument.page(at: pageIndex) else { return nil }
        return page.thumbnail(of: thumbnailSize, for: .mediaBox)
    }
}

// MARK: - 타입 별칭
#if os(iOS)
typealias ThumbnailImage = UIImage
#elseif os(macOS)
typealias ThumbnailImage = NSImage
#endif

// MARK: - 섹션별 썸네일 뷰
/// 페이지를 챕터/섹션별로 그룹화한 썸네일 뷰
struct SectionedThumbnailView: View {
    
    /// PDF 문서
    let pdfDocument: PDFDocument
    
    /// 현재 페이지 인덱스
    @Binding var currentPageIndex: Int
    
    /// 섹션당 페이지 수
    let pagesPerSection: Int
    
    /// 섹션 목록
    private var sections: [ThumbnailSection] {
        stride(from: 0, to: pdfDocument.pageCount, by: pagesPerSection)
            .map { startIndex in
                let endIndex = min(startIndex + pagesPerSection, pdfDocument.pageCount)
                return ThumbnailSection(
                    id: startIndex / pagesPerSection,
                    title: "페이지 \(startIndex + 1)-\(endIndex)",
                    pageRange: startIndex..<endIndex
                )
            }
    }
    
    init(pdfDocument: PDFDocument, currentPageIndex: Binding<Int>, pagesPerSection: Int = 10) {
        self.pdfDocument = pdfDocument
        self._currentPageIndex = currentPageIndex
        self.pagesPerSection = pagesPerSection
    }
    
    var body: some View {
        List(sections) { section in
            Section(section.title) {
                ForEach(Array(section.pageRange), id: \.self) { pageIndex in
                    HStack {
                        // 페이지 번호
                        Text("\(pageIndex + 1)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .frame(width: 30)
                        
                        // 페이지 텍스트 미리보기
                        if let page = pdfDocument.page(at: pageIndex) {
                            Text(page.text.prefix(50) + (page.text.count > 50 ? "..." : ""))
                                .font(.caption2)
                                .lineLimit(2)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // 선택 표시
                        if currentPageIndex == pageIndex {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        currentPageIndex = pageIndex
                    }
                }
            }
        }
    }
}

/// 썸네일 섹션 모델
struct ThumbnailSection: Identifiable {
    let id: Int
    let title: String
    let pageRange: Range<Int>
}

// MARK: - 프리뷰
#Preview {
    if let url = Bundle.main.url(forResource: "sample", withExtension: "pdf"),
       let document = PDFDocument(url: url) {
        ThumbnailView(
            pdfDocument: document,
            currentPageIndex: .constant(0)
        )
        .environmentObject(BookmarkManager())
    } else {
        Text("샘플 PDF 없음")
    }
}
