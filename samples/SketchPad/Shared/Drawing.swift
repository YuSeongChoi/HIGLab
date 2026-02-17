import Foundation
import PencilKit

// MARK: - Drawing 모델
// PKDrawing을 감싸는 식별 가능한 모델

struct Drawing: Identifiable, Codable {
    let id: UUID
    var name: String
    var drawingData: Data  // PKDrawing을 Data로 저장
    var createdAt: Date
    var modifiedAt: Date
    var thumbnailData: Data?  // 썸네일 이미지 (PNG)
    
    // MARK: - 초기화
    
    init(
        id: UUID = UUID(),
        name: String = "새 드로잉",
        drawing: PKDrawing = PKDrawing(),
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.drawingData = drawing.dataRepresentation()
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.thumbnailData = nil
    }
    
    // MARK: - PKDrawing 변환
    
    /// Data에서 PKDrawing 복원
    var pkDrawing: PKDrawing {
        get {
            (try? PKDrawing(data: drawingData)) ?? PKDrawing()
        }
        set {
            drawingData = newValue.dataRepresentation()
            modifiedAt = Date()
        }
    }
    
    // MARK: - 썸네일 생성
    
    /// PKDrawing에서 썸네일 이미지 생성
    mutating func generateThumbnail(size: CGSize = CGSize(width: 200, height: 200)) {
        let drawing = pkDrawing
        let bounds = drawing.bounds
        
        // 드로잉이 비어있으면 썸네일 생성하지 않음
        guard !bounds.isEmpty else {
            thumbnailData = nil
            return
        }
        
        // 비율 유지하며 크기 계산
        let scale = min(size.width / bounds.width, size.height / bounds.height)
        let scaledSize = CGSize(
            width: bounds.width * scale,
            height: bounds.height * scale
        )
        
        let image = drawing.image(from: bounds, scale: scale)
        thumbnailData = image.pngData()
    }
}

// MARK: - 샘플 데이터

extension Drawing {
    /// 미리보기용 샘플 드로잉
    static var sample: Drawing {
        Drawing(name: "샘플 드로잉")
    }
    
    /// 여러 샘플 드로잉
    static var samples: [Drawing] {
        [
            Drawing(name: "아이디어 스케치"),
            Drawing(name: "회의 노트"),
            Drawing(name: "다이어그램")
        ]
    }
}
