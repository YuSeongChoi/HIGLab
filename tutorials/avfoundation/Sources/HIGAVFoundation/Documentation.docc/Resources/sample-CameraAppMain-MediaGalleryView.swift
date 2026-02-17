import SwiftUI

// MARK: - 미디어 갤러리 뷰
// HIG: 그리드 레이아웃으로 촬영 내역을 한눈에 파악할 수 있도록 합니다.
// 썸네일은 균일한 크기로 정렬하여 시각적 일관성을 유지합니다.

struct MediaGalleryView: View {
    
    // MARK: - Properties
    
    /// 촬영된 미디어 목록
    let media: [CapturedMedia]
    
    /// Sheet 닫기
    @Environment(\.dismiss) private var dismiss
    
    /// 선택된 미디어 (상세 보기용)
    @State private var selectedMedia: CapturedMedia?
    
    /// 그리드 컬럼 설정
    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if media.isEmpty {
                    emptyStateView
                } else {
                    galleryGridView
                }
            }
            .navigationTitle("촬영한 사진")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $selectedMedia) { media in
            MediaDetailView(media: media)
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 60))
                .foregroundColor(.secondary.opacity(0.5))
            
            Text("촬영한 사진이 없습니다")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("카메라로 사진을 촬영하면\n여기에 표시됩니다")
                .font(.subheadline)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Gallery Grid View
    
    private var galleryGridView: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(media) { item in
                    MediaThumbnailView(media: item)
                        .onTapGesture {
                            selectedMedia = item
                        }
                }
            }
            .padding(.horizontal, 2)
        }
    }
}

// MARK: - 미디어 썸네일 뷰

struct MediaThumbnailView: View {
    let media: CapturedMedia
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottomTrailing) {
                // 썸네일 이미지
                Image(uiImage: media.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.width  // 정사각형
                    )
                    .clipped()
                
                // 비디오 표시 아이콘
                if media.type == .video {
                    Image(systemName: "play.fill")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(6)
                        .background(Color.black.opacity(0.5))
                        .clipShape(Circle())
                        .padding(6)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - 미디어 상세 뷰

struct MediaDetailView: View {
    let media: CapturedMedia
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Image(uiImage: media.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(media.formattedDate)
                            .font(.caption)
                            .foregroundColor(.white)
                        Text(media.formattedTime)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(
                        item: Image(uiImage: media.image),
                        preview: SharePreview(
                            "촬영한 사진",
                            image: Image(uiImage: media.image)
                        )
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Preview

#Preview("갤러리 - 사진 있음") {
    MediaGalleryView(media: CapturedMedia.previewList)
}

#Preview("갤러리 - 비어있음") {
    MediaGalleryView(media: [])
}
