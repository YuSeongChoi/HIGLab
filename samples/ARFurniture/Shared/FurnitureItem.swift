//
//  FurnitureItem.swift
//  ARFurniture
//
//  가구 아이템 모델 정의
//

import Foundation
import RealityKit

/// 가구 카테고리 열거형
enum FurnitureCategory: String, CaseIterable, Identifiable {
    case chair = "의자"
    case table = "테이블"
    case sofa = "소파"
    case lamp = "조명"
    case plant = "식물"
    
    var id: String { rawValue }
    
    /// 카테고리별 시스템 아이콘
    var iconName: String {
        switch self {
        case .chair: return "chair.fill"
        case .table: return "rectangle.split.3x3"
        case .sofa: return "sofa.fill"
        case .lamp: return "lamp.desk.fill"
        case .plant: return "leaf.fill"
        }
    }
}

/// 가구 아이템 모델
struct FurnitureItem: Identifiable, Hashable {
    let id: UUID
    let name: String              // 가구 이름
    let category: FurnitureCategory
    let modelName: String         // USDZ 파일명 (확장자 제외)
    let thumbnailName: String     // 썸네일 이미지 이름
    let price: Int                // 가격 (원)
    let dimensions: SIMD3<Float>  // 크기 (미터 단위: 가로, 세로, 높이)
    let description: String       // 상품 설명
    
    init(
        id: UUID = UUID(),
        name: String,
        category: FurnitureCategory,
        modelName: String,
        thumbnailName: String? = nil,
        price: Int,
        dimensions: SIMD3<Float>,
        description: String = ""
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.modelName = modelName
        self.thumbnailName = thumbnailName ?? modelName
        self.price = price
        self.dimensions = dimensions
        self.description = description
    }
    
    /// 가격 포맷팅 (예: "150,000원")
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: price)) ?? "\(price)")원"
    }
    
    /// 크기 포맷팅 (예: "가로 80cm × 세로 60cm × 높이 75cm")
    var formattedDimensions: String {
        let w = Int(dimensions.x * 100)
        let d = Int(dimensions.y * 100)
        let h = Int(dimensions.z * 100)
        return "가로 \(w)cm × 세로 \(d)cm × 높이 \(h)cm"
    }
}

// MARK: - 샘플 데이터

extension FurnitureItem {
    /// 샘플 가구 목록
    static let sampleItems: [FurnitureItem] = [
        // 의자
        FurnitureItem(
            name: "모던 의자",
            category: .chair,
            modelName: "modern_chair",
            price: 150000,
            dimensions: SIMD3<Float>(0.5, 0.5, 0.85),
            description: "심플하고 세련된 모던 스타일 의자"
        ),
        FurnitureItem(
            name: "원목 의자",
            category: .chair,
            modelName: "wooden_chair",
            price: 220000,
            dimensions: SIMD3<Float>(0.45, 0.48, 0.90),
            description: "천연 원목으로 제작된 따뜻한 느낌의 의자"
        ),
        
        // 테이블
        FurnitureItem(
            name: "식탁 테이블",
            category: .table,
            modelName: "dining_table",
            price: 450000,
            dimensions: SIMD3<Float>(1.4, 0.8, 0.75),
            description: "4인 가족용 식탁 테이블"
        ),
        FurnitureItem(
            name: "커피 테이블",
            category: .table,
            modelName: "coffee_table",
            price: 180000,
            dimensions: SIMD3<Float>(1.0, 0.6, 0.45),
            description: "거실용 낮은 커피 테이블"
        ),
        
        // 소파
        FurnitureItem(
            name: "3인 소파",
            category: .sofa,
            modelName: "sofa_3seat",
            price: 890000,
            dimensions: SIMD3<Float>(2.2, 0.9, 0.85),
            description: "편안한 쿠션의 3인용 소파"
        ),
        
        // 조명
        FurnitureItem(
            name: "스탠드 조명",
            category: .lamp,
            modelName: "floor_lamp",
            price: 95000,
            dimensions: SIMD3<Float>(0.35, 0.35, 1.6),
            description: "분위기 있는 플로어 스탠드"
        ),
        
        // 식물
        FurnitureItem(
            name: "화분 식물",
            category: .plant,
            modelName: "potted_plant",
            price: 45000,
            dimensions: SIMD3<Float>(0.3, 0.3, 0.8),
            description: "인테리어용 관엽 식물"
        )
    ]
}

// MARK: - 배치된 가구 모델

/// AR 공간에 배치된 가구 정보
struct PlacedFurniture: Identifiable {
    let id: UUID
    let item: FurnitureItem
    var entity: ModelEntity?      // RealityKit 엔티티
    var transform: Transform      // 위치/회전/크기 정보
    let placedAt: Date            // 배치 시간
    
    init(
        id: UUID = UUID(),
        item: FurnitureItem,
        entity: ModelEntity? = nil,
        transform: Transform = .identity,
        placedAt: Date = Date()
    ) {
        self.id = id
        self.item = item
        self.entity = entity
        self.transform = transform
        self.placedAt = placedAt
    }
}
