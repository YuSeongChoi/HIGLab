import SwiftUI
import Observation

// MARK: - 참조 변경 vs 값 변경
// 중요한 개념: User 수준에서는 address 참조 변경만 감지!

@Observable
class Address {
    var city: String
    
    init(city: String) {
        self.city = city
    }
}

@Observable
class User {
    var name: String
    var address: Address
    
    init(name: String, address: Address) {
        self.name = name
        self.address = address
    }
}

// MARK: - 관찰 동작 데모

struct ObservationDemo: View {
    @State private var user = User(
        name: "홍길동",
        address: Address(city: "서울")
    )
    
    var body: some View {
        VStack(spacing: 20) {
            // 이 뷰는 user.name만 읽음
            Text("사용자: \(user.name)")
            
            Button("이름 변경") {
                // ✅ User 수준에서 감지됨 → 뷰 업데이트
                user.name = "김철수"
            }
            
            Button("주소 객체 교체") {
                // ✅ User 수준에서 감지됨 → 뷰 업데이트
                // address 참조 자체가 변경됨
                user.address = Address(city: "부산")
            }
            
            Button("도시만 변경") {
                // ⚠️ User 수준에서는 감지 안 됨!
                // address 참조는 그대로, 내부 값만 변경
                // 하지만 address.city를 직접 읽는 뷰에서는 감지됨
                user.address.city = "대전"
            }
        }
    }
}
