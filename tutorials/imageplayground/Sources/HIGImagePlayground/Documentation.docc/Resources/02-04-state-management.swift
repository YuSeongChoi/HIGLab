import SwiftUI
import ImagePlayground

struct StateManagementView: View {
    // 분리된 상태 관리
    @State private var isPresented = false
    @State private var lastGeneratedURL: URL?
    @State private var generationCount = 0
    
    var body: some View {
        VStack {
            Text("생성 횟수: \(generationCount)")
            
            if let url = lastGeneratedURL {
                Text("마지막 URL: \(url.lastPathComponent)")
                    .font(.caption)
            }
            
            Button("새 이미지 생성") {
                isPresented = true
            }
        }
        .imagePlaygroundSheet(isPresented: $isPresented) { url in
            // 시트가 닫히고 나서도 결과에 접근 가능
            lastGeneratedURL = url
            generationCount += 1
        }
    }
}
