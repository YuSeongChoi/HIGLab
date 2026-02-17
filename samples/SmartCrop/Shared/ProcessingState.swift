// ProcessingState.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import Foundation

/// 이미지 처리 상태를 나타내는 열거형
/// 각 상태에 따라 UI가 적절하게 반응합니다
enum ProcessingState: Equatable {
    /// 대기 상태 - 이미지 선택 전
    case idle
    
    /// 이미지 로드 중
    case loading
    
    /// 피사체 분석 중
    case analyzingSubject
    
    /// 스마트 크롭 처리 중
    case croppingSubject
    
    /// 배경 제거 중
    case removingBackground
    
    /// 이미지 확장(아웃페인팅) 중
    case extending
    
    /// 처리 완료
    case completed
    
    /// 오류 발생
    case failed(ProcessingError)
    
    /// 현재 상태에 대한 사용자 친화적 메시지
    var message: String {
        switch self {
        case .idle:
            return "이미지를 선택해주세요"
        case .loading:
            return "이미지 로딩 중..."
        case .analyzingSubject:
            return "피사체 분석 중..."
        case .croppingSubject:
            return "스마트 크롭 중..."
        case .removingBackground:
            return "배경 제거 중..."
        case .extending:
            return "이미지 확장 중..."
        case .completed:
            return "처리 완료!"
        case .failed(let error):
            return error.localizedDescription
        }
    }
    
    /// 처리 중인지 여부
    var isProcessing: Bool {
        switch self {
        case .loading, .analyzingSubject, .croppingSubject,
             .removingBackground, .extending:
            return true
        default:
            return false
        }
    }
    
    /// 진행률 (0.0 ~ 1.0)
    var progress: Double {
        switch self {
        case .idle: return 0.0
        case .loading: return 0.1
        case .analyzingSubject: return 0.3
        case .croppingSubject: return 0.5
        case .removingBackground: return 0.7
        case .extending: return 0.9
        case .completed: return 1.0
        case .failed: return 0.0
        }
    }
    
    // Equatable 구현 (연관값이 있는 case 처리)
    static func == (lhs: ProcessingState, rhs: ProcessingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.analyzingSubject, .analyzingSubject),
             (.croppingSubject, .croppingSubject),
             (.removingBackground, .removingBackground),
             (.extending, .extending),
             (.completed, .completed):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

/// 이미지 처리 중 발생할 수 있는 오류
enum ProcessingError: LocalizedError {
    /// 이미지 로드 실패
    case loadFailed
    
    /// 피사체를 찾을 수 없음
    case noSubjectFound
    
    /// 배경 제거 실패
    case backgroundRemovalFailed
    
    /// 이미지 확장 실패
    case extensionFailed
    
    /// ExtensibleImage API 사용 불가
    case apiUnavailable
    
    /// 메모리 부족
    case outOfMemory
    
    /// 알 수 없는 오류
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .loadFailed:
            return "이미지를 불러올 수 없습니다"
        case .noSubjectFound:
            return "피사체를 찾을 수 없습니다"
        case .backgroundRemovalFailed:
            return "배경 제거에 실패했습니다"
        case .extensionFailed:
            return "이미지 확장에 실패했습니다"
        case .apiUnavailable:
            return "이 기능은 iOS 26 이상에서 사용 가능합니다"
        case .outOfMemory:
            return "메모리가 부족합니다. 다른 앱을 종료해주세요"
        case .unknown(let message):
            return "오류 발생: \(message)"
        }
    }
}

/// 처리 모드 열거형
/// 사용자가 선택할 수 있는 이미지 처리 옵션
enum ProcessingMode: String, CaseIterable, Identifiable {
    /// 스마트 크롭 - 피사체 자동 감지 및 크롭
    case smartCrop = "스마트 크롭"
    
    /// 배경 제거 - 피사체만 추출
    case removeBackground = "배경 제거"
    
    /// 이미지 확장 - 아웃페인팅으로 이미지 영역 확장
    case extend = "이미지 확장"
    
    var id: String { rawValue }
    
    /// 모드에 대한 설명
    var description: String {
        switch self {
        case .smartCrop:
            return "AI가 자동으로 피사체를 감지하여 최적의 영역으로 크롭합니다"
        case .removeBackground:
            return "배경을 제거하고 피사체만 추출합니다"
        case .extend:
            return "이미지 영역을 확장하여 새로운 배경을 생성합니다"
        }
    }
    
    /// 모드 아이콘 이름
    var iconName: String {
        switch self {
        case .smartCrop:
            return "crop"
        case .removeBackground:
            return "person.crop.rectangle"
        case .extend:
            return "arrow.up.left.and.arrow.down.right"
        }
    }
}
