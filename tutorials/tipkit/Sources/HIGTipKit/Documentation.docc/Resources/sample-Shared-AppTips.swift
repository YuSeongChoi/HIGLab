import TipKit

// MARK: - 인라인 팁
/// 화면에 직접 삽입되는 인라인 스타일 팁
struct FavoriteTip: Tip {
    // 팁 제목
    var title: Text {
        Text("즐겨찾기 추가")
    }
    
    // 팁 설명 메시지
    var message: Text? {
        Text("하트 버튼을 눌러 즐겨찾기에 추가하세요.")
    }
    
    // SF Symbol 아이콘
    var image: Image? {
        Image(systemName: "heart.fill")
    }
}

// MARK: - 팝오버 팁
/// 특정 UI 요소 위에 말풍선으로 표시되는 팝오버 스타일 팁
struct ShareTip: Tip {
    var title: Text {
        Text("공유하기")
    }
    
    var message: Text? {
        Text("이 버튼으로 친구에게 공유할 수 있어요.")
    }
    
    var image: Image? {
        Image(systemName: "square.and.arrow.up")
    }
}

// MARK: - 이벤트 기반 팁
/// 특정 이벤트가 발생한 후에만 표시되는 팁
struct ProTip: Tip {
    // 이벤트 조건: 앱을 3번 이상 사용해야 표시
    static let appOpenedEvent = Tips.Event(id: "appOpened")
    
    var title: Text {
        Text("프로 기능 발견!")
    }
    
    var message: Text? {
        Text("앱을 여러 번 사용하셨네요. 고급 기능을 확인해보세요.")
    }
    
    var image: Image? {
        Image(systemName: "star.fill")
    }
    
    // 표시 규칙: appOpened 이벤트가 3회 이상 발생해야 함
    var rules: [Rule] {
        #Rule(Self.appOpenedEvent) { event in
            event.donations.count >= 3
        }
    }
}

// MARK: - 액션이 있는 팁
/// 사용자가 선택할 수 있는 액션 버튼이 포함된 팁
struct ActionTip: Tip {
    var title: Text {
        Text("새로운 기능")
    }
    
    var message: Text? {
        Text("이 기능에 대해 더 알아보시겠어요?")
    }
    
    var image: Image? {
        Image(systemName: "lightbulb.fill")
    }
    
    // 팁에 표시될 액션 버튼들
    var actions: [Action] {
        Action(id: "learn-more", title: "자세히 보기")
        Action(id: "dismiss", title: "닫기")
    }
}
