import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

// MARK: - 이미지 Transferable
/// PhotosPicker에서 이미지를 로드하기 위한 Transferable 구현
struct TransferableImage: Transferable {
    let image: Image
    let uiImage: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            // 데이터에서 UIImage 생성
            guard let uiImage = UIImage(data: data) else {
                throw PhotoLoaderError.invalidImageData
            }
            return TransferableImage(image: Image(uiImage: uiImage), uiImage: uiImage)
        }
    }
}

// MARK: - 비디오 Transferable
/// PhotosPicker에서 비디오를 로드하기 위한 Transferable 구현
struct TransferableVideo: Transferable {
    let url: URL
    
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(importedContentType: .movie) { receivedFile in
            // 임시 디렉토리에 비디오 파일 복사
            let tempDirectory = FileManager.default.temporaryDirectory
            let filename = "\(UUID().uuidString).mov"
            let destinationURL = tempDirectory.appendingPathComponent(filename)
            
            // 기존 파일이 있으면 삭제
            try? FileManager.default.removeItem(at: destinationURL)
            
            // 파일 복사
            try FileManager.default.copyItem(at: receivedFile.file, to: destinationURL)
            
            return TransferableVideo(url: destinationURL)
        }
    }
}

// MARK: - 에러 타입
enum PhotoLoaderError: LocalizedError {
    case invalidImageData
    case loadFailed
    case unsupportedType
    
    var errorDescription: String? {
        switch self {
        case .invalidImageData:
            return "이미지 데이터를 읽을 수 없습니다"
        case .loadFailed:
            return "미디어 로딩에 실패했습니다"
        case .unsupportedType:
            return "지원하지 않는 미디어 타입입니다"
        }
    }
}

// MARK: - 포토 로더
/// PhotosPickerItem에서 미디어를 로드하는 유틸리티
@MainActor
final class PhotoLoader: ObservableObject {
    
    // MARK: - 싱글톤
    static let shared = PhotoLoader()
    
    private init() {}
    
    // MARK: - 이미지 로드
    
    /// PhotosPickerItem에서 이미지 로드
    /// - Parameter item: PhotosPicker에서 선택된 아이템
    /// - Returns: 로드된 TransferableImage
    func loadImage(from item: PhotosPickerItem) async throws -> TransferableImage {
        // Transferable 프로토콜을 사용해 이미지 로드
        guard let transferable = try await item.loadTransferable(type: TransferableImage.self) else {
            throw PhotoLoaderError.loadFailed
        }
        return transferable
    }
    
    /// PhotosPickerItem에서 썸네일 이미지 로드
    /// - Parameters:
    ///   - item: PhotosPicker에서 선택된 아이템
    ///   - targetSize: 원하는 썸네일 크기
    /// - Returns: 리사이즈된 Image
    func loadThumbnail(from item: PhotosPickerItem, targetSize: CGSize = CGSize(width: 200, height: 200)) async throws -> Image {
        let transferable = try await loadImage(from: item)
        
        // 썸네일 크기로 리사이즈
        let resized = await resizeImage(transferable.uiImage, to: targetSize)
        return Image(uiImage: resized)
    }
    
    // MARK: - 비디오 로드
    
    /// PhotosPickerItem에서 비디오 URL 로드
    /// - Parameter item: PhotosPicker에서 선택된 아이템
    /// - Returns: 비디오 파일의 로컬 URL
    func loadVideo(from item: PhotosPickerItem) async throws -> URL {
        // Transferable 프로토콜을 사용해 비디오 로드
        guard let transferable = try await item.loadTransferable(type: TransferableVideo.self) else {
            throw PhotoLoaderError.loadFailed
        }
        return transferable.url
    }
    
    // MARK: - 헬퍼 메서드
    
    /// 이미지 리사이즈
    /// - Parameters:
    ///   - image: 원본 이미지
    ///   - targetSize: 목표 크기
    /// - Returns: 리사이즈된 이미지
    private func resizeImage(_ image: UIImage, to targetSize: CGSize) async -> UIImage {
        // 비율 유지하며 크기 계산
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(
            width: image.size.width * ratio,
            height: image.size.height * ratio
        )
        
        // 이미지 그리기
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
