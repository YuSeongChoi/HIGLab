// FilterLabApp.swift
// FilterLab - 앱 진입점
// HIG Lab 샘플 프로젝트

import SwiftUI

// MARK: - 앱 진입점
@main
struct FilterLabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - 앱 상태
/// 앱 전체에서 공유되는 상태
@Observable
class AppState {
    /// 이미지 프로세서
    var processor = ImageProcessor()
    
    /// 필터 체인
    var filterChain = FilterChain()
    
    /// 선택된 필터 카테고리
    var selectedCategory: FilterCategory = .color
    
    /// 비교 모드 (원본/필터 비교)
    var isCompareMode: Bool = false
    
    /// 저장 완료 알림
    var showSaveSuccess: Bool = false
    
    /// 에러 알림
    var showError: Bool = false
    
    /// 프리셋 시트 표시
    var showPresets: Bool = false
    
    /// 필터 선택 시트 표시
    var showFilterPicker: Bool = false
}
