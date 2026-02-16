import SwiftUI
import Observation

// MARK: - 패턴 2: 뷰 분리로 중첩 Observable 활용
// 각 Observable 수준에 맞는 전용 뷰 생성

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
    var address: Address
    
    init(name: String, email: String, address: Address) {
        self.name = name
        self.email = email
        self.address = address
    }
}

// MARK: - 분리된 뷰 구조

// Address 전용 뷰 - Address 수준 변화만 추적
struct AddressView: View {
    @Bindable var address: Address
    
    var body: some View {
        let _ = Self._printChanges()  // 디버그
        
        VStack(alignment: .leading, spacing: 8) {
            TextField("도로명", text: $address.street)
            TextField("도시", text: $address.city)
            TextField("우편번호", text: $address.zipCode)
        }
    }
}

// User 기본 정보 뷰 - User 수준 변화만 추적
struct UserBasicInfoView: View {
    @Bindable var user: User
    
    var body: some View {
        let _ = Self._printChanges()  // 디버그
        
        VStack(alignment: .leading, spacing: 8) {
            TextField("이름", text: $user.name)
            TextField("이메일", text: $user.email)
        }
    }
}

// MARK: - 통합 뷰

struct UserProfileForm: View {
    var user: User
    
    var body: some View {
        Form {
            Section("기본 정보") {
                // User의 name, email 변경 시에만 업데이트
                UserBasicInfoView(user: user)
            }
            
            Section("배송 주소") {
                // Address의 프로퍼티 변경 시에만 업데이트
                AddressView(address: user.address)
            }
        }
        .navigationTitle("프로필 편집")
    }
}

// 결과:
// - user.name 변경 → UserBasicInfoView만 업데이트
// - user.address.city 변경 → AddressView만 업데이트
// - 최적의 성능! ✅
