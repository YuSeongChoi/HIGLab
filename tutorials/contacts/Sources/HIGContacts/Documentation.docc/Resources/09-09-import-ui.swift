import SwiftUI
import UniformTypeIdentifiers

struct ImportVCardView: View {
    @State private var showFilePicker = false
    @State private var importedCount = 0
    @State private var showResult = false
    
    let vCardManager = VCardManager()
    
    var body: some View {
        Button("vCard 가져오기") {
            showFilePicker = true
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [UTType.vCard],
            allowsMultipleSelection: true
        ) { result in
            handleImport(result)
        }
        .alert("가져오기 완료", isPresented: $showResult) {
            Button("확인") {}
        } message: {
            Text("\(importedCount)개의 연락처를 가져왔습니다.")
        }
    }
    
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            var total = 0
            for url in urls {
                if let count = try? vCardManager.importContactsFromFile(at: url) {
                    total += count
                }
            }
            importedCount = total
            showResult = true
            
        case .failure(let error):
            print("파일 선택 실패: \(error)")
        }
    }
}
