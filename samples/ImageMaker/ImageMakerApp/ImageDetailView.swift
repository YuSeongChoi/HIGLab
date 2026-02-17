import SwiftUI

// MARK: - ImageDetailView
// 이미지 상세 보기 화면
// 전체 화면 이미지 보기, 정보 표시, 공유 및 관리 기능

/// 이미지 상세 뷰
struct ImageDetailView: View {
    
    // MARK: - Properties
    
    let image: GeneratedImage
    
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var storageManager: ImageStorageManager
    @EnvironmentObject private var viewModel: ImageMakerViewModel
    
    // MARK: - State
    
    /// 정보 패널 표시 여부
    @State private var showInfo = true
    
    /// 메모 편집 모드
    @State private var isEditingNote = false
    
    /// 편집 중인 메모
    @State private var editingNote: String = ""
    
    /// 삭제 확인 표시
    @State private var showDeleteConfirmation = false
    
    /// 줌 스케일
    @State private var scale: CGFloat = 1.0
    
    /// 줌 오프셋
    @State private var offset: CGSize = .zero
    
    /// 마지막 스케일 (제스처용)
    @State private var lastScale: CGFloat = 1.0
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // 배경
                    Color.black.ignoresSafeArea()
                    
                    // 이미지
                    imageView(in: geometry)
                    
                    // 정보 오버레이
                    if showInfo {
                        infoOverlay
                    }
                }
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showInfo.toggle()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $isEditingNote) {
                noteEditSheet
            }
            .confirmationDialog(
                "이미지 삭제",
                isPresented: $showDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    deleteImage()
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("이 이미지를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
    
    // MARK: - Subviews
    
    /// 이미지 뷰 (줌/팬 제스처 포함)
    private func imageView(in geometry: GeometryProxy) -> some View {
        storageManager.image(for: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(magnificationGesture)
            .gesture(dragGesture)
            .onDoubleTap { location in
                withAnimation(.spring(duration: 0.3)) {
                    if scale > 1 {
                        scale = 1
                        offset = .zero
                    } else {
                        scale = 2.5
                    }
                }
            }
    }
    
    /// 정보 오버레이
    private var infoOverlay: some View {
        VStack {
            Spacer()
            
            // 하단 정보 패널
            VStack(alignment: .leading, spacing: 16) {
                // 프롬프트
                VStack(alignment: .leading, spacing: 8) {
                    Text("프롬프트")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(image.prompt)
                        .font(.body)
                        .foregroundStyle(.white)
                }
                
                // 메타 정보
                HStack(spacing: 20) {
                    // 스타일
                    VStack(alignment: .leading, spacing: 4) {
                        Text("스타일")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: image.style.iconName)
                                .foregroundStyle(image.style.themeColor)
                            Text(image.style.displayName)
                                .foregroundStyle(.white)
                        }
                        .font(.subheadline)
                    }
                    
                    // 생성 시간
                    VStack(alignment: .leading, spacing: 4) {
                        Text("생성 시간")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(image.detailedDateString)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                    }
                }
                
                // 메모
                if let note = image.note, !note.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("메모")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            Button {
                                editingNote = note
                                isEditingNote = true
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                // 액션 버튼들
                actionButtons
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    /// 액션 버튼들
    private var actionButtons: some View {
        HStack(spacing: 12) {
            // 즐겨찾기
            ActionButton(
                icon: image.isFavorite ? "heart.fill" : "heart",
                title: "즐겨찾기",
                color: image.isFavorite ? .red : .white
            ) {
                storageManager.toggleFavorite(image)
                HapticFeedback.selection()
            }
            
            // 메모 추가/편집
            ActionButton(
                icon: "note.text",
                title: "메모",
                color: image.note != nil ? .yellow : .white
            ) {
                editingNote = image.note ?? ""
                isEditingNote = true
            }
            
            // 사진 앱에 저장
            ActionButton(
                icon: "square.and.arrow.down",
                title: "저장",
                color: .white
            ) {
                saveToPhotos()
            }
            
            // 공유
            ShareLink(item: storageManager.image(for: image), preview: SharePreview(image.prompt, image: storageManager.image(for: image))) {
                VStack(spacing: 4) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                    Text("공유")
                        .font(.caption2)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    /// 툴바 콘텐츠
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                // 사진 앱에 저장
                Button {
                    saveToPhotos()
                } label: {
                    Label("사진 앱에 저장", systemImage: "square.and.arrow.down")
                }
                
                // 공유
                ShareLink(item: storageManager.image(for: image), preview: SharePreview(image.prompt, image: storageManager.image(for: image))) {
                    Label("공유", systemImage: "square.and.arrow.up")
                }
                
                // 프롬프트 복사
                Button {
                    UIPasteboard.general.string = image.prompt
                    HapticFeedback.success()
                } label: {
                    Label("프롬프트 복사", systemImage: "doc.on.doc")
                }
                
                Divider()
                
                // 삭제
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
    
    /// 메모 편집 시트
    private var noteEditSheet: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("이미지에 대한 메모를 남겨보세요")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                TextEditor(text: $editingNote)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Spacer()
            }
            .padding()
            .navigationTitle("메모 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        isEditingNote = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        storageManager.updateNote(for: image, note: editingNote)
                        isEditingNote = false
                        HapticFeedback.success()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    // MARK: - Gestures
    
    /// 확대/축소 제스처
    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let delta = value.magnification / lastScale
                lastScale = value.magnification
                scale = min(max(scale * delta, 1), 5)
            }
            .onEnded { _ in
                lastScale = 1
                if scale < 1 {
                    withAnimation(.spring(duration: 0.3)) {
                        scale = 1
                        offset = .zero
                    }
                }
            }
    }
    
    /// 드래그 제스처 (줌 상태에서만)
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1 {
                    offset = value.translation
                }
            }
            .onEnded { _ in
                if scale <= 1 {
                    withAnimation(.spring(duration: 0.3)) {
                        offset = .zero
                    }
                }
            }
    }
    
    // MARK: - Actions
    
    /// 사진 앱에 저장
    private func saveToPhotos() {
        Task {
            let success = await storageManager.saveToPhotoLibrary(image)
            if success {
                HapticFeedback.success()
            } else {
                HapticFeedback.error()
            }
        }
    }
    
    /// 이미지 삭제
    private func deleteImage() {
        storageManager.deleteImage(image)
        dismiss()
        HapticFeedback.success()
    }
}

// MARK: - ActionButton
// 액션 버튼 컴포넌트

/// 액션 버튼 뷰
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(color)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Double Tap Gesture
// 더블 탭 제스처 확장

extension View {
    func onDoubleTap(perform action: @escaping (CGPoint) -> Void) -> some View {
        self.gesture(
            SpatialTapGesture(count: 2)
                .onEnded { event in
                    action(event.location)
                }
        )
    }
}

// MARK: - Preview

#Preview {
    ImageDetailView(image: .sample)
        .environmentObject(ImageStorageManager.shared)
        .environmentObject(ImageMakerViewModel())
}
