// PhotosPicker 스타일링

import SwiftUI
import PhotosUI

struct StyledPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        VStack(spacing: 30) {
            // 기본 텍스트 라벨
            PhotosPicker(selection: $selectedItem) {
                Text("기본 스타일")
            }
            
            // SF Symbol과 텍스트
            PhotosPicker(selection: $selectedItem) {
                Label("사진 추가", systemImage: "photo.badge.plus")
            }
            
            // 커스텀 버튼 스타일
            PhotosPicker(selection: $selectedItem) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("갤러리에서 선택")
                }
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // 원형 버튼
            PhotosPicker(selection: $selectedItem) {
                Image(systemName: "plus")
                    .font(.title)
                    .frame(width: 60, height: 60)
                    .background(.blue.gradient)
                    .foregroundStyle(.white)
                    .clipShape(Circle())
            }
            
            // 이미지 자체를 버튼으로
            PhotosPicker(selection: $selectedItem) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.gray.opacity(0.2))
                        .frame(width: 200, height: 150)
                    
                    VStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                        Text("탭하여 선택")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}
