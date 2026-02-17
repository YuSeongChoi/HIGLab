//
//  ContentView.swift
//  DevicePair
//
//  메인 콘텐츠 뷰 - 탭 기반 네비게이션 구조
//

import SwiftUI

// MARK: - 메인 콘텐츠 뷰

/// 앱의 루트 뷰로 탭 바를 통해 주요 기능에 접근
struct ContentView: View {
    
    /// 환경에서 주입받은 세션 매니저
    @EnvironmentObject private var sessionManager: AccessorySessionManager
    
    /// 현재 선택된 탭
    @State private var selectedTab: Tab = .accessories
    
    /// 에러 알림 표시 여부
    @State private var showingErrorAlert = false
    
    /// 성공 알림 표시 여부
    @State private var showingSuccessAlert = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 페어링된 기기 목록 탭
            PairedAccessoriesView()
                .tabItem {
                    Label("내 기기", systemImage: "rectangle.stack.fill")
                }
                .tag(Tab.accessories)
            
            // 새 기기 검색/페어링 탭
            AccessoryDiscoveryView()
                .tabItem {
                    Label("기기 추가", systemImage: "plus.circle.fill")
                }
                .tag(Tab.discover)
        }
        .tint(.blue)
        // 에러 메시지 알림
        .onChange(of: sessionManager.errorMessage) { _, newValue in
            showingErrorAlert = newValue != nil
        }
        // 성공 메시지 알림
        .onChange(of: sessionManager.successMessage) { _, newValue in
            showingSuccessAlert = newValue != nil
        }
        .alert("오류", isPresented: $showingErrorAlert) {
            Button("확인") {
                sessionManager.errorMessage = nil
            }
        } message: {
            Text(sessionManager.errorMessage ?? "")
        }
        .alert("완료", isPresented: $showingSuccessAlert) {
            Button("확인") {
                sessionManager.successMessage = nil
            }
        } message: {
            Text(sessionManager.successMessage ?? "")
        }
    }
}

// MARK: - 탭 열거형

/// 앱의 탭 정의
enum Tab: Hashable {
    case accessories
    case discover
}

// MARK: - 미리보기

#Preview {
    ContentView()
        .environmentObject(AccessorySessionManager())
}
