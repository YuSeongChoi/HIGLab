import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - 필터 앱 메인 뷰
struct FilterAppView: View {
    @State private var inputImage: UIImage?
    @State private var filteredImage: UIImage?
    @State private var filterIntensity: Double = 0.5
    
    private let context = CIContext()
    
    var body: some View {
        VStack {
            if let image = filteredImage ?? inputImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            Slider(value: $filterIntensity, in: 0...1)
                .onChange(of: filterIntensity) { _ in
                    applyFilter()
                }
            
            HStack {
                FilterButton(title: "세피아") { applySepia() }
                FilterButton(title: "흑백") { applyNoir() }
                FilterButton(title: "비네트") { applyVignette() }
            }
        }
        .padding()
    }
    
    private func applyFilter() {
        // 필터 적용 로직
    }
    
    private func applySepia() {
        guard let inputImage,
              let ciImage = CIImage(image: inputImage) else { return }
        
        let filter = CIFilter.sepiaTone()
        filter.inputImage = ciImage
        filter.intensity = Float(filterIntensity)
        
        if let output = filter.outputImage,
           let cgImage = context.createCGImage(output, from: output.extent) {
            filteredImage = UIImage(cgImage: cgImage)
        }
    }
    
    private func applyNoir() { }
    private func applyVignette() { }
}

struct FilterButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(title, action: action)
            .buttonStyle(.bordered)
    }
}
