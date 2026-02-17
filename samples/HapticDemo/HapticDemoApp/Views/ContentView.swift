// ContentView.swift
// HapticDemo - Core Haptics 샘플
// 메인 탭 뷰 컨테이너

import SwiftUI

// MARK: - 메인 콘텐츠 뷰
struct ContentView: View {
    @EnvironmentObject var hapticManager: HapticEngineManager
    @State private var selectedTab: TabItem = .gallery
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 프리셋 갤러리 탭
            PresetGalleryView()
                .tabItem {
                    Label("갤러리", systemImage: "square.grid.2x2.fill")
                }
                .tag(TabItem.gallery)
            
            // 패턴 에디터 탭
            PatternEditorView()
                .tabItem {
                    Label("에디터", systemImage: "slider.horizontal.3")
                }
                .tag(TabItem.editor)
            
            // 햅틱 컨트롤 탭
            HapticControlView()
                .tabItem {
                    Label("컨트롤", systemImage: "dial.high.fill")
                }
                .tag(TabItem.control)
            
            // 설정 탭
            SettingsView()
                .tabItem {
                    Label("설정", systemImage: "gearshape.fill")
                }
                .tag(TabItem.settings)
        }
        .onAppear {
            // 앱 시작 시 햅틱 엔진 상태 확인
            if !hapticManager.supportsHaptics {
                // 시뮬레이터나 미지원 기기 알림
            }
        }
    }
}

// MARK: - 탭 아이템
enum TabItem: Hashable {
    case gallery
    case editor
    case control
    case settings
}

// MARK: - 설정 뷰
struct SettingsView: View {
    @EnvironmentObject var hapticManager: HapticEngineManager
    
    var body: some View {
        NavigationStack {
            List {
                // 엔진 상태 섹션
                Section {
                    HStack {
                        Text("엔진 상태")
                        Spacer()
                        StatusBadge(state: hapticManager.state)
                    }
                    
                    HStack {
                        Text("햅틱 지원")
                        Spacer()
                        Image(systemName: hapticManager.supportsHaptics ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(hapticManager.supportsHaptics ? .green : .red)
                    }
                    
                    if let currentPattern = hapticManager.currentPatternName {
                        HStack {
                            Text("재생 중")
                            Spacer()
                            Text(currentPattern)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("엔진 정보")
                }
                
                // 엔진 제어 섹션
                Section {
                    Button {
                        hapticManager.restartEngine()
                    } label: {
                        Label("엔진 재시작", systemImage: "arrow.clockwise")
                    }
                    
                    Button {
                        hapticManager.stopCurrentPlayback()
                    } label: {
                        Label("재생 중지", systemImage: "stop.fill")
                    }
                    .disabled(hapticManager.state != .playing)
                } header: {
                    Text("엔진 제어")
                }
                
                // 전역 설정 섹션
                Section {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("전역 강도")
                            Spacer()
                            Text("\(Int(hapticManager.globalIntensity * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $hapticManager.globalIntensity, in: 0...1)
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("전역 선명도")
                            Spacer()
                            Text("\(Int(hapticManager.globalSharpness * 100))%")
                                .foregroundColor(.secondary)
                        }
                        Slider(value: $hapticManager.globalSharpness, in: 0...1)
                    }
                } header: {
                    Text("전역 설정")
                }
                
                // 에러 정보 섹션
                if let error = hapticManager.lastError {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    } header: {
                        Text("마지막 오류")
                    }
                }
                
                // 정보 섹션
                Section {
                    Link(destination: URL(string: "https://developer.apple.com/documentation/corehaptics")!) {
                        Label("Core Haptics 문서", systemImage: "book.fill")
                    }
                    
                    Link(destination: URL(string: "https://developer.apple.com/design/human-interface-guidelines/playing-haptics")!) {
                        Label("HIG: 햅틱 가이드", systemImage: "doc.text.fill")
                    }
                } header: {
                    Text("참고 자료")
                }
            }
            .navigationTitle("설정")
        }
    }
}

// MARK: - 상태 배지
struct StatusBadge: View {
    let state: HapticEngineState
    
    var body: some View {
        Text(state.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
    
    private var backgroundColor: Color {
        switch state {
        case .ready: return .green
        case .playing: return .blue
        case .stopped: return .orange
        case .error: return .red
        case .notInitialized: return .gray
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HapticEngineManager())
}
