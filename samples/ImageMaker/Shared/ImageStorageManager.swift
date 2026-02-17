import Foundation
import SwiftUI
import UIKit

// MARK: - ImageStorageManager
// 생성된 이미지의 저장 및 로드를 관리하는 싱글톤 클래스
// 이미지 파일과 메타데이터를 별도로 관리

/// 이미지 저장소 관리자
/// 파일 시스템을 사용하여 이미지와 메타데이터를 영구 저장
@MainActor
final class ImageStorageManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ImageStorageManager()
    
    // MARK: - Published Properties
    
    /// 저장된 모든 이미지 메타데이터
    @Published private(set) var images: [GeneratedImage] = []
    
    /// 로딩 상태
    @Published private(set) var isLoading = false
    
    /// 마지막 에러 메시지
    @Published var lastError: String?
    
    // MARK: - Private Properties
    
    /// 이미지 저장 디렉토리
    private let imagesDirectory: URL
    
    /// 메타데이터 파일 경로
    private let metadataURL: URL
    
    /// JSON 인코더/디코더
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    
    private init() {
        // 문서 디렉토리 내 이미지 폴더 설정
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        
        imagesDirectory = documentsPath.appendingPathComponent("GeneratedImages", isDirectory: true)
        metadataURL = documentsPath.appendingPathComponent("images_metadata.json")
        
        // 인코더 설정
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        // 디렉토리 생성 및 데이터 로드
        createDirectoryIfNeeded()
        loadImages()
    }
    
    // MARK: - Directory Management
    
    /// 이미지 저장 디렉토리 생성
    private func createDirectoryIfNeeded() {
        if !FileManager.default.fileExists(atPath: imagesDirectory.path) {
            do {
                try FileManager.default.createDirectory(
                    at: imagesDirectory,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                lastError = "디렉토리 생성 실패: \(error.localizedDescription)"
            }
        }
    }
    
    // MARK: - Load & Save Metadata
    
    /// 저장된 이미지 메타데이터 로드
    func loadImages() {
        isLoading = true
        defer { isLoading = false }
        
        guard FileManager.default.fileExists(atPath: metadataURL.path) else {
            images = []
            return
        }
        
        do {
            let data = try Data(contentsOf: metadataURL)
            images = try decoder.decode([GeneratedImage].self, from: data)
            // 최신 순으로 정렬
            images.sort { $0.createdAt > $1.createdAt }
        } catch {
            lastError = "이미지 로드 실패: \(error.localizedDescription)"
            images = []
        }
    }
    
    /// 메타데이터를 파일에 저장
    private func saveMetadata() {
        do {
            let data = try encoder.encode(images)
            try data.write(to: metadataURL, options: .atomic)
        } catch {
            lastError = "메타데이터 저장 실패: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Image Operations
    
    /// 새 이미지 저장
    /// - Parameters:
    ///   - uiImage: 저장할 UIImage
    ///   - prompt: 생성 프롬프트
    ///   - style: 이미지 스타일
    /// - Returns: 생성된 이미지 메타데이터
    @discardableResult
    func saveImage(_ uiImage: UIImage, prompt: String, style: ImageStyle) -> GeneratedImage? {
        let imageData = GeneratedImage(prompt: prompt, style: style)
        let fileURL = imagesDirectory.appendingPathComponent(imageData.fileName)
        
        // PNG로 저장 (고품질)
        guard let pngData = uiImage.pngData() else {
            lastError = "이미지 변환 실패"
            return nil
        }
        
        do {
            try pngData.write(to: fileURL, options: .atomic)
            images.insert(imageData, at: 0) // 최신 이미지를 맨 앞에
            saveMetadata()
            return imageData
        } catch {
            lastError = "이미지 저장 실패: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// URL에서 이미지를 저장
    /// - Parameters:
    ///   - url: 이미지 URL (로컬 또는 원격)
    ///   - prompt: 생성 프롬프트
    ///   - style: 이미지 스타일
    /// - Returns: 생성된 이미지 메타데이터
    @discardableResult
    func saveImage(from url: URL, prompt: String, style: ImageStyle) async -> GeneratedImage? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let uiImage = UIImage(data: data) else {
                lastError = "이미지 데이터 변환 실패"
                return nil
            }
            return saveImage(uiImage, prompt: prompt, style: style)
        } catch {
            lastError = "이미지 다운로드 실패: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// 저장된 이미지 로드
    /// - Parameter image: 이미지 메타데이터
    /// - Returns: UIImage 또는 nil
    func loadImage(for image: GeneratedImage) -> UIImage? {
        let fileURL = imagesDirectory.appendingPathComponent(image.fileName)
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    /// SwiftUI Image로 변환
    /// - Parameter image: 이미지 메타데이터
    /// - Returns: SwiftUI Image 또는 플레이스홀더
    func image(for generatedImage: GeneratedImage) -> Image {
        if let uiImage = loadImage(for: generatedImage) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "photo")
    }
    
    // MARK: - Delete Operations
    
    /// 이미지 삭제
    /// - Parameter image: 삭제할 이미지
    func deleteImage(_ image: GeneratedImage) {
        // 파일 삭제
        let fileURL = imagesDirectory.appendingPathComponent(image.fileName)
        try? FileManager.default.removeItem(at: fileURL)
        
        // 메타데이터에서 제거
        images.removeAll { $0.id == image.id }
        saveMetadata()
    }
    
    /// 여러 이미지 삭제
    /// - Parameter imagesToDelete: 삭제할 이미지 배열
    func deleteImages(_ imagesToDelete: [GeneratedImage]) {
        for image in imagesToDelete {
            let fileURL = imagesDirectory.appendingPathComponent(image.fileName)
            try? FileManager.default.removeItem(at: fileURL)
        }
        
        let idsToDelete = Set(imagesToDelete.map { $0.id })
        images.removeAll { idsToDelete.contains($0.id) }
        saveMetadata()
    }
    
    /// 모든 이미지 삭제
    func deleteAllImages() {
        // 디렉토리 내 모든 파일 삭제
        if let files = try? FileManager.default.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil) {
            for file in files {
                try? FileManager.default.removeItem(at: file)
            }
        }
        
        images.removeAll()
        saveMetadata()
    }
    
    // MARK: - Update Operations
    
    /// 이미지 즐겨찾기 토글
    /// - Parameter image: 대상 이미지
    func toggleFavorite(_ image: GeneratedImage) {
        guard let index = images.firstIndex(where: { $0.id == image.id }) else {
            return
        }
        images[index].isFavorite.toggle()
        saveMetadata()
    }
    
    /// 이미지 메모 업데이트
    /// - Parameters:
    ///   - image: 대상 이미지
    ///   - note: 새 메모
    func updateNote(for image: GeneratedImage, note: String?) {
        guard let index = images.firstIndex(where: { $0.id == image.id }) else {
            return
        }
        images[index].note = note?.isEmpty == true ? nil : note
        saveMetadata()
    }
    
    // MARK: - Query Operations
    
    /// 즐겨찾기 이미지들
    var favoriteImages: [GeneratedImage] {
        images.filter { $0.isFavorite }
    }
    
    /// 특정 스타일의 이미지들
    func images(for style: ImageStyle) -> [GeneratedImage] {
        images.filter { $0.style == style }
    }
    
    /// 프롬프트로 검색
    func searchImages(query: String) -> [GeneratedImage] {
        guard !query.isEmpty else { return images }
        let lowercased = query.lowercased()
        return images.filter {
            $0.prompt.lowercased().contains(lowercased) ||
            $0.note?.lowercased().contains(lowercased) == true
        }
    }
    
    /// 날짜 범위로 필터링
    func images(from startDate: Date, to endDate: Date) -> [GeneratedImage] {
        images.filter { $0.createdAt >= startDate && $0.createdAt <= endDate }
    }
    
    // MARK: - Statistics
    
    /// 전체 이미지 개수
    var totalCount: Int {
        images.count
    }
    
    /// 스타일별 이미지 개수
    var countByStyle: [ImageStyle: Int] {
        Dictionary(grouping: images, by: { $0.style })
            .mapValues { $0.count }
    }
    
    /// 저장소 사용량 (바이트)
    var storageUsage: Int64 {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: imagesDirectory,
            includingPropertiesForKeys: [.fileSizeKey]
        ) else {
            return 0
        }
        
        return files.reduce(0) { total, url in
            let size = (try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
            return total + Int64(size)
        }
    }
    
    /// 저장소 사용량 (포맷된 문자열)
    var formattedStorageUsage: String {
        ByteCountFormatter.string(fromByteCount: storageUsage, countStyle: .file)
    }
}

// MARK: - Export/Share Support

extension ImageStorageManager {
    
    /// 이미지를 공유용 URL로 내보내기
    /// - Parameter image: 내보낼 이미지
    /// - Returns: 임시 파일 URL
    func exportImage(_ image: GeneratedImage) -> URL? {
        let sourceURL = imagesDirectory.appendingPathComponent(image.fileName)
        
        // 임시 디렉토리에 복사 (공유용)
        let tempDirectory = FileManager.default.temporaryDirectory
        let tempURL = tempDirectory.appendingPathComponent("ImageMaker_\(image.id.uuidString).png")
        
        do {
            // 기존 파일 제거 후 복사
            try? FileManager.default.removeItem(at: tempURL)
            try FileManager.default.copyItem(at: sourceURL, to: tempURL)
            return tempURL
        } catch {
            lastError = "내보내기 실패: \(error.localizedDescription)"
            return nil
        }
    }
    
    /// 포토 라이브러리에 저장
    /// - Parameter image: 저장할 이미지
    /// - Returns: 성공 여부
    func saveToPhotoLibrary(_ image: GeneratedImage) async -> Bool {
        guard let uiImage = loadImage(for: image) else {
            lastError = "이미지를 찾을 수 없습니다"
            return false
        }
        
        return await withCheckedContinuation { continuation in
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            continuation.resume(returning: true)
        }
    }
}
