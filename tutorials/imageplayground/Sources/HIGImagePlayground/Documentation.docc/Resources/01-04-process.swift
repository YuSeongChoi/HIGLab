#if canImport(ImagePlayground)
import SwiftUI
import ImagePlayground

// ImagePlayground 생성 프로세스:
// 1. 앱이 시트를 표시하고 초기 개념 제안
// 2. 사용자가 프롬프트를 수정하거나 추가
// 3. Apple Intelligence가 이미지 옵션 생성
// 4. 사용자가 마음에 드는 이미지 선택
// 5. 선택된 이미지가 앱으로 반환

struct GenerationProcessView: View {
    @State private var showSheet = false
    @State private var resultURL: URL?
    
    // 앱의 맥락에 맞는 초기 개념
    let suggestedConcepts: [ImagePlaygroundConcept] = [
        .text("산 정상에서 일출을 바라보는 등산객"),
        .text("평화로운 분위기")
    ]
    
    var body: some View {
        VStack {
            Button("멋진 풍경 만들기") {
                showSheet = true
            }
        }
        .imagePlaygroundSheet(
            isPresented: $showSheet,
            concepts: suggestedConcepts,  // 초기 개념 제안
            style: .illustration           // 권장 스타일
        ) { url in
            // 사용자가 최종 선택한 이미지
            resultURL = url
            print("사용자가 선택한 이미지: \(url)")
        }
    }
}
#endif
