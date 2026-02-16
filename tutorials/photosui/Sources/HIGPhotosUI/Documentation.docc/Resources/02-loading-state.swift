// 로딩 상태 관리

import SwiftUI
import PhotosUI

// 로딩 상태 enum
enum ImageLoadingState {
    case empty
    case loading
    case loaded(Image)
    case failed(Error)
}

struct LoadingStateView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var loadingState: ImageLoadingState = .empty
    
    var body: some View {
        VStack {
            // 상태에 따른 UI 분기
            switch loadingState {
            case .empty:
                ContentUnavailableView(
                    "사진을 선택하세요",
                    systemImage: "photo.badge.plus"
                )
                
            case .loading:
                ProgressView("로딩 중...")
                    .frame(maxHeight: .infinity)
                
            case .loaded(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding()
                
            case .failed(let error):
                ContentUnavailableView(
                    "로딩 실패",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            }
            
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label("사진 선택", systemImage: "photo")
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding()
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                await loadImage(from: newItem)
            }
        }
    }
    
    private func loadImage(from item: PhotosPickerItem?) async {
        guard let item else {
            loadingState = .empty
            return
        }
        
        loadingState = .loading
        
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                loadingState = .loaded(Image(uiImage: uiImage))
            } else {
                loadingState = .failed(LoadingError.invalidData)
            }
        } catch {
            loadingState = .failed(error)
        }
    }
}

enum LoadingError: LocalizedError {
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .invalidData:
            return "이미지 데이터를 변환할 수 없습니다."
        }
    }
}
