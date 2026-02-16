import SwiftUI

// @ViewBuilder의 마법
// 여러 뷰를 나열할 수 있게 해줍니다!

struct ViewBuilderExample: View {
    var body: some View {
        // @ViewBuilder 덕분에 여러 뷰를 그냥 나열할 수 있습니다
        VStack {
            Text("첫 번째")
            Text("두 번째") 
            Text("세 번째")
            // 내부적으로 TupleView로 묶입니다
        }
    }
}

// @ViewBuilder 없이 직접 구현하려면?
struct WithoutViewBuilder: View {
    var body: some View {
        // 이렇게 return 해야 합니다
        return VStack {
            return Text("한 줄")
        }
        // 매우 불편하죠!
    }
}

// @ViewBuilder는 result builder 기능을 사용합니다
// Swift 5.4에서 도입된 기능입니다

#Preview {
    ViewBuilderExample()
}
