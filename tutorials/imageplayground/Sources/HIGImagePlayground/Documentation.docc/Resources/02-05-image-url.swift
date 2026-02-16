import SwiftUI
import ImagePlayground

struct ImageURLHandlingView: View {
    @State private var isPresented = false
    @State private var savedImageURL: URL?
    
    var body: some View {
        Button("이미지 생성") {
            isPresented = true
        }
        .imagePlaygroundSheet(isPresented: $isPresented) { tempURL in
            // ⚠️ tempURL은 임시 위치를 가리킴
            // 앱에서 계속 사용하려면 영구 저장소로 복사 필요
            
            Task {
                do {
                    let documentsURL = FileManager.default.urls(
                        for: .documentDirectory, 
                        in: .userDomainMask
                    ).first!
                    
                    let filename = "generated_\(Date().timeIntervalSince1970).png"
                    let permanentURL = documentsURL.appendingPathComponent(filename)
                    
                    // 영구 저장소로 복사
                    try FileManager.default.copyItem(at: tempURL, to: permanentURL)
                    
                    savedImageURL = permanentURL
                    print("이미지 저장됨: \(permanentURL)")
                } catch {
                    print("저장 실패: \(error)")
                }
            }
        }
    }
}
