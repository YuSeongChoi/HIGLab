// SmartCropApp.swift
// SmartCrop - HIG Lab 샘플 프로젝트
// iOS 26 ExtensibleImage API 활용

import SwiftUI

/// SmartCrop 앱의 진입점
/// iOS 26의 ExtensibleImage API를 활용한 이미지 처리 앱입니다
@main
struct SmartCropApp: App {
    /// 이미지 처리 모델 (앱 전체에서 공유)
    @State private var processingModel = ImageProcessingModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(processingModel)
        }
    }
}

// MARK: - 앱 상수

/// 앱 전역 상수
enum AppConstants {
    /// 앱 이름
    static let appName = "SmartCrop"
    
    /// 앱 버전
    static let version = "1.0.0"
    
    /// 최대 이미지 크기 (픽셀)
    /// 메모리 효율을 위해 큰 이미지는 이 크기로 축소됩니다
    static let maxImageDimension: CGFloat = 4096
    
    /// 썸네일 크기
    static let thumbnailSize: CGFloat = 120
    
    /// 애니메이션 지속 시간
    static let animationDuration: Double = 0.3
    
    /// 최소 iOS 버전 요구사항
    static let minimumIOSVersion = 26.0
}

// MARK: - 접근성 레이블

/// 접근성 레이블 상수
enum AccessibilityLabels {
    static let selectImage = "이미지 선택"
    static let processImage = "이미지 처리"
    static let saveImage = "이미지 저장"
    static let shareImage = "이미지 공유"
    static let compareImages = "전후 비교"
    static let undoAction = "실행 취소"
    static let resetAction = "초기화"
}
