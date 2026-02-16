import CloudKit
import SwiftUI
import Foundation

/// 메모 데이터 모델
struct Note: Identifiable, Equatable {
    let id: String
    var title: String
    var content: String
    var createdAt: Date
    var modifiedAt: Date
    var isShared: Bool
    
    // CloudKit 레코드 ID (nil이면 아직 저장 안됨)
    var recordID: CKRecord.ID?
    
    init(
        id: String = UUID().uuidString,
        title: String = "",
        content: String = "",
        createdAt: Date = Date(),
        modifiedAt: Date = Date(),
        isShared: Bool = false,
        recordID: CKRecord.ID? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
        self.isShared = isShared
        self.recordID = recordID
    }
}
