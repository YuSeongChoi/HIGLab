import UIKit
import CloudKit

/// UICloudSharingController 생성
func createSharingController(
    for share: CKShare,
    container: CKContainer
) -> UICloudSharingController {
    
    let controller = UICloudSharingController(share: share, container: container)
    
    // 공유 옵션 설정
    controller.availablePermissions = [.allowPublic, .allowPrivate, .allowReadOnly, .allowReadWrite]
    
    return controller
}

/// 새 공유 생성 시
func createSharingController(
    preparationHandler: @escaping (UICloudSharingController, @escaping (CKShare?, CKContainer?, Error?) -> Void) -> Void
) -> UICloudSharingController {
    
    return UICloudSharingController(preparationHandler: preparationHandler)
}
