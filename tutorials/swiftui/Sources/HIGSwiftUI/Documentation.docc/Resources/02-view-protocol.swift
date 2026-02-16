import SwiftUI

// View 프로토콜의 정의 (간략화)
// 실제로는 SwiftUI 프레임워크에 정의되어 있습니다.

/*
public protocol View {
    associatedtype Body: View
    
    @ViewBuilder
    var body: Self.Body { get }
}
*/

// 핵심 포인트:
// 1. View는 프로토콜입니다 (struct나 class가 채택)
// 2. body라는 연산 프로퍼티 하나만 요구합니다
// 3. body는 또 다른 View를 반환합니다 (재귀적 정의)
// 4. @ViewBuilder가 여러 뷰를 조합하게 해줍니다

struct MyFirstView: View {
    // body 프로퍼티만 구현하면 View 완성!
    var body: some View {
        Text("안녕하세요!")
    }
}

#Preview {
    MyFirstView()
}
