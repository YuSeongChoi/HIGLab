// PhysicsCategory.swift
// SpaceShooter - SpriteKit 2D 게임
// 물리 충돌 카테고리 정의

import Foundation

/// 물리 충돌 감지를 위한 비트마스크 카테고리
/// SpriteKit의 SKPhysicsBody에서 사용되는 충돌 카테고리를 정의합니다.
struct PhysicsCategory {
    /// 충돌 없음
    static let none: UInt32 = 0
    
    /// 플레이어 우주선
    static let player: UInt32 = 0x1 << 0      // 1
    
    /// 플레이어가 발사한 총알
    static let playerBullet: UInt32 = 0x1 << 1 // 2
    
    /// 적 우주선
    static let enemy: UInt32 = 0x1 << 2        // 4
    
    /// 적이 발사한 총알
    static let enemyBullet: UInt32 = 0x1 << 3  // 8
    
    /// 화면 경계
    static let boundary: UInt32 = 0x1 << 4     // 16
    
    /// 파워업 아이템
    static let powerUp: UInt32 = 0x1 << 5      // 32
    
    /// 모든 카테고리 (디버깅용)
    static let all: UInt32 = UInt32.max
}

/// 충돌 그룹 설정을 위한 헬퍼
extension PhysicsCategory {
    /// 플레이어 총알이 충돌해야 하는 대상
    static var playerBulletContacts: UInt32 {
        return enemy
    }
    
    /// 적 총알이 충돌해야 하는 대상
    static var enemyBulletContacts: UInt32 {
        return player
    }
    
    /// 플레이어가 충돌해야 하는 대상
    static var playerContacts: UInt32 {
        return enemy | enemyBullet | powerUp
    }
    
    /// 적이 충돌해야 하는 대상
    static var enemyContacts: UInt32 {
        return playerBullet | player
    }
}
