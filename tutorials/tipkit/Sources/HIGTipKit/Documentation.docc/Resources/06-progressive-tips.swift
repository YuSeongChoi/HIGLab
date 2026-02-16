import SwiftUI
import TipKit

// MARK: - 점진적 팁 공개 패턴
// 기본 기능 사용 후 고급 기능 팁을 표시합니다.

// 초보자용: 항상 표시 가능
struct BeginnerTip: Tip {
    var title: Text { Text("항목 추가하기") }
    var message: Text? { Text("+ 버튼을 탭하세요") }
}

// 중급자용: 항목 5개 추가 후 표시
struct IntermediateTip: Tip {
    static let itemAdded = Event(id: "itemAdded")
    
    var title: Text { Text("드래그로 정렬") }
    var message: Text? { Text("항목을 길게 눌러 순서를 바꿀 수 있어요") }
    
    var rules: [Rule] {
        #Rule(Self.itemAdded.donations.count >= 5) { $0 }
    }
}

// 고급자용: 정렬 기능 3번 사용 후 표시
struct AdvancedTip: Tip {
    static let itemReordered = Event(id: "itemReordered")
    
    var title: Text { Text("폴더로 정리") }
    var message: Text? { Text("관련 항목들을 폴더로 묶어보세요") }
    
    var rules: [Rule] {
        #Rule(Self.itemReordered.donations.count >= 3) { $0 }
    }
}

// 이렇게 하면 사용자 숙련도에 맞는 팁이 표시됨!
