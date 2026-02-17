//
//  ContentView.swift
//  ARFurniture
//
//  메인 컨텐츠 뷰 - AR 뷰 + UI 오버레이
//

import SwiftUI
import RealityKit

/// 메인 컨텐츠 뷰
struct ContentView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var arManager: ARManager
    
    /// 카탈로그 시트 표시 여부
    @State private var showCatalog = false
    
    /// 설정 시트 표시 여부
    @State private var showSettings = false
    
    /// 선택된 카테고리
    @State private var selectedCategory: FurnitureCategory = .chair
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // AR 뷰 (전체 화면)
            ARViewContainer()
                .edgesIgnoringSafeArea(.all)
            
            // UI 오버레이
            VStack {
                // 상단 바
                topBar
                
                Spacer()
                
                // 상태 표시
                statusIndicator
                
                // 선택된 가구가 있으면 배치 컨트롤 표시
                if arManager.selectedFurniture != nil {
                    PlacementView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                // 하단 바
                bottomBar
            }
            .padding()
            
            // 코칭 오버레이
            if arManager.showCoaching {
                coachingOverlay
            }
        }
        .sheet(isPresented: $showCatalog) {
            CatalogView(selectedCategory: $selectedCategory)
        }
        .animation(.easeInOut, value: arManager.selectedFurniture != nil)
    }
    
    // MARK: - Top Bar
    
    /// 상단 바 (리셋, 설정 버튼)
    private var topBar: some View {
        HStack {
            // 리셋 버튼
            Button {
                withAnimation {
                    arManager.resetSession()
                }
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // 배치된 가구 개수
            if !arManager.placedFurnitures.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "cube.fill")
                    Text("\(arManager.placedFurnitures.count)")
                }
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            
            Spacer()
            
            // 설정 버튼
            Button {
                showSettings.toggle()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
        }
    }
    
    // MARK: - Status Indicator
    
    /// 상태 표시기
    private var statusIndicator: some View {
        HStack(spacing: 8) {
            // 상태 아이콘
            statusIcon
            
            // 상태 메시지
            Text(arManager.sessionState.description)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .opacity(shouldShowStatus ? 1 : 0)
        .animation(.easeInOut, value: arManager.sessionState)
    }
    
    /// 상태 아이콘
    @ViewBuilder
    private var statusIcon: some View {
        switch arManager.sessionState {
        case .notStarted:
            Image(systemName: "camera.fill")
                .foregroundColor(.gray)
        case .initializing:
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.8)
        case .running:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .limited:
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
        case .failed:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        case .paused:
            Image(systemName: "pause.circle.fill")
                .foregroundColor(.orange)
        }
    }
    
    /// 상태 표시 여부
    private var shouldShowStatus: Bool {
        switch arManager.sessionState {
        case .running:
            return arManager.selectedFurniture == nil
        default:
            return true
        }
    }
    
    // MARK: - Bottom Bar
    
    /// 하단 바 (카탈로그 버튼)
    private var bottomBar: some View {
        HStack {
            Spacer()
            
            // 카탈로그 버튼
            Button {
                showCatalog.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("가구 선택")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            }
            
            Spacer()
        }
    }
    
    // MARK: - Coaching Overlay
    
    /// 코칭 오버레이 (초기 안내)
    private var coachingOverlay: some View {
        VStack(spacing: 20) {
            // 애니메이션 아이콘
            Image(systemName: "iphone.gen3.radiowaves.left.and.right")
                .font(.system(size: 60))
                .foregroundColor(.white)
                .symbolEffect(.pulse)
            
            Text("주변 환경을 스캔하세요")
                .font(.title2.bold())
                .foregroundColor(.white)
            
            Text("기기를 천천히 움직여\n바닥 평면을 인식하게 해주세요")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
            
            // 평면 감지 상태
            if arManager.detectedPlaneCount > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("\(arManager.detectedPlaneCount)개 평면 감지됨")
                        .foregroundColor(.white)
                }
                .font(.subheadline.bold())
                .padding(.top, 10)
            }
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding()
        .transition(.opacity)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(ARManager())
}
