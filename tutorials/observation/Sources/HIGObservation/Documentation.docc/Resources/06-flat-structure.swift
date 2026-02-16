import SwiftUI
import Observation

// MARK: - 패턴 1: 평면 구조 유지하기
// 중첩을 피하고 가능하면 평면적으로 설계

// ❌ 중첩 구조 (피해야 할 경우)
@Observable
class NestedUser {
    var name: String = ""
    var address: NestedAddress = NestedAddress()
}

@Observable
class NestedAddress {
    var city: String = ""
}

// ✅ 평면 구조 (더 간단한 경우)
@Observable
class FlatUser {
    var name: String = ""
    
    // 주소 정보를 직접 포함
    var addressStreet: String = ""
    var addressCity: String = ""
    var addressZipCode: String = ""
    
    // 계산 프로퍼티로 묶어서 제공 가능
    var fullAddress: String {
        "\(addressStreet), \(addressCity) \(addressZipCode)"
    }
}

// MARK: - 언제 평면 구조를 선택할까?

/*
 ✅ 평면 구조가 좋은 경우:
 - 주소 정보가 항상 함께 사용됨
 - 주소만 독립적으로 편집하는 UI가 없음
 - 코드가 단순해짐
 
 ❌ 평면 구조가 나쁜 경우:
 - 주소를 여러 User가 공유해야 함
 - 주소 편집 화면이 별도로 있음
 - 주소 검증 로직이 복잡함
 */

// MARK: - 사용 예시

struct FlatUserForm: View {
    @Bindable var user: FlatUser
    
    var body: some View {
        Form {
            Section("기본 정보") {
                TextField("이름", text: $user.name)
            }
            
            Section("주소") {
                TextField("도로명", text: $user.addressStreet)
                TextField("도시", text: $user.addressCity)
                TextField("우편번호", text: $user.addressZipCode)
            }
            
            Section("전체 주소") {
                Text(user.fullAddress)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
