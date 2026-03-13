//
//  Category.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/10/26.
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - 카테고리 모델

/// 할일 카테고리 데이터 모델
/// - 이름, 색상, 아이콘 및 소속된 할일들을 관리
@Model
final class Category {
    // MARK: - 속성
    
    /// 카테고리 이름
    var name: String
    
    /// 카테고리 대표 색상
    /// - 실제 저장은 Color 자체가 아니라 hex 문자열로 한다.
    var colorHex: String
    
    /// 카테고리를 나타내는 SF Symbol 이름
    var iconName: String
    
    /// 생성 시각
    var createdAt: Date
    
    /// 목록에서의 정렬 순서
    var order: Int
    
    /// 이 카테고리에 속한 할일들
    /// - Category -> TaskItem의 1:N 관계
    /// - deleteRule이 .nullify라서 Category를 삭제해도 TaskItem까지 함께 삭제되지는 않는다.
    /// - 대신 연결만 끊기므로, 각 TaskItem의 category는 nil이 된다.
    @Relationship(deleteRule: .nullify)
    var tasks: [TaskItem] = []
    
    // Category 자체의 고유 데이터(name, colorHex, iconName)와
    // 다른 모델과의 연결 데이터(tasks)를 나눠서 보면 관계 모델이 더 잘 보인다.
    init(
        name: String,
        colorHex: String = "#007AFF",
        iconName: String = "folder.fill",
        order: Int = 0
    ) {
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.createdAt = Date()
        self.order = order
    }
}

// MARK: - 색상 변환

extension Category {
    /// SwiftUI Color 접근
    /// - 저장된 hex 문자열을 화면에서 쓰기 쉬운 Color로 변환한다.
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
    
    /// 색상 설정
    /// - View에서 선택한 Color를 다시 저장 가능한 hex 문자열로 바꾼다.
    func setColor(_ color: Color) {
        self.colorHex = color.toHex() ?? "#007AFF"
    }
}

// MARK: - 통계
extension Category {
    /// 완료되지 않은 할일 수
    /// - 별도 저장값이 아니라 tasks 관계를 기준으로 매번 계산한다.
    var pendingTaskCount: Int {
        tasks.filter { !$0.isCompleted }.count
    }
    
    /// 완료된 할일 수
    var completedTaskCount: Int {
        tasks.filter { $0.isCompleted }.count
    }
    
    /// 완료율 (0.0 ~ 1.0)
    var completionRate: Double {
        guard !tasks.isEmpty else { return 0 }
        return Double(completedTaskCount) / Double(tasks.count)
    }
}

// MARK: - 기본 카테고리

extension Category {
    /// 기본 카테고리 생성
    static func createDefaults() -> [Category] {
        [
            Category(name: "개인", colorHex: "#007AFF", iconName: "person.fill", order: 0),
            Category(name: "업무", colorHex: "#FF9500", iconName: "briefcase.fill", order: 1),
            Category(name: "쇼핑", colorHex: "#34C759", iconName: "cart.fill", order: 2),
            Category(name: "건강", colorHex: "#FF2D55", iconName: "heart.fill", order: 3),
        ]
    }
}

// MARK: - Color 확장 (Hex 변환)

extension Color {
    /// Hex 문자열로 Color 생성
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        guard hexSanitized.count == 6 else { return nil }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
    
    /// Color를 Hex 문자열로 변환
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

// MARK: - 사용 가능한 색상

/// 카테고리에 사용 가능한 색상 목록
enum CategoryColor: String, CaseIterable {
    case blue = "#007AFF"
    case green = "#34C759"
    case orange = "#FF9500"
    case red = "#FF2D55"
    case purple = "#AF52DE"
    case teal = "#5AC8FA"
    case indigo = "#5856D6"
    case pink = "#FF6B6B"
    
    var color: Color {
        Color(hex: rawValue) ?? .blue
    }
    
    var name: String {
        switch self {
        case .blue: "파랑"
        case .green: "초록"
        case .orange: "주황"
        case .red: "빨강"
        case .purple: "보라"
        case .teal: "청록"
        case .indigo: "남색"
        case .pink: "분홍"
        }
    }
}

// MARK: - 사용 가능한 아이콘

/// 카테고리에 사용 가능한 아이콘 목록
enum CategoryIcon: String, CaseIterable {
    case folder = "folder.fill"
    case person = "person.fill"
    case briefcase = "briefcase.fill"
    case cart = "cart.fill"
    case heart = "heart.fill"
    case star = "star.fill"
    case house = "house.fill"
    case book = "book.fill"
    case gamecontroller = "gamecontroller.fill"
    case airplane = "airplane"
    case car = "car.fill"
    case gift = "gift.fill"
    
    var name: String {
        switch self {
        case .folder: "폴더"
        case .person: "개인"
        case .briefcase: "업무"
        case .cart: "쇼핑"
        case .heart: "건강"
        case .star: "중요"
        case .house: "집"
        case .book: "학습"
        case .gamecontroller: "취미"
        case .airplane: "여행"
        case .car: "이동"
        case .gift: "선물"
        }
    }
}
