import SwiftUI
import Combine // ⚠️ Combine 프레임워크 필수 import

/// ObservableObject는 Combine에 의존합니다.
/// 내부적으로 ObjectWillChangePublisher를 사용합니다.
class CombineDependentStore: ObservableObject {
    // ObservableObject 프로토콜이 정의하는 publisher
    // let objectWillChange = PassthroughSubject<Void, Never>()
    
    @Published var items: [String] = []
    
    // 수동으로 변경 알림을 보내려면 Combine 지식 필요
    func manualUpdate() {
        objectWillChange.send() // Combine의 Publisher 개념
        items.append("새 아이템")
    }
}

/// Combine을 더 활용하려면 이런 복잡한 코드가 필요합니다
class AdvancedStore: ObservableObject {
    @Published var searchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // debounce, filter 등 Combine 연산자 사용
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { text in
                print("검색: \(text)")
            }
            .store(in: &cancellables)
    }
}

// 💡 단순히 상태 변화만 추적하고 싶은데, 
// Combine의 Publisher, Subscriber, Cancellable 개념까지 알아야 하나요?
