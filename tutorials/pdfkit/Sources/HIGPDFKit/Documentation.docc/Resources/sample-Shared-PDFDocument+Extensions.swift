// PDFDocument+Extensions.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// PDFDocument 확장: 유틸리티 메서드 추가

import PDFKit
import Foundation

// MARK: - PDFDocument 확장
extension PDFDocument {
    
    // MARK: - 문서 정보
    
    /// 문서 제목 반환 (메타데이터 또는 파일명)
    var title: String {
        // 메타데이터에서 제목 추출 시도
        if let attributes = documentAttributes,
           let title = attributes[PDFDocumentAttribute.titleAttribute] as? String,
           !title.isEmpty {
            return title
        }
        // 파일 URL에서 이름 추출
        return documentURL?.deletingPathExtension().lastPathComponent ?? "제목 없음"
    }
    
    /// 문서 저자 반환
    var author: String? {
        guard let attributes = documentAttributes else { return nil }
        return attributes[PDFDocumentAttribute.authorAttribute] as? String
    }
    
    /// 문서 생성일 반환
    var creationDate: Date? {
        guard let attributes = documentAttributes else { return nil }
        return attributes[PDFDocumentAttribute.creationDateAttribute] as? Date
    }
    
    /// 문서 수정일 반환
    var modificationDate: Date? {
        guard let attributes = documentAttributes else { return nil }
        return attributes[PDFDocumentAttribute.modificationDateAttribute] as? Date
    }
    
    // MARK: - 페이지 관련
    
    /// 전체 페이지 배열 반환
    var allPages: [PDFPage] {
        (0..<pageCount).compactMap { page(at: $0) }
    }
    
    /// 특정 범위의 페이지 반환
    /// - Parameters:
    ///   - start: 시작 인덱스 (0-based)
    ///   - end: 끝 인덱스 (exclusive)
    /// - Returns: 페이지 배열
    func pages(from start: Int, to end: Int) -> [PDFPage] {
        let safeStart = max(0, start)
        let safeEnd = min(pageCount, end)
        return (safeStart..<safeEnd).compactMap { page(at: $0) }
    }
    
    /// 페이지 인덱스 반환 (1-based 표시용)
    func displayPageNumber(for page: PDFPage) -> Int? {
        guard let index = index(for: page) else { return nil }
        return index + 1
    }
    
    // MARK: - 텍스트 검색
    
    /// 전체 문서 텍스트 반환
    var fullText: String {
        allPages.compactMap { $0.string }.joined(separator: "\n")
    }
    
    /// 텍스트 검색 (대소문자 무시)
    /// - Parameter query: 검색어
    /// - Returns: 검색 결과 배열 (페이지, 범위)
    func search(_ query: String) -> [PDFSelection] {
        guard !query.isEmpty else { return [] }
        return findString(query, withOptions: .caseInsensitive)
    }
    
    /// 비동기 텍스트 검색
    /// - Parameters:
    ///   - query: 검색어
    ///   - completion: 결과 콜백
    func searchAsync(_ query: String, completion: @escaping ([PDFSelection]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let results = self?.search(query) ?? []
            DispatchQueue.main.async {
                completion(results)
            }
        }
    }
    
    // MARK: - 썸네일 생성
    
    /// 특정 페이지의 썸네일 생성
    /// - Parameters:
    ///   - pageIndex: 페이지 인덱스
    ///   - size: 썸네일 크기
    /// - Returns: 썸네일 이미지
    #if os(iOS)
    func thumbnail(for pageIndex: Int, size: CGSize) -> UIImage? {
        guard let page = page(at: pageIndex) else { return nil }
        return page.thumbnail(of: size, for: .mediaBox)
    }
    #elseif os(macOS)
    func thumbnail(for pageIndex: Int, size: CGSize) -> NSImage? {
        guard let page = page(at: pageIndex) else { return nil }
        return page.thumbnail(of: size, for: .mediaBox)
    }
    #endif
    
    // MARK: - 주석 관련
    
    /// 전체 주석 반환
    var allAnnotations: [PDFAnnotation] {
        allPages.flatMap { $0.annotations }
    }
    
    /// 특정 타입의 주석만 반환
    func annotations(ofType type: String) -> [PDFAnnotation] {
        allAnnotations.filter { $0.type == type }
    }
    
    /// 하이라이트 주석만 반환
    var highlights: [PDFAnnotation] {
        annotations(ofType: "Highlight")
    }
    
    /// 메모 주석만 반환
    var notes: [PDFAnnotation] {
        annotations(ofType: "Text")
    }
}

// MARK: - PDFPage 확장
extension PDFPage {
    
    /// 페이지 크기 (포인트 단위)
    var pageSize: CGSize {
        bounds(for: .mediaBox).size
    }
    
    /// 페이지 비율 (가로/세로)
    var aspectRatio: CGFloat {
        let size = pageSize
        return size.width / size.height
    }
    
    /// 페이지가 가로 방향인지 확인
    var isLandscape: Bool {
        aspectRatio > 1.0
    }
    
    /// 페이지 텍스트 (nil-safe)
    var text: String {
        string ?? ""
    }
}

// MARK: - PDFSelection 확장
extension PDFSelection {
    
    /// 선택된 텍스트의 페이지 번호 (1-based)
    var pageNumber: Int? {
        guard let page = pages.first,
              let document = page.document else { return nil }
        return document.displayPageNumber(for: page)
    }
    
    /// 선택 영역의 중심점
    var centerPoint: CGPoint? {
        guard let bounds = bounds(for: pages.first ?? PDFPage()) else { return nil }
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
}
