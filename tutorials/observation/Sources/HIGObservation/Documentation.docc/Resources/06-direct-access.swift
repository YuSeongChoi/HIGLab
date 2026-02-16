import SwiftUI
import Observation

// MARK: - 직접 접근을 통한 내부 객체 추적
// 내부 프로퍼티를 읽으면 해당 프로퍼티가 추적됨

@Observable
class Address {
    var street: String
    var city: String
    
    init(street: String, city: String) {
        self.street = street
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

// MARK: - 직접 접근 예시

struct UserDetailView: View {
    var user: User
    
    var body: some View {
        let _ = Self._printChanges()  // 디버그용
        
        VStack(alignment: .leading, spacing: 16) {
            // user.name을 읽음 → name 추적
            Text("이름: \(user.name)")
                .font(.headline)
            
            // user.address.street을 읽음 → street 추적
            Text("주소: \(user.address.street)")
            
            // user.address.city를 읽음 → city 추적
            Text("도시: \(user.address.city)")
            
            // 결과:
            // - user.name 변경 시 → 뷰 업데이트 ✅
            // - user.address.street 변경 시 → 뷰 업데이트 ✅
            // - user.address.city 변경 시 → 뷰 업데이트 ✅
            // - user.address 객체 교체 시 → 뷰 업데이트 ✅
        }
        .padding()
    }
}

// MARK: - 부분 접근 예시

struct CityOnlyView: View {
    var user: User
    
    var body: some View {
        let _ = Self._printChanges()
        
        // 오직 city만 읽음
        Text("도시: \(user.address.city)")
        
        // 결과:
        // - user.address.city 변경 시 → 뷰 업데이트 ✅
        // - user.address.street 변경 시 → 뷰 업데이트 ❌ (안 읽었으니까)
        // - user.name 변경 시 → 뷰 업데이트 ❌ (안 읽었으니까)
    }
}
