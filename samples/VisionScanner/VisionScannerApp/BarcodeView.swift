//
//  BarcodeView.swift
//  VisionScanner
//
//  바코드/QR 코드 스캔 화면
//

import SwiftUI
import PhotosUI
import Vision

/// 바코드/QR 코드 스캔 뷰
struct BarcodeView: View {
    
    // MARK: - 상태
    
    /// Vision 매니저
    @EnvironmentObject var visionManager: VisionManager
    
    /// 선택된 사진
    @State private var selectedItem: PhotosPickerItem?
    
    /// 분석할 이미지
    @State private var selectedImage: UIImage?
    
    /// 스캔된 바코드 결과
    @State private var results: [BarcodeResult] = []
    
    /// 결과 오버레이 표시 여부
    @State private var showOverlay = true
    
    /// 선택된 바코드 (상세 정보용)
    @State private var selectedBarcode: BarcodeResult?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 이미지 선택 영역
                imageSection
                
                // 설정 섹션
                settingsSection
                
                // 스캔 버튼
                scanButton
                
                // 결과 목록
                if !results.isEmpty {
                    resultsSection
                }
            }
            .padding()
        }
        .navigationTitle("바코드 스캔")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selectedItem) { _, newItem in
            loadImage(from: newItem)
        }
        .sheet(item: $selectedBarcode) { barcode in
            barcodeDetailSheet(barcode)
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
            .frame(minHeight: 200)
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
            Image(systemName: "barcode.viewfinder")
                .font(.system(size: 50))
                .foregroundStyle(.secondary)
            
            Text("바코드나 QR 코드가 있는\n이미지를 선택하세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
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
            ForEach(results) { result in
                let rect = VisionManager.convertBoundingBox(result.boundingBox, to: displaySize)
                
                // 바코드 종류에 따른 색상
                let color: Color = result.symbology == .qr ? .purple : .green
                
                Rectangle()
                    .stroke(color, lineWidth: 3)
                    .background(color.opacity(0.15))
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .overlay(alignment: .top) {
                        // 바코드 종류 라벨
                        Text(result.symbologyName)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(color)
                            .clipShape(Capsule())
                            .position(x: rect.midX, y: rect.minY - 12)
                    }
            }
        }
        .frame(width: displaySize.width, height: displaySize.height)
    }
    
    // MARK: - 설정 섹션
    
    /// 설정 섹션
    private var settingsSection: some View {
        VStack(spacing: 12) {
            // 오버레이 표시 설정
            Toggle(isOn: $showOverlay) {
                HStack {
                    Image(systemName: "rectangle.dashed")
                        .foregroundStyle(.green)
                    Text("인식 영역 표시")
                }
            }
            
            // 지원 바코드 종류 안내
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 8) {
                    supportedBarcodeRow(name: "QR 코드", icon: "qrcode")
                    supportedBarcodeRow(name: "EAN-13 / EAN-8", icon: "barcode")
                    supportedBarcodeRow(name: "Code 128 / Code 39", icon: "barcode")
                    supportedBarcodeRow(name: "UPC-E", icon: "barcode")
                    supportedBarcodeRow(name: "Aztec / PDF417", icon: "square.grid.2x2")
                    supportedBarcodeRow(name: "Data Matrix", icon: "square.grid.3x3")
                }
                .padding(.top, 8)
            } label: {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.blue)
                    Text("지원되는 바코드 종류")
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 지원 바코드 행
    private func supportedBarcodeRow(name: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .frame(width: 24)
            Text(name)
                .font(.subheadline)
        }
    }
    
    // MARK: - 스캔 버튼
    
    /// 스캔 시작 버튼
    private var scanButton: some View {
        Button {
            Task {
                await scanImage()
            }
        } label: {
            HStack {
                if visionManager.isProcessing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "barcode.viewfinder")
                }
                Text(visionManager.isProcessing ? "스캔 중..." : "바코드 스캔 시작")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedImage == nil ? Color.gray : Color.green)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(selectedImage == nil || visionManager.isProcessing)
    }
    
    // MARK: - 결과 섹션
    
    /// 결과 목록 섹션
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("\(results.count)개의 바코드 발견")
                    .font(.headline)
            }
            
            // 바코드 결과 카드들
            ForEach(results) { result in
                barcodeCard(result)
            }
        }
    }
    
    /// 바코드 결과 카드
    private func barcodeCard(_ result: BarcodeResult) -> some View {
        Button {
            selectedBarcode = result
        } label: {
            HStack(spacing: 16) {
                // 바코드 종류 아이콘
                Image(systemName: result.symbology == .qr ? "qrcode" : "barcode")
                    .font(.title2)
                    .foregroundStyle(result.symbology == .qr ? .purple : .green)
                    .frame(width: 44, height: 44)
                    .background(
                        (result.symbology == .qr ? Color.purple : Color.green).opacity(0.15)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // 내용
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.symbologyName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(result.payload)
                        .font(.body)
                        .lineLimit(2)
                        .foregroundStyle(.primary)
                    
                    // URL인 경우 표시
                    if result.isURL {
                        Label("링크", systemImage: "link")
                            .font(.caption2)
                            .foregroundStyle(.blue)
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
    
    // MARK: - 바코드 상세 시트
    
    /// 바코드 상세 정보 시트
    private func barcodeDetailSheet(_ barcode: BarcodeResult) -> some View {
        NavigationStack {
            List {
                // 바코드 정보
                Section("바코드 정보") {
                    LabeledContent("종류", value: barcode.symbologyName)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("내용")
                            .foregroundStyle(.secondary)
                        Text(barcode.payload)
                            .textSelection(.enabled)
                    }
                }
                
                // 액션 버튼들
                Section {
                    // 복사 버튼
                    Button {
                        UIPasteboard.general.string = barcode.payload
                    } label: {
                        Label("내용 복사", systemImage: "doc.on.doc")
                    }
                    
                    // URL인 경우 열기 버튼
                    if barcode.isURL, let url = URL(string: barcode.payload) {
                        Link(destination: url) {
                            Label("링크 열기", systemImage: "safari")
                        }
                    }
                }
            }
            .navigationTitle("바코드 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        selectedBarcode = nil
                    }
                }
            }
        }
        .presentationDetents([.medium])
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
    
    /// 이미지에서 바코드를 스캔합니다
    private func scanImage() async {
        guard let image = selectedImage else { return }
        
        // 이미지 전처리
        let processedImage = ImageProcessor.preprocessForBarcode(image)
        
        // 바코드 스캔 실행
        results = await visionManager.scanBarcodes(in: processedImage)
    }
}

// MARK: - 프리뷰

#Preview {
    NavigationStack {
        BarcodeView()
            .environmentObject(VisionManager())
    }
}
