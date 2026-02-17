// Bookmark.swift
// PDFReader - HIG Lab 샘플 프로젝트
//
// 북마크 모델 및 관리자

import Foundation
import PDFKit

// MARK: - 북마크 모델
/// PDF 페이지 북마크를 나타내는 구조체
struct Bookmark: Identifiable, Codable, Equatable {
    /// 고유 식별자
    let id: UUID
    
    /// 북마크된 페이지 인덱스 (0-based)
    let pageIndex: Int
    
    /// 북마크 제목 (사용자 지정 또는 자동 생성)
    var title: String
    
    /// 북마크 생성 시간
    let createdAt: Date
    
    /// 북마크 메모 (선택적)
    var note: String?
    
    /// 북마크 색상 (hex 문자열)
    var colorHex: String
    
    // MARK: - 초기화
    
    /// 기본 초기화
    /// - Parameters:
    ///   - pageIndex: 페이지 인덱스
    ///   - title: 제목 (기본값: "페이지 N")
    ///   - note: 메모 (선택적)
    ///   - colorHex: 색상 hex (기본값: 노란색)
    init(
        pageIndex: Int,
        title: String? = nil,
        note: String? = nil,
        colorHex: String = "#FFD700"
    ) {
        self.id = UUID()
        self.pageIndex = pageIndex
        self.title = title ?? "페이지 \(pageIndex + 1)"
        self.createdAt = Date()
        self.note = note
        self.colorHex = colorHex
    }
    
    // MARK: - 표시용 속성
    
    /// 표시용 페이지 번호 (1-based)
    var displayPageNumber: Int {
        pageIndex + 1
    }
    
    /// 생성 시간 포맷팅
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: createdAt)
    }
}

// MARK: - 북마크 관리자
/// 북마크 CRUD 및 영속성 관리
@MainActor
class BookmarkManager: ObservableObject {
    
    // MARK: - 속성
    
    /// 현재 문서의 북마크 목록
    @Published private(set) var bookmarks: [Bookmark] = []
    
    /// 현재 문서 URL (저장 키로 사용)
    private var documentURL: URL?
    
    /// UserDefaults 키 접두사
    private let keyPrefix = "PDFReader.Bookmarks."
    
    // MARK: - 초기화
    
    init() {}
    
    // MARK: - 문서 관리
    
    /// 문서 로드 시 북마크 불러오기
    /// - Parameter url: PDF 문서 URL
    func loadBookmarks(for url: URL) {
        documentURL = url
        bookmarks = fetchBookmarks(for: url)
    }
    
    /// 문서 언로드 시 북마크 저장
    func unloadDocument() {
        if let url = documentURL {
            saveBookmarks(for: url)
        }
        documentURL = nil
        bookmarks = []
    }
    
    // MARK: - CRUD 작업
    
    /// 북마크 추가
    /// - Parameter bookmark: 새 북마크
    func add(_ bookmark: Bookmark) {
        // 중복 페이지 확인
        guard !bookmarks.contains(where: { $0.pageIndex == bookmark.pageIndex }) else {
            return
        }
        
        bookmarks.append(bookmark)
        bookmarks.sort { $0.pageIndex < $1.pageIndex }
        saveIfNeeded()
    }
    
    /// 현재 페이지에 북마크 추가/토글
    /// - Parameter pageIndex: 페이지 인덱스
    /// - Returns: 추가됨 = true, 삭제됨 = false
    @discardableResult
    func toggleBookmark(at pageIndex: Int) -> Bool {
        if let existingIndex = bookmarks.firstIndex(where: { $0.pageIndex == pageIndex }) {
            bookmarks.remove(at: existingIndex)
            saveIfNeeded()
            return false
        } else {
            add(Bookmark(pageIndex: pageIndex))
            return true
        }
    }
    
    /// 북마크 삭제
    /// - Parameter id: 북마크 ID
    func remove(id: UUID) {
        bookmarks.removeAll { $0.id == id }
        saveIfNeeded()
    }
    
    /// 북마크 업데이트
    /// - Parameter bookmark: 업데이트된 북마크
    func update(_ bookmark: Bookmark) {
        guard let index = bookmarks.firstIndex(where: { $0.id == bookmark.id }) else {
            return
        }
        bookmarks[index] = bookmark
        saveIfNeeded()
    }
    
    /// 모든 북마크 삭제
    func removeAll() {
        bookmarks.removeAll()
        saveIfNeeded()
    }
    
    // MARK: - 쿼리
    
    /// 특정 페이지의 북마크 여부 확인
    /// - Parameter pageIndex: 페이지 인덱스
    /// - Returns: 북마크 존재 여부
    func isBookmarked(pageIndex: Int) -> Bool {
        bookmarks.contains { $0.pageIndex == pageIndex }
    }
    
    /// 특정 페이지의 북마크 반환
    /// - Parameter pageIndex: 페이지 인덱스
    /// - Returns: 북마크 (없으면 nil)
    func bookmark(for pageIndex: Int) -> Bookmark? {
        bookmarks.first { $0.pageIndex == pageIndex }
    }
    
    /// 다음 북마크 페이지 인덱스
    /// - Parameter currentPage: 현재 페이지
    /// - Returns: 다음 북마크 페이지 (없으면 nil)
    func nextBookmark(after currentPage: Int) -> Int? {
        bookmarks.first { $0.pageIndex > currentPage }?.pageIndex
    }
    
    /// 이전 북마크 페이지 인덱스
    /// - Parameter currentPage: 현재 페이지
    /// - Returns: 이전 북마크 페이지 (없으면 nil)
    func previousBookmark(before currentPage: Int) -> Int? {
        bookmarks.last { $0.pageIndex < currentPage }?.pageIndex
    }
    
    // MARK: - 영속성
    
    /// 저장 키 생성
    private func storageKey(for url: URL) -> String {
        // URL을 해시하여 키 생성 (파일명 + 크기)
        let fileName = url.lastPathComponent
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0
        return keyPrefix + "\(fileName)_\(fileSize)".data(using: .utf8)!.base64EncodedString()
    }
    
    /// 북마크 불러오기
    private func fetchBookmarks(for url: URL) -> [Bookmark] {
        let key = storageKey(for: url)
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        
        do {
            return try JSONDecoder().decode([Bookmark].self, from: data)
        } catch {
            print("북마크 로드 실패: \(error)")
            return []
        }
    }
    
    /// 북마크 저장
    private func saveBookmarks(for url: URL) {
        let key = storageKey(for: url)
        
        do {
            let data = try JSONEncoder().encode(bookmarks)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("북마크 저장 실패: \(error)")
        }
    }
    
    /// 필요시 저장
    private func saveIfNeeded() {
        guard let url = documentURL else { return }
        saveBookmarks(for: url)
    }
}

// MARK: - 북마크 색상 프리셋
extension Bookmark {
    /// 사용 가능한 색상 프리셋
    static let colorPresets: [String] = [
        "#FFD700",  // 골드 (기본)
        "#FF6B6B",  // 빨강
        "#4ECDC4",  // 청록
        "#45B7D1",  // 하늘
        "#96CEB4",  // 민트
        "#DDA0DD",  // 자주
        "#F7DC6F",  // 노랑
        "#85C1E9"   // 파랑
    ]
}
