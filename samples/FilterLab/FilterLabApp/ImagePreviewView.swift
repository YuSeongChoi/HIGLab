// ImagePreviewView.swift
// FilterLab - 이미지 프리뷰 뷰
// HIG Lab 샘플 프로젝트

import SwiftUI

// MARK: - 이미지 프리뷰 뷰
struct ImagePreviewView: View {
    let appState: AppState
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var showOriginal: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경 패턴 (투명 이미지용)
                CheckerboardBackground()
                
                // 이미지 표시
                if let displayImage = showOriginal ? 
                    appState.processor.originalImage : 
                    appState.processor.processedImage {
                    
                    Image(uiImage: displayImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(combinedGesture)
                        .onTapGesture(count: 2) {
                            // 더블 탭으로 리셋
                            withAnimation(.spring(response: 0.3)) {
                                scale = 1.0
                                offset = .zero
                            }
                        }
                }
                
                // 처리 중 인디케이터
                if appState.processor.isProcessing {
                    ProcessingOverlay()
                }
                
                // 비교 모드 인디케이터
                if showOriginal {
                    VStack {
                        HStack {
                            Spacer()
                            Text("원본")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                                .padding()
                        }
                        Spacer()
                    }
                }
                
                // 비교 버튼
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        CompareButton(isPressed: $showOriginal)
                            .padding()
                    }
                }
            }
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - 제스처
    private var combinedGesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    let delta = value / lastScale
                    lastScale = value
                    scale = min(max(scale * delta, 0.5), 5.0)
                }
                .onEnded { _ in
                    lastScale = 1.0
                    // 최소 크기 이하면 리셋
                    if scale < 1.0 {
                        withAnimation(.spring(response: 0.3)) {
                            scale = 1.0
                            offset = .zero
                        }
                    }
                },
            DragGesture()
                .onChanged { value in
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
                .onEnded { _ in
                    lastOffset = offset
                }
        )
    }
}

// MARK: - 체커보드 배경
/// 투명 이미지를 위한 체커보드 패턴 배경
struct CheckerboardBackground: View {
    let squareSize: CGFloat = 10
    
    var body: some View {
        Canvas { context, size in
            let columns = Int(ceil(size.width / squareSize))
            let rows = Int(ceil(size.height / squareSize))
            
            for row in 0..<rows {
                for col in 0..<columns {
                    let isLight = (row + col) % 2 == 0
                    let rect = CGRect(
                        x: CGFloat(col) * squareSize,
                        y: CGFloat(row) * squareSize,
                        width: squareSize,
                        height: squareSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isLight ? Color(.systemGray5) : Color(.systemGray4))
                    )
                }
            }
        }
    }
}

// MARK: - 처리 중 오버레이
struct ProcessingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
            
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                
                Text("필터 적용 중...")
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

// MARK: - 비교 버튼
/// 길게 누르면 원본을 보여주는 버튼
struct CompareButton: View {
    @Binding var isPressed: Bool
    
    var body: some View {
        Button {
            // 단일 탭은 무시
        } label: {
            Image(systemName: isPressed ? "eye.fill" : "eye")
                .font(.title2)
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(.black.opacity(0.5))
                )
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.1)
                .onChanged { pressing in
                    isPressed = pressing
                }
        )
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

// MARK: - 히스토그램 뷰 (보너스 기능)
struct HistogramView: View {
    let image: UIImage?
    
    @State private var redValues: [CGFloat] = []
    @State private var greenValues: [CGFloat] = []
    @State private var blueValues: [CGFloat] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 빨간 채널
                HistogramChannel(values: redValues, color: .red)
                // 초록 채널
                HistogramChannel(values: greenValues, color: .green)
                // 파란 채널
                HistogramChannel(values: blueValues, color: .blue)
            }
        }
        .frame(height: 60)
        .background(Color.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .task(id: image) {
            await calculateHistogram()
        }
    }
    
    private func calculateHistogram() async {
        guard let image = image,
              let cgImage = image.cgImage else {
            return
        }
        
        // 간단한 히스토그램 계산 (실제 앱에서는 vImage 사용 권장)
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        
        var redBins = [Int](repeating: 0, count: 256)
        var greenBins = [Int](repeating: 0, count: 256)
        var blueBins = [Int](repeating: 0, count: 256)
        
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return }
        
        let buffer = data.bindMemory(to: UInt8.self, capacity: width * height * bytesPerPixel)
        
        // 샘플링 (전체 픽셀 대신 일부만)
        let sampleStep = max(1, (width * height) / 10000)
        
        for i in stride(from: 0, to: width * height, by: sampleStep) {
            let offset = i * bytesPerPixel
            redBins[Int(buffer[offset])] += 1
            greenBins[Int(buffer[offset + 1])] += 1
            blueBins[Int(buffer[offset + 2])] += 1
        }
        
        // 정규화
        let maxValue = max(redBins.max() ?? 1, greenBins.max() ?? 1, blueBins.max() ?? 1)
        
        await MainActor.run {
            redValues = redBins.map { CGFloat($0) / CGFloat(maxValue) }
            greenValues = greenBins.map { CGFloat($0) / CGFloat(maxValue) }
            blueValues = blueBins.map { CGFloat($0) / CGFloat(maxValue) }
        }
    }
}

// MARK: - 히스토그램 채널
struct HistogramChannel: View {
    let values: [CGFloat]
    let color: Color
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                guard !values.isEmpty else { return }
                
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(values.count - 1)
                
                path.move(to: CGPoint(x: 0, y: height))
                
                for (index, value) in values.enumerated() {
                    let x = CGFloat(index) * stepX
                    let y = height - (value * height)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                path.addLine(to: CGPoint(x: width, y: height))
                path.closeSubpath()
            }
            .fill(color.opacity(0.3))
        }
    }
}

// MARK: - 프리뷰
#Preview {
    ImagePreviewView(appState: AppState())
}
