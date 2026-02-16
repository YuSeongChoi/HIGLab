// ContentView - 탭 기반 네비게이션

import SwiftUI
import PhotosUI

struct ContentView: View {
    var body: some View {
        TabView {
            GalleryTab()
                .tabItem {
                    Label("갤러리", systemImage: "photo.on.rectangle")
                }
            
            SettingsTab()
                .tabItem {
                    Label("설정", systemImage: "gear")
                }
        }
    }
}

struct GalleryTab: View {
    @Environment(GalleryViewModel.self) private var viewModel
    
    var body: some View {
        NavigationStack {
            VStack {
                PhotosPicker(
                    selection: Bindable(viewModel).selectedItems,
                    maxSelectionCount: 10,
                    matching: .images
                ) {
                    Label("사진 추가", systemImage: "plus")
                }
                
                // 선택된 이미지 그리드로 표시
                // (다음 챕터에서 구현)
            }
            .navigationTitle("내 갤러리")
        }
    }
}

struct SettingsTab: View {
    var body: some View {
        NavigationStack {
            List {
                Text("설정 항목들...")
            }
            .navigationTitle("설정")
        }
    }
}
