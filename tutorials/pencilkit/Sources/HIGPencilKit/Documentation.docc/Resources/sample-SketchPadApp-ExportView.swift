import SwiftUI
import PencilKit

// MARK: - ExportView
// 드로잉을 이미지 또는 PDF로 내보내는 뷰

struct ExportView: View {
    // MARK: - 환경
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 속성
    
    /// 내보낼 드로잉
    let drawing: PKDrawing
    
    /// 드로잉 이름
    let name: String
    
    // MARK: - 상태
    
    /// 내보내기 형식
    @State private var exportFormat: ExportFormat = .png
    
    /// 배경색 포함 여부
    @State private var includeBackground = true
    
    /// 배경색
    @State private var backgroundColor: Color = .white
    
    /// 이미지 크기 배율
    @State private var scale: CGFloat = 2.0
    
    /// 공유 시트 표시
    @State private var showingShareSheet = false
    
    /// 내보낸 아이템
    @State private var exportedItem: Any?
    
    /// 내보내기 상태
    @State private var isExporting = false
    
    /// 오류 메시지
    @State private var errorMessage: String?
    
    // MARK: - 내보내기 형식
    
    enum ExportFormat: String, CaseIterable, Identifiable {
        case png = "PNG"
        case jpeg = "JPEG"
        case pdf = "PDF"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .png: return "photo"
            case .jpeg: return "photo.fill"
            case .pdf: return "doc"
            }
        }
        
        var description: String {
            switch self {
            case .png: return "투명 배경 지원, 무손실"
            case .jpeg: return "작은 파일 크기"
            case .pdf: return "벡터, 인쇄용"
            }
        }
        
        var fileExtension: String {
            rawValue.lowercased()
        }
    }
    
    // MARK: - 본문
    
    var body: some View {
        NavigationStack {
            List {
                // 미리보기 섹션
                previewSection
                
                // 형식 선택 섹션
                formatSection
                
                // 옵션 섹션
                optionsSection
                
                // 내보내기 버튼
                exportButton
            }
            .navigationTitle("내보내기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                if let item = exportedItem {
                    ShareSheet(items: [item])
                }
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
        }
    }
    
    // MARK: - 미리보기 섹션
    
    private var previewSection: some View {
        Section {
            HStack {
                Spacer()
                
                ZStack {
                    // 배경
                    if includeBackground {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    } else {
                        // 투명 배경 체커보드
                        checkerboardBackground
                    }
                    
                    // 드로잉 이미지
                    if !drawing.bounds.isEmpty {
                        Image(uiImage: previewImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        Text("빈 드로잉")
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                }
                
                Spacer()
            }
            .listRowBackground(Color.clear)
        } header: {
            Text("미리보기")
        }
    }
    
    /// 투명 배경 체커보드
    private var checkerboardBackground: some View {
        Canvas { context, size in
            let squareSize: CGFloat = 10
            let rows = Int(size.height / squareSize) + 1
            let cols = Int(size.width / squareSize) + 1
            
            for row in 0..<rows {
                for col in 0..<cols {
                    let isEven = (row + col) % 2 == 0
                    let color: Color = isEven ? .white : Color(.systemGray5)
                    
                    context.fill(
                        Path(CGRect(
                            x: CGFloat(col) * squareSize,
                            y: CGFloat(row) * squareSize,
                            width: squareSize,
                            height: squareSize
                        )),
                        with: .color(color)
                    )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    /// 미리보기 이미지
    private var previewImage: UIImage {
        let bounds = drawing.bounds
        guard !bounds.isEmpty else {
            return UIImage()
        }
        
        return drawing.image(from: bounds, scale: 1.0)
    }
    
    // MARK: - 형식 선택 섹션
    
    private var formatSection: some View {
        Section {
            ForEach(ExportFormat.allCases) { format in
                Button {
                    exportFormat = format
                } label: {
                    HStack {
                        Image(systemName: format.icon)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading) {
                            Text(format.rawValue)
                                .foregroundStyle(.primary)
                            Text(format.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if exportFormat == format {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        } header: {
            Text("형식")
        }
    }
    
    // MARK: - 옵션 섹션
    
    private var optionsSection: some View {
        Section {
            // 배경색 (PNG/PDF만)
            if exportFormat != .jpeg {
                Toggle("배경색 포함", isOn: $includeBackground)
            }
            
            if includeBackground || exportFormat == .jpeg {
                HStack {
                    Text("배경색")
                    Spacer()
                    ColorPicker("", selection: $backgroundColor)
                        .labelsHidden()
                }
            }
            
            // 크기 배율 (이미지만)
            if exportFormat != .pdf {
                VStack(alignment: .leading) {
                    HStack {
                        Text("크기 배율")
                        Spacer()
                        Text("\(scale, specifier: "%.1f")x")
                            .foregroundStyle(.secondary)
                    }
                    
                    Slider(value: $scale, in: 1...4, step: 0.5)
                }
                
                // 예상 크기
                if !drawing.bounds.isEmpty {
                    let size = drawing.bounds.size
                    let exportSize = CGSize(
                        width: size.width * scale,
                        height: size.height * scale
                    )
                    Text("예상 크기: \(Int(exportSize.width)) × \(Int(exportSize.height)) px")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("옵션")
        }
    }
    
    // MARK: - 내보내기 버튼
    
    private var exportButton: some View {
        Section {
            Button {
                exportDrawing()
            } label: {
                HStack {
                    Spacer()
                    
                    if isExporting {
                        ProgressView()
                            .padding(.trailing, 8)
                    }
                    
                    Text("내보내기")
                        .fontWeight(.semibold)
                    
                    Spacer()
                }
            }
            .disabled(drawing.bounds.isEmpty || isExporting)
        }
    }
    
    // MARK: - 내보내기 로직
    
    private func exportDrawing() {
        isExporting = true
        
        Task {
            do {
                let item = try await performExport()
                
                await MainActor.run {
                    exportedItem = item
                    isExporting = false
                    showingShareSheet = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = "내보내기 실패: \(error.localizedDescription)"
                    isExporting = false
                }
            }
        }
    }
    
    /// 내보내기 수행
    private func performExport() async throws -> Any {
        let bounds = drawing.bounds
        
        switch exportFormat {
        case .png:
            return try exportAsPNG(bounds: bounds)
        case .jpeg:
            return try exportAsJPEG(bounds: bounds)
        case .pdf:
            return try exportAsPDF(bounds: bounds)
        }
    }
    
    /// PNG 내보내기
    private func exportAsPNG(bounds: CGRect) throws -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(
                width: bounds.width * scale,
                height: bounds.height * scale
            )
        )
        
        return renderer.image { context in
            // 배경
            if includeBackground {
                UIColor(backgroundColor).setFill()
                context.fill(CGRect(
                    origin: .zero,
                    size: CGSize(
                        width: bounds.width * scale,
                        height: bounds.height * scale
                    )
                ))
            }
            
            // 드로잉
            let image = drawing.image(from: bounds, scale: scale)
            image.draw(at: .zero)
        }
    }
    
    /// JPEG 내보내기
    private func exportAsJPEG(bounds: CGRect) throws -> UIImage {
        let renderer = UIGraphicsImageRenderer(
            size: CGSize(
                width: bounds.width * scale,
                height: bounds.height * scale
            )
        )
        
        return renderer.image { context in
            // 배경 (JPEG는 항상 배경 필요)
            UIColor(backgroundColor).setFill()
            context.fill(CGRect(
                origin: .zero,
                size: CGSize(
                    width: bounds.width * scale,
                    height: bounds.height * scale
                )
            ))
            
            // 드로잉
            let image = drawing.image(from: bounds, scale: scale)
            image.draw(at: .zero)
        }
    }
    
    /// PDF 내보내기
    private func exportAsPDF(bounds: CGRect) throws -> URL {
        let pdfRenderer = UIGraphicsPDFRenderer(
            bounds: CGRect(origin: .zero, size: bounds.size)
        )
        
        let data = pdfRenderer.pdfData { context in
            context.beginPage()
            
            // 배경
            if includeBackground {
                UIColor(backgroundColor).setFill()
                context.cgContext.fill(CGRect(origin: .zero, size: bounds.size))
            }
            
            // 드로잉
            let image = drawing.image(from: bounds, scale: 1.0)
            image.draw(at: .zero)
        }
        
        // 임시 파일로 저장
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(name).pdf")
        
        try data.write(to: tempURL)
        return tempURL
    }
}

// MARK: - ShareSheet
// UIKit의 UIActivityViewController를 SwiftUI에서 사용

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}

// MARK: - 미리보기

#Preview {
    ExportView(
        drawing: PKDrawing(),
        name: "테스트 드로잉"
    )
}
