// GalleryApp 구조 설계

import SwiftUI
import PhotosUI
import Observation

// MARK: - ViewModel
@Observable
final class GalleryViewModel {
    var selectedItems: [PhotosPickerItem] = []
    var loadedImages: [UIImage] = []
    var isLoading = false
    
    func loadImages() async {
        isLoading = true
        defer { isLoading = false }
        
        loadedImages.removeAll()
        
        for item in selectedItems {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                loadedImages.append(image)
            }
        }
    }
}

// MARK: - App Entry
@main
struct GalleryApp: App {
    @State private var viewModel = GalleryViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
    }
}
