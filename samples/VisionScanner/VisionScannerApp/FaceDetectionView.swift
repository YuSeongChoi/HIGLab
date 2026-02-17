//
//  FaceDetectionView.swift
//  VisionScanner
//
//  얼굴 인식 화면
//

import SwiftUI
import PhotosUI
import Vision

/// 얼굴 인식 뷰
struct FaceDetectionView: View {
    
    // MARK: - 상태
    
    /// Vision 매니저
    @EnvironmentObject var visionManager: VisionManager
    
    /// 선택된 사진
    @State private var selectedItem: PhotosPickerItem?
    
    /// 분석할 이미지
    @State private var selectedImage: UIImage?
    
    /// 인식된 얼굴 결과
    @State private var results: [FaceDetectionResult] = []
    
    /// 랜드마크 검출 여부
    @State private var detectLandmarks = true
    
    /// 결과 오버레이 표시 여부
    @State private var showOverlay = true
    
    /// 랜드마크 오버레이 표시 여부
    @State private var showLandmarks = true
    
    /// 선택된 얼굴 (상세 정보용)
    @State private var selectedFaceIndex: Int?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 이미지 선택 영역
                imageSection
                
                // 설정 섹션
                settingsSection
                
                // 분석 버튼
                detectButton
                
                // 결과 섹션
                if !results.isEmpty {
                    resultsSection
                }
            }
            .padding()
        }
        .navigationTitle("얼굴 인식")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { _, newItem in
            loadImage(from: newItem)
        }
        .sheet(item: Binding(
            get: { selectedFaceIndex.map { FaceIndexWrapper(index: $0) } },
            set: { selectedFaceIndex = $0?.index }
        )) { wrapper in
            if wrapper.index < results.count {
                faceDetailSheet(results[wrapper.index], index: wrapper.index)
            }
        }
        .alert("오류", isPresented: .init(
            get: { visionManager.errorMessage != nil },
            set: { if !$0 { visionManager.clearError() } }
        )) {
            Button("확인") { visionManager.clearError() }
        } message: {
            Text(visionManager.errorMessage ?? "")
        }
    }
    
    // MARK: - 이미지 섹션
    
    /// 이미지 선택 및 표시 영역
    private var imageSection: some View {
        VStack(spacing: 12) {
            // 이미지 표시 영역
            ZStack {
                if let image = selectedImage {
                    // 선택된 이미지 표시
                    GeometryReader { geometry in
                        ZStack {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                            
                            // 인식된 영역 오버레이
                            if showOverlay {
                                overlayView(in: geometry.size, image: image)
                            }
                        }
                    }
                    .aspectRatio(selectedImage?.size ?? CGSize(width: 1, height: 1), contentMode: .fit)
                } else {
                    // 플레이스홀더
                    placeholderView
                }
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: 250)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // 이미지 선택 버튼
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Label(selectedImage == nil ? "이미지 선택" : "다른 이미지 선택", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }
    
    /// 플레이스홀더 뷰
    private var placeholderView: some View {
        VStack(spacing: 16) {
            Image(systemName: "face.smiling")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("얼굴이 포함된 이미지를 선택하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    /// 인식된 영역 오버레이
    private func overlayView(in size: CGSize, image: UIImage) -> some View {
        // 이미지 실제 표시 크기 계산
        let imageAspect = image.size.width / image.size.height
        let viewAspect = size.width / size.height
        
        let displaySize: CGSize
        if imageAspect > viewAspect {
            displaySize = CGSize(width: size.width, height: size.width / imageAspect)
        } else {
            displaySize = CGSize(width: size.height * imageAspect, height: size.height)
        }
        
        return ZStack {
            ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                let rect = VisionManager.convertBoundingBox(result.boundingBox, to: displaySize)
                
                ZStack {
                    // 얼굴 영역 박스
                    Rectangle()
                        .stroke(Color.orange, lineWidth: 3)
                        .background(Color.orange.opacity(0.1))
                        .frame(width: rect.width, height: rect.height)
                    
                    // 얼굴 번호 라벨
                    Text("\(index + 1)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(6)
                        .background(Color.orange)
                        .clipShape(Circle())
                        .offset(x: -rect.width/2 + 15, y: -rect.height/2 + 15)
                    
                    // 랜드마크 표시
                    if showLandmarks, let landmarks = result.landmarks {
                        landmarkOverlay(landmarks: landmarks, in: rect.size)
                    }
                }
                .position(x: rect.midX, y: rect.midY)
            }
        }
        .frame(width: displaySize.width, height: displaySize.height)
    }
    
    /// 얼굴 랜드마크 오버레이
    private func landmarkOverlay(landmarks: VNFaceLandmarks2D, in size: CGSize) -> some View {
        Canvas { context, canvasSize in
            // 왼쪽 눈
            if let leftEye = landmarks.leftEye {
                drawLandmark(leftEye, in: context, size: size, color: .cyan)
            }
            
            // 오른쪽 눈
            if let rightEye = landmarks.rightEye {
                drawLandmark(rightEye, in: context, size: size, color: .cyan)
            }
            
            // 코
            if let nose = landmarks.nose {
                drawLandmark(nose, in: context, size: size, color: .yellow)
            }
            
            // 입술 (외곽)
            if let outerLips = landmarks.outerLips {
                drawLandmark(outerLips, in: context, size: size, color: .pink)
            }
            
            // 눈썹
            if let leftEyebrow = landmarks.leftEyebrow {
                drawLandmark(leftEyebrow, in: context, size: size, color: .mint)
            }
            if let rightEyebrow = landmarks.rightEyebrow {
                drawLandmark(rightEyebrow, in: context, size: size, color: .mint)
            }
        }
        .frame(width: size.width, height: size.height)
    }
    
    /// 랜드마크 포인트들을 그립니다
    private func drawLandmark(_ region: VNFaceLandmarkRegion2D, in context: GraphicsContext, size: CGSize, color: Color) {
        guard region.pointCount > 0 else { return }
        
        let points = region.normalizedPoints
        
        for point in points {
            // 정규화된 좌표를 실제 좌표로 변환 (Y축 반전)
            let x = point.x * size.width - size.width/2
            let y = (1 - point.y) * size.height - size.height/2
            
            let circle = Path(ellipseIn: CGRect(x: x - 2, y: y - 2, width: 4, height: 4))
            context.fill(circle, with: .color(color))
        }
    }
    
    // MARK: - 설정 섹션
    
    /// 설정 섹션
    private var settingsSection: some View {
        VStack(spacing: 12) {
            // 랜드마크 검출 설정
            Toggle(isOn: $detectLandmarks) {
                HStack {
                    Image(systemName: "eye")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading) {
                        Text("랜드마크 검출")
                        Text("눈, 코, 입 위치를 분석합니다")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            // 오버레이 표시 설정
            Toggle(isOn: $showOverlay) {
                HStack {
                    Image(systemName: "rectangle.dashed")
                        .foregroundStyle(.orange)
                    Text("얼굴 영역 표시")
                }
            }
            
            // 랜드마크 표시 설정 (랜드마크 검출이 활성화된 경우만)
            if detectLandmarks {
                Toggle(isOn: $showLandmarks) {
                    HStack {
                        Image(systemName: "point.3.connected.trianglepath.dotted")
                            .foregroundStyle(.cyan)
                        Text("랜드마크 포인트 표시")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - 분석 버튼
    
    /// 분석 시작 버튼
    private var detectButton: some View {
        Button {
            Task {
                await detectFaces()
            }
        } label: {
            HStack {
                if visionManager.isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "face.smiling")
                }
                Text(visionManager.isProcessing ? "분석 중..." : "얼굴 인식 시작")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedImage == nil ? Color.gray : Color.orange)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(selectedImage == nil || visionManager.isProcessing)
    }
    
    // MARK: - 결과 섹션
    
    /// 결과 섹션
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("\(results.count)개의 얼굴 발견")
                    .font(.headline)
            }
            
            // 얼굴 결과 카드들
            ForEach(Array(results.enumerated()), id: \.element.id) { index, result in
                faceCard(result, index: index)
            }
        }
    }
    
    /// 얼굴 결과 카드
    private func faceCard(_ result: FaceDetectionResult, index: Int) -> some View {
        Button {
            selectedFaceIndex = index
        } label: {
            HStack(spacing: 16) {
                // 얼굴 번호
                Text("\(index + 1)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Color.orange)
                    .clipShape(Circle())
                
                // 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text("얼굴 \(index + 1)")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(result.faceOrientationDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    if result.landmarks != nil {
                        HStack {
                            Image(systemName: "point.3.connected.trianglepath.dotted")
                            Text("\(result.landmarkCount)개 랜드마크")
                        }
                        .font(.caption)
                        .foregroundStyle(.cyan)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 5)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 얼굴 상세 시트
    
    /// 얼굴 상세 정보 시트
    private func faceDetailSheet(_ face: FaceDetectionResult, index: Int) -> some View {
        NavigationStack {
            List {
                // 기본 정보
                Section("얼굴 정보") {
                    LabeledContent("얼굴 번호", value: "\(index + 1)")
                    LabeledContent("방향", value: face.faceOrientationDescription)
                    
                    if let yaw = face.yaw {
                        LabeledContent("좌우 회전 (Yaw)", value: String(format: "%.1f°", yaw * 180 / .pi))
                    }
                    
                    if let roll = face.roll {
                        LabeledContent("기울기 (Roll)", value: String(format: "%.1f°", roll * 180 / .pi))
                    }
                }
                
                // 위치 정보
                Section("위치 (정규화 좌표)") {
                    LabeledContent("X", value: String(format: "%.3f", face.boundingBox.origin.x))
                    LabeledContent("Y", value: String(format: "%.3f", face.boundingBox.origin.y))
                    LabeledContent("너비", value: String(format: "%.3f", face.boundingBox.width))
                    LabeledContent("높이", value: String(format: "%.3f", face.boundingBox.height))
                }
                
                // 랜드마크 정보
                if let landmarks = face.landmarks {
                    Section("랜드마크") {
                        landmarkRow("왼쪽 눈", landmark: landmarks.leftEye, icon: "eye", color: .cyan)
                        landmarkRow("오른쪽 눈", landmark: landmarks.rightEye, icon: "eye", color: .cyan)
                        landmarkRow("코", landmark: landmarks.nose, icon: "nose", color: .yellow)
                        landmarkRow("입술", landmark: landmarks.outerLips, icon: "mouth", color: .pink)
                        landmarkRow("왼쪽 눈썹", landmark: landmarks.leftEyebrow, icon: "eyebrow", color: .mint)
                        landmarkRow("오른쪽 눈썹", landmark: landmarks.rightEyebrow, icon: "eyebrow", color: .mint)
                    }
                }
            }
            .navigationTitle("얼굴 \(index + 1) 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        selectedFaceIndex = nil
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    /// 랜드마크 행
    private func landmarkRow(_ name: String, landmark: VNFaceLandmarkRegion2D?, icon: String, color: Color) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            
            Text(name)
            
            Spacer()
            
            if let landmark = landmark {
                Text("\(landmark.pointCount)개 포인트")
                    .foregroundStyle(.secondary)
            } else {
                Text("검출 안됨")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - 메서드
    
    /// 선택된 아이템에서 이미지를 로드합니다
    private func loadImage(from item: PhotosPickerItem?) {
        guard let item else { return }
        
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run {
                    selectedImage = image
                    results = []  // 이전 결과 초기화
                }
            }
        }
    }
    
    /// 얼굴 인식을 실행합니다
    private func detectFaces() async {
        guard let image = selectedImage else { return }
        
        // 이미지 전처리
        let processedImage = ImageProcessor.preprocessForFaceDetection(image)
        
        // 얼굴 인식 실행
        results = await visionManager.detectFaces(
            in: processedImage,
            detectLandmarks: detectLandmarks
        )
    }
}

// MARK: - 헬퍼 타입

/// 시트 바인딩을 위한 래퍼
private struct FaceIndexWrapper: Identifiable {
    let index: Int
    var id: Int { index }
}

// MARK: - 프리뷰

#Preview {
    NavigationStack {
        FaceDetectionView()
            .environmentObject(VisionManager())
    }
}
