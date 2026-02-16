import SwiftUI
import TipKit

// MARK: - 점진적 공개 (Progressive Disclosure)
// 사용자의 숙련도에 따라 단계별로 팁을 공개합니다.

// 초보자용 팁 - 앱 첫 사용 시
struct BeginnerTip: Tip {
    var title: Text {
        Text("기본 사용법")
    }
    
    var message: Text? {
        Text("+ 버튼을 탭해서 새 항목을 추가하세요")
    }
    
    var image: Image? {
        Image(systemName: "plus.circle.fill")
    }
}

// 중급자용 팁 - 기본 기능을 5번 이상 사용 후
struct IntermediateTip: Tip {
    static let itemAddedEvent = Event(id: "itemAdded")
    
    var title: Text {
        Text("빠른 추가")
    }
    
    var message: Text? {
        Text("키보드의 Return 키로 빠르게 연속 추가할 수 있어요")
    }
    
    var rules: [Rule] {
        #Rule(Self.itemAddedEvent.donations.count >= 5) {
            $0
        }
    }
}

// 고급자용 팁 - 중급 기능을 사용한 후
struct AdvancedTip: Tip {
    static let quickAddUsed = Event(id: "quickAddUsed")
    
    var title: Text {
        Text("템플릿 만들기")
    }
    
    var message: Text? {
        Text("자주 쓰는 항목을 템플릿으로 저장하면 더 빠르게 추가할 수 있어요")
    }
    
    var rules: [Rule] {
        #Rule(Self.quickAddUsed.donations.count >= 3) {
            $0
        }
    }
}
