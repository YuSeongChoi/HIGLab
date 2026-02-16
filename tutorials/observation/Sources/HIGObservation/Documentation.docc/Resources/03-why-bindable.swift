import SwiftUI
import Observation

/// @Bindable이 필요한 이유를 이해하기
///
/// @Observable은 프로퍼티별 추적을 위해 내부 구조가 다릅니다.
/// @Bindable이 이 차이를 메꿔주는 어댑터 역할을 합니다.

@Observable
class FormData {
    var email: String = ""
    var password: String = ""
}

// 💡 @Bindable이 하는 일:
//
// 1. @Observable 객체를 받아서
// 2. dynamicMemberLookup을 통해 프로퍼티 접근 시
// 3. 해당 프로퍼티에 대한 Binding<T>를 생성

// 내부적으로는 이런 식으로 동작합니다 (개념적 설명):
//
// @dynamicMemberLookup
// struct Bindable<T: Observable> {
//     var wrappedValue: T
//
//     subscript<Value>(dynamicMember keyPath: ReferenceWritableKeyPath<T, Value>) -> Binding<Value> {
//         Binding(
//             get: { wrappedValue[keyPath: keyPath] },
//             set: { wrappedValue[keyPath: keyPath] = $0 }
//         )
//     }
// }

struct WhyBindableDemo: View {
    @Bindable var form: FormData
    
    var body: some View {
        VStack {
            // $form.email은 Bindable이 생성한 Binding<String>
            TextField("이메일", text: $form.email)
            
            // 직접 Binding을 만드는 것과 동일
            TextField("비밀번호", text: Binding(
                get: { form.password },
                set: { form.password = $0 }
            ))
        }
    }
}
