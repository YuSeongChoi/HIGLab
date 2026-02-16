import UIKit
import CloudKit

// UICloudSharingControllerDelegate 필수 메서드

extension CloudSharingView.Coordinator {
    
    // 공유 저장 실패
    // func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error)
    
    // 공유 저장 성공
    // func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController)
    
    // 공유 중단됨
    // func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController)
    
    // 공유 제목 (필수)
    // func itemTitle(for csc: UICloudSharingController) -> String?
}

// 선택적 메서드

// func itemThumbnailData(for csc: UICloudSharingController) -> Data?
// 썸네일 이미지 데이터

// func itemType(for csc: UICloudSharingController) -> String?
// UTI 타입 (예: "com.example.note")
