//
//  Priority.swift
//  HIGPractice
//
//  Created by YuSeongChoi on 3/9/26.
//

import Foundation
import AppIntents

// MARK: - 우선순위 열거형
/// 할일 항목의 우선순위를 정의하는 열거형
/// AppEnum을 준수하여 Siri와 단축어에서 사용 가능
enum Priority: Int, Codable, CaseIterable, Sendable {
    case low = 0        // 낮음
    case normal = 1     // 보통
    case high = 2       // 높음
    case urgent = 3     // 긴급
    
    // MARK: - 표시 이름
        
        /// 사용자에게 표시할 이름
        var displayName: String {
            switch self {
            case .low: return "낮음"
            case .normal: return "보통"
            case .high: return "높음"
            case .urgent: return "긴급"
            }
        }
        
        /// 아이콘 이름
        var systemImageName: String {
            switch self {
            case .low: return "arrow.down.circle"
            case .normal: return "minus.circle"
            case .high: return "arrow.up.circle"
            case .urgent: return "exclamationmark.circle.fill"
            }
        }
        
        /// 색상
        var colorName: String {
            switch self {
            case .low: return "gray"
            case .normal: return "blue"
            case .high: return "orange"
            case .urgent: return "red"
            }
        }
        
        // MARK: - 이모지
        
        /// 이모지 표현
        var emoji: String {
            switch self {
            case .low: return "🔵"
            case .normal: return "🟢"
            case .high: return "🟠"
            case .urgent: return "🔴"
            }
        }
        
        // MARK: - 비교 지원
        
        /// 정렬을 위한 가중치
        var sortWeight: Int {
            rawValue
        }
    
}

// MARK: - AppEnum 준수
/// Siri 및 단축어에서 우선순위를 선택할 수 있도록 AppEnum 준수
extension Priority: AppEnum {
    
    /// 타입 표시 정보
    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "우선순위")
    }
    
    /// 각 케이스별 표시 정보
    nonisolated static var caseDisplayRepresentations: [Priority : DisplayRepresentation]  {
        [
                    .low: DisplayRepresentation(
                        title: "낮음",
                        subtitle: "나중에 해도 되는 일",
                        image: .init(systemName: "arrow.down.circle")
                    ),
                    .normal: DisplayRepresentation(
                        title: "보통",
                        subtitle: "일반적인 할일",
                        image: .init(systemName: "minus.circle")
                    ),
                    .high: DisplayRepresentation(
                        title: "높음",
                        subtitle: "중요한 할일",
                        image: .init(systemName: "arrow.up.circle")
                    ),
                    .urgent: DisplayRepresentation(
                        title: "긴급",
                        subtitle: "즉시 처리 필요",
                        image: .init(systemName: "exclamationmark.circle.fill")
                    )
                ]
    }
}

// MARK: - 문자열 변환
extension Priority {
    
    /// 문자열로부터 우선순위 생성
    /// - Parameter string: 우선순위를 나타내는 문자열
    /// - Return: 해당하는 우선순위 (없으면 nil)
    static func from(string: String) -> Priority? {
        let normalized = string.lowercased().trimmingCharacters(in: .whitespaces)
        
        switch normalized {
        case "low", "낮음", "낮은", "저":
            return .low
        case "normal", "보통", "중간", "중":
            return .normal
        case "high", "높음", "높은", "고":
            return .high
        case "urgent", "긴급", "급함", "급한":
            return .urgent
        default:
            return nil
        }
    }
}

// MARK: - Comparable 준수
extension Priority: Comparable {
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
