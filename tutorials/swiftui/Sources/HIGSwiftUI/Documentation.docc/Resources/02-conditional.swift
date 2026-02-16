import SwiftUI

// @ViewBuilder 덕분에 조건부 뷰 렌더링이 가능합니다!

struct ConditionalViewExample: View {
    @State private var isFavorite = false
    @State private var showDetails = true
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("김치찌개")
                    .font(.title)
                
                // if문으로 조건부 표시
                if isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.red)
                }
            }
            
            Button("즐겨찾기 토글") {
                isFavorite.toggle()
            }
            
            Divider()
            
            // if-else도 사용 가능
            if showDetails {
                Text("구수하고 얼큰한 한국의 대표 찌개입니다.")
                    .foregroundStyle(.secondary)
            } else {
                Text("상세 정보를 보려면 탭하세요")
                    .foregroundStyle(.blue)
            }
            
            Button("상세 정보 토글") {
                showDetails.toggle()
            }
        }
        .padding()
    }
}

#Preview {
    ConditionalViewExample()
}
