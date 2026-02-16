import SwiftUI

struct BarcodeScanView: View {
    @State private var selectedImage: UIImage?
    @State private var scannedBarcodes: [ScannedBarcode] = []
    @State private var isProcessing = false
    @State private var showingImagePicker = false
    
    private let scanner = BarcodeScanner()
    
    var body: some View {
        VStack {
            if let image = selectedImage {
                ZStack {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                    
                    BarcodeOverlayView(
                        barcodes: scannedBarcodes,
                        imageSize: image.size
                    )
                }
            } else {
                ContentUnavailableView(
                    "이미지 선택",
                    systemImage: "barcode.viewfinder",
                    description: Text("바코드가 있는 이미지를 선택하세요")
                )
            }
            
            // 스캔된 바코드 목록
            if !scannedBarcodes.isEmpty {
                List(scannedBarcodes) { barcode in
                    VStack(alignment: .leading) {
                        Text(barcode.value)
                            .font(.headline)
                        Text(barcode.symbologyName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxHeight: 200)
            }
            
            HStack {
                Button("사진 선택") {
                    showingImagePicker = true
                }
                .buttonStyle(.bordered)
                
                Button("바코드 스캔") {
                    Task { await scanBarcodes() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedImage == nil || isProcessing)
            }
            .padding()
        }
        .navigationTitle("바코드 스캔")
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $selectedImage)
        }
    }
    
    private func scanBarcodes() async {
        guard let image = selectedImage else { return }
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            let observations = try await scanner.detectBarcodes(in: image)
            scannedBarcodes = scanner.processObservations(observations)
        } catch {
            print("Error: \(error)")
        }
    }
}
