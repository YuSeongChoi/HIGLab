import SwiftUI
import Observation

// MARK: - 중첩 Observable 기본 구조
// User 안에 Address가 포함된 중첩 구조

@Observable
class Address {
    var street: String
    var city: String
    var zipCode: String
    
    init(street: String = "", city: String = "", zipCode: String = "") {
        self.street = street
        self.city = city
        self.zipCode = zipCode
    }
}

@Observable
class User {
    var name: String
    var email: String
    var address: Address  // 중첩된 Observable 객체
    
    init(name: String, email: String, address: Address) {
        self.name = name
        self.email = email
        self.address = address
    }
}

// MARK: - 사용 예시

struct UserProfileView: View {
    var user: User
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // user.name 변경 시 업데이트됨
            Text("이름: \(user.name)")
            
            // user.email 변경 시 업데이트됨
            Text("이메일: \(user.email)")
            
            // user.address.city 변경 시 업데이트됨!
            // 직접 접근하면 내부 프로퍼티도 추적됨
            Text("도시: \(user.address.city)")
        }
        .padding()
    }
}
