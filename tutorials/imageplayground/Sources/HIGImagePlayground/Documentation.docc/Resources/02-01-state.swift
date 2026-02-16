import SwiftUI
import ImagePlayground

struct SheetStateView: View {
    // 시트 표시 상태 관리
    @State private var isShowingPlayground = false
    
    // 생성된 이미지 URL 저장
    @State private var generatedImageURL: URL?
    
    var body: some View {
        VStack {
            Text("상태 관리 예시")
        }
    }
}
