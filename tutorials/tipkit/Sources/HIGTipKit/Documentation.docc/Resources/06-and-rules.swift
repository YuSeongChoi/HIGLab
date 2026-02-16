import SwiftUI
import TipKit

struct ProTip: Tip {
    static let photoEdited = Event(id: "photoEdited")
    static let filterApplied = Event(id: "filterApplied")
    static let photoExported = Event(id: "photoExported")
    
    var title: Text { Text("프로 편집 팁") }
    var message: Text? { Text("레이어와 마스크를 사용해보세요") }
    
    // AND 조건: 모든 규칙이 충족되어야 팁 표시
    var rules: [Rule] {
        // 사진을 3번 이상 편집하고
        #Rule(Self.photoEdited.donations.count >= 3) { $0 }
        
        // 필터를 2번 이상 적용하고
        #Rule(Self.filterApplied.donations.count >= 2) { $0 }
        
        // 내보내기를 1번 이상 해야
        #Rule(Self.photoExported.donations.count >= 1) { $0 }
        
        // 프로 팁이 표시됨
    }
}

// 💡 rules 배열의 모든 규칙은 AND로 적용됨
// 하나라도 false면 팁이 표시되지 않음
