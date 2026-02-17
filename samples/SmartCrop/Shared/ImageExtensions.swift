// ImageExtensions.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI
import Photos

// MARK: - UIImage 확장

extension UIImage {
    /// 이미지를 지정된 최대 크기로 리사이즈
    /// 메모리 효율을 위해 큰 이미지를 처리 전 축소합니다
    /// - Parameter maxDimension: 최대 가로/세로 크기
    /// - Returns: 리사이즈된 이미지
    func resized(maxDimension: CGFloat) -> UIImage {
        let ratio = min(
            maxDimension / size.width,
            maxDimension / size.height
        )
        
        // 이미 충분히 작으면 원본 반환
        guard ratio < 1.0 else { return self }
        
        let newSize = CGSize(
            width: size.width * ratio,
            height: size.height * ratio
        )
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    
    /// 이미지에 투명 배경 적용
    /// 배경 제거 결과를 시각화할 때 사용합니다
    /// - Parameter backgroundColor: 배경색 (기본: 투명)
    /// - Returns: 배경이 적용된 이미지
    func withBackground(color backgroundColor: UIColor = .clear) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            backgroundColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            self.draw(at: .zero)
        }
    }
    
    /// 체커보드 배경과 함께 이미지 렌더링
    /// 투명 영역을 시각적으로 표시합니다
    /// - Parameter squareSize: 체커보드 사각형 크기
    /// - Returns: 체커보드 배경이 적용된 이미지
    func withCheckerboardBackground(squareSize: CGFloat = 10) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let ctx = context.cgContext
            
            // 체커보드 패턴 그리기
            let lightGray = UIColor(white: 0.9, alpha: 1.0)
            let darkGray = UIColor(white: 0.7, alpha: 1.0)
            
            let cols = Int(ceil(size.width / squareSize))
            let rows = Int(ceil(size.height / squareSize))
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let isLight = (row + col) % 2 == 0
                    ctx.setFillColor(isLight ? lightGray.cgColor : darkGray.cgColor)
                    ctx.fill(CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    ))
                }
            }
            
            // 원본 이미지 그리기
            self.draw(at: .zero)
        }
    }
    
    /// 이미지 데이터 크기 (바이트)
    var dataSize: Int {
        guard let data = jpegData(compressionQuality: 1.0) else { return 0 }
        return data.count
    }
    
    /// 사람이 읽기 쉬운 파일 크기 문자열
    var formattedDataSize: String {
        let bytes = Double(dataSize)
        let units = ["B", "KB", "MB", "GB"]
        var size = bytes
        var unitIndex = 0
        
        while size >= 1024 && unitIndex < units.count - 1 {
            size /= 1024
            unitIndex += 1
        }
        
        return String(format: "%.1f %@", size, units[unitIndex])
    }
}

// MARK: - CGRect 확장

extension CGRect {
    /// 정규화된 좌표 (0.0 ~ 1.0)를 실제 픽셀 좌표로 변환
    /// - Parameter imageSize: 이미지 크기
    /// - Returns: 픽셀 단위의 CGRect
    func denormalized(for imageSize: CGSize) -> CGRect {
        CGRect(
            x: origin.x * imageSize.width,
            y: origin.y * imageSize.height,
            width: width * imageSize.width,
            height: height * imageSize.height
        )
    }
    
    /// 픽셀 좌표를 정규화된 좌표로 변환
    /// - Parameter imageSize: 이미지 크기
    /// - Returns: 정규화된 CGRect (0.0 ~ 1.0)
    func normalized(for imageSize: CGSize) -> CGRect {
        CGRect(
            x: origin.x / imageSize.width,
            y: origin.y / imageSize.height,
            width: width / imageSize.width,
            height: height / imageSize.height
        )
    }
    
    /// 중심점
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    /// 종횡비
    var aspectRatio: CGFloat {
        guard height > 0 else { return 0 }
        return width / height
    }
}

// MARK: - View 확장

extension View {
    /// 조건부 수정자 적용
    /// - Parameters:
    ///   - condition: 조건
    ///   - transform: 적용할 변환
    /// - Returns: 수정된 뷰
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - 사진 라이브러리 저장 유틸리티

/// 사진 라이브러리에 이미지를 저장하는 유틸리티
actor PhotoLibrarySaver {
    /// 이미지를 사진 라이브러리에 저장
    /// - Parameter image: 저장할 이미지
    /// - Throws: 권한 오류 또는 저장 실패
    func saveToPhotoLibrary(_ image: UIImage) async throws {
        // 사진 라이브러리 접근 권한 확인
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized || status == .limited else {
            throw PhotoLibraryError.accessDenied
        }
        
        // 이미지 저장
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                if success {
                    continuation.resume()
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: PhotoLibraryError.saveFailed)
                }
            }
        }
    }
}

/// 사진 라이브러리 관련 오류
enum PhotoLibraryError: LocalizedError {
    case accessDenied
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "사진 라이브러리 접근 권한이 필요합니다"
        case .saveFailed:
            return "이미지 저장에 실패했습니다"
        }
    }
}

// MARK: - 이미지 공유 유틸리티

/// 이미지 공유를 위한 Transferable 래퍼
struct ShareableImage: Transferable {
    let image: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            guard let data = item.image.pngData() else {
                throw ShareError.encodingFailed
            }
            return data
        }
    }
}

/// 공유 관련 오류
enum ShareError: LocalizedError {
    case encodingFailed
    
    var errorDescription: String? {
        "이미지 인코딩에 실패했습니다"
    }
}

// MARK: - 색상 확장

extension Color {
    /// 앱 테마 색상
    static let smartCropPrimary = Color("PrimaryColor", bundle: nil)
    static let smartCropSecondary = Color("SecondaryColor", bundle: nil)
    
    /// 처리 상태별 색상
    static func forProcessingState(_ state: ProcessingState) -> Color {
        switch state {
        case .idle:
            return .secondary
        case .loading, .analyzingSubject, .croppingSubject,
             .removingBackground, .extending:
            return .blue
        case .completed:
            return .green
        case .failed:
            return .red
        }
    }
}
