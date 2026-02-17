// FilterType.swift
// FilterLab - Core Image 필터 타입 정의
// HIG Lab 샘플 프로젝트

import Foundation
import CoreImage

// MARK: - 필터 카테고리
/// 필터를 분류하기 위한 카테고리
enum FilterCategory: String, CaseIterable, Identifiable {
    case color = "색상"
    case blur = "블러"
    case stylize = "스타일"
    case distortion = "왜곡"
    case custom = "커스텀"
    
    var id: String { rawValue }
    
    /// 카테고리별 아이콘
    var icon: String {
        switch self {
        case .color: return "paintpalette"
        case .blur: return "drop.halffull"
        case .stylize: return "wand.and.stars"
        case .distortion: return "water.waves"
        case .custom: return "sparkles"
        }
    }
}

// MARK: - 필터 타입
/// 앱에서 지원하는 모든 필터 타입
enum FilterType: String, CaseIterable, Identifiable {
    // 색상 필터
    case sepiaTone = "세피아"
    case colorMonochrome = "흑백"
    case vibrance = "생동감"
    case hueAdjust = "색조"
    case colorInvert = "색상 반전"
    case photoEffectChrome = "크롬"
    case photoEffectFade = "페이드"
    case photoEffectInstant = "인스턴트"
    case photoEffectNoir = "누아르"
    case photoEffectProcess = "프로세스"
    case photoEffectTonal = "토널"
    case photoEffectTransfer = "트랜스퍼"
    
    // 블러 필터
    case gaussianBlur = "가우시안 블러"
    case boxBlur = "박스 블러"
    case discBlur = "디스크 블러"
    case motionBlur = "모션 블러"
    case zoomBlur = "줌 블러"
    
    // 스타일 필터
    case vignette = "비네트"
    case vignetteEffect = "비네트 효과"
    case bloom = "블룸"
    case gloom = "글룸"
    case crystallize = "크리스탈"
    case pixellate = "픽셀화"
    case pointillize = "점묘화"
    case comicEffect = "만화"
    case edges = "엣지"
    case edgeWork = "엣지 워크"
    
    // 왜곡 필터
    case bumpDistortion = "범프"
    case twirlDistortion = "소용돌이"
    case pinchDistortion = "핀치"
    case circularWrap = "원형 왜곡"
    
    // 커스텀 필터
    case customVignette = "커스텀 비네트"
    case customColorShift = "컬러 시프트"
    
    var id: String { rawValue }
    
    /// 필터가 속한 카테고리
    var category: FilterCategory {
        switch self {
        case .sepiaTone, .colorMonochrome, .vibrance, .hueAdjust, .colorInvert,
             .photoEffectChrome, .photoEffectFade, .photoEffectInstant,
             .photoEffectNoir, .photoEffectProcess, .photoEffectTonal, .photoEffectTransfer:
            return .color
        case .gaussianBlur, .boxBlur, .discBlur, .motionBlur, .zoomBlur:
            return .blur
        case .vignette, .vignetteEffect, .bloom, .gloom, .crystallize,
             .pixellate, .pointillize, .comicEffect, .edges, .edgeWork:
            return .stylize
        case .bumpDistortion, .twirlDistortion, .pinchDistortion, .circularWrap:
            return .distortion
        case .customVignette, .customColorShift:
            return .custom
        }
    }
    
    /// Core Image 필터 이름
    var ciFilterName: String? {
        switch self {
        case .sepiaTone: return "CISepiaTone"
        case .colorMonochrome: return "CIColorMonochrome"
        case .vibrance: return "CIVibrance"
        case .hueAdjust: return "CIHueAdjust"
        case .colorInvert: return "CIColorInvert"
        case .photoEffectChrome: return "CIPhotoEffectChrome"
        case .photoEffectFade: return "CIPhotoEffectFade"
        case .photoEffectInstant: return "CIPhotoEffectInstant"
        case .photoEffectNoir: return "CIPhotoEffectNoir"
        case .photoEffectProcess: return "CIPhotoEffectProcess"
        case .photoEffectTonal: return "CIPhotoEffectTonal"
        case .photoEffectTransfer: return "CIPhotoEffectTransfer"
        case .gaussianBlur: return "CIGaussianBlur"
        case .boxBlur: return "CIBoxBlur"
        case .discBlur: return "CIDiscBlur"
        case .motionBlur: return "CIMotionBlur"
        case .zoomBlur: return "CIZoomBlur"
        case .vignette: return "CIVignette"
        case .vignetteEffect: return "CIVignetteEffect"
        case .bloom: return "CIBloom"
        case .gloom: return "CIGloom"
        case .crystallize: return "CICrystallize"
        case .pixellate: return "CIPixellate"
        case .pointillize: return "CIPointillize"
        case .comicEffect: return "CIComicEffect"
        case .edges: return "CIEdges"
        case .edgeWork: return "CIEdgeWork"
        case .bumpDistortion: return "CIBumpDistortion"
        case .twirlDistortion: return "CITwirlDistortion"
        case .pinchDistortion: return "CIPinchDistortion"
        case .circularWrap: return "CICircularWrap"
        case .customVignette, .customColorShift: return nil // 커스텀 커널 사용
        }
    }
    
    /// 강도 조절 가능 여부
    var hasIntensity: Bool {
        switch self {
        case .colorInvert, .comicEffect, .photoEffectChrome, .photoEffectFade,
             .photoEffectInstant, .photoEffectNoir, .photoEffectProcess,
             .photoEffectTonal, .photoEffectTransfer:
            return false
        default:
            return true
        }
    }
    
    /// 강도 파라미터 이름
    var intensityParameterName: String? {
        switch self {
        case .sepiaTone, .vibrance: return kCIInputIntensityKey
        case .colorMonochrome: return kCIInputIntensityKey
        case .hueAdjust: return kCIInputAngleKey
        case .gaussianBlur, .boxBlur, .discBlur: return kCIInputRadiusKey
        case .motionBlur: return kCIInputRadiusKey
        case .zoomBlur: return kCIInputAmountKey
        case .vignette, .vignetteEffect: return kCIInputIntensityKey
        case .bloom, .gloom: return kCIInputIntensityKey
        case .crystallize, .pixellate, .pointillize: return kCIInputRadiusKey
        case .edges, .edgeWork: return kCIInputIntensityKey
        case .bumpDistortion, .twirlDistortion, .pinchDistortion: return kCIInputRadiusKey
        case .circularWrap: return kCIInputRadiusKey
        case .customVignette, .customColorShift: return "inputIntensity"
        default: return nil
        }
    }
    
    /// 강도 범위 (최소, 최대, 기본값)
    var intensityRange: (min: Float, max: Float, defaultValue: Float) {
        switch self {
        case .sepiaTone, .vibrance, .colorMonochrome:
            return (0, 1, 0.5)
        case .hueAdjust:
            return (-Float.pi, Float.pi, 0)
        case .gaussianBlur:
            return (0, 50, 10)
        case .boxBlur, .discBlur:
            return (0, 100, 20)
        case .motionBlur:
            return (0, 50, 20)
        case .zoomBlur:
            return (0, 50, 10)
        case .vignette:
            return (0, 2, 1)
        case .vignetteEffect:
            return (0, 1, 0.5)
        case .bloom, .gloom:
            return (0, 1, 0.5)
        case .crystallize, .pointillize:
            return (1, 50, 20)
        case .pixellate:
            return (1, 100, 20)
        case .edges, .edgeWork:
            return (0, 10, 1)
        case .bumpDistortion, .twirlDistortion, .pinchDistortion:
            return (0, 500, 150)
        case .circularWrap:
            return (0, 600, 150)
        case .customVignette, .customColorShift:
            return (0, 1, 0.5)
        default:
            return (0, 1, 0.5)
        }
    }
    
    /// 필터 설명
    var description: String {
        switch self {
        case .sepiaTone: return "따뜻한 갈색 톤의 빈티지 효과"
        case .colorMonochrome: return "단색 효과로 분위기 있는 이미지 생성"
        case .vibrance: return "채도를 조절하여 생동감 부여"
        case .hueAdjust: return "색조를 회전시켜 색상 변경"
        case .colorInvert: return "모든 색상을 반전"
        case .photoEffectChrome: return "강렬한 색상의 레트로 효과"
        case .photoEffectFade: return "부드럽게 바랜 빈티지 효과"
        case .photoEffectInstant: return "폴라로이드 스타일 효과"
        case .photoEffectNoir: return "드라마틱한 흑백 효과"
        case .photoEffectProcess: return "차가운 톤의 필름 효과"
        case .photoEffectTonal: return "부드러운 흑백 톤"
        case .photoEffectTransfer: return "따뜻한 빈티지 전사 효과"
        case .gaussianBlur: return "부드러운 가우시안 블러"
        case .boxBlur: return "박스 형태의 균일한 블러"
        case .discBlur: return "원형 디스크 블러"
        case .motionBlur: return "움직임을 표현하는 블러"
        case .zoomBlur: return "중심에서 방사형 블러"
        case .vignette: return "가장자리를 어둡게 처리"
        case .vignetteEffect: return "향상된 비네트 효과"
        case .bloom: return "밝은 부분에 빛 번짐 효과"
        case .gloom: return "어두운 분위기의 빛 효과"
        case .crystallize: return "크리스탈 모자이크 효과"
        case .pixellate: return "픽셀 모자이크 효과"
        case .pointillize: return "점묘화 스타일 효과"
        case .comicEffect: return "만화 스타일 효과"
        case .edges: return "이미지 가장자리 강조"
        case .edgeWork: return "연필 스케치 스타일 엣지"
        case .bumpDistortion: return "볼록한 범프 왜곡"
        case .twirlDistortion: return "회오리 소용돌이 효과"
        case .pinchDistortion: return "중심으로 당기는 효과"
        case .circularWrap: return "원형으로 감싸는 왜곡"
        case .customVignette: return "커스텀 비네트 (Metal 커널)"
        case .customColorShift: return "RGB 채널 시프트 효과"
        }
    }
}
