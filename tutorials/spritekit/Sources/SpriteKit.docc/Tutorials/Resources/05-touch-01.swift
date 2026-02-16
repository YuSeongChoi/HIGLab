import SpriteKit

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        backgroundColor = .darkGray
    }
    
    // 손가락이 화면에 닿을 때
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touches는 동시에 발생한 모든 터치의 집합
        guard let touch = touches.first else { return }
        
        // 터치 정보
        print("터치 시작!")
        print("터치 수: \(touches.count)")
    }
    
    // 손가락이 이동할 때
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        print("터치 이동 중...")
    }
    
    // 손가락이 떨어질 때
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("터치 종료")
    }
    
    // 터치가 취소될 때 (전화 수신 등)
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("터치 취소됨")
    }
}
