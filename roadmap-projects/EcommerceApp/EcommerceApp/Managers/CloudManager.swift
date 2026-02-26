import Foundation
import CloudKit

@Observable
final class CloudManager {
    private let container = CKContainer(identifier: "iCloud.com.higlab.ecommerce")
    private let database: CKDatabase
    
    private(set) var iCloudStatus: ICloudStatus = .checking
    private(set) var syncStatus: SyncStatus = .idle
    
    enum ICloudStatus {
        case checking
        case available
        case unavailable
        case restricted
    }
    
    enum SyncStatus {
        case idle
        case syncing
        case synced(Date)
        case error(Error)
    }
    
    init() {
        database = container.privateCloudDatabase
        Task {
            await checkICloudStatus()
        }
    }
    
    // MARK: - iCloud 상태 확인
    @MainActor
    func checkICloudStatus() async {
        do {
            let status = try await container.accountStatus()
            switch status {
            case .available:
                iCloudStatus = .available
            case .noAccount, .couldNotDetermine:
                iCloudStatus = .unavailable
            case .restricted, .temporarilyUnavailable:
                iCloudStatus = .restricted
            @unknown default:
                iCloudStatus = .unavailable
            }
        } catch {
            iCloudStatus = .unavailable
        }
    }
    
    // MARK: - 위시리스트 동기화
    @MainActor
    func syncWishlist(_ productIds: [String]) async {
        guard iCloudStatus == .available else { return }
        
        syncStatus = .syncing
        
        do {
            // 기존 위시리스트 삭제
            let query = CKQuery(
                recordType: "Wishlist",
                predicate: NSPredicate(value: true)
            )
            let results = try await database.records(matching: query)
            
            for (recordId, _) in results.matchResults {
                try await database.deleteRecord(withID: recordId)
            }
            
            // 새 위시리스트 저장
            for productId in productIds {
                let record = CKRecord(recordType: "Wishlist")
                record["productId"] = productId
                record["addedAt"] = Date()
                
                try await database.save(record)
            }
            
            syncStatus = .synced(Date())
        } catch {
            syncStatus = .error(error)
        }
    }
    
    // MARK: - 위시리스트 불러오기
    @MainActor
    func fetchWishlist() async -> [String] {
        guard iCloudStatus == .available else { return [] }
        
        do {
            let query = CKQuery(
                recordType: "Wishlist",
                predicate: NSPredicate(value: true)
            )
            query.sortDescriptors = [NSSortDescriptor(key: "addedAt", ascending: false)]
            
            let results = try await database.records(matching: query)
            
            return results.matchResults.compactMap { (_, result) in
                guard case .success(let record) = result else { return nil }
                return record["productId"] as? String
            }
        } catch {
            return []
        }
    }
    
    // MARK: - 구독을 통한 실시간 업데이트
    func setupSubscription() async {
        let subscription = CKQuerySubscription(
            recordType: "Wishlist",
            predicate: NSPredicate(value: true),
            options: [.firesOnRecordCreation, .firesOnRecordDeletion]
        )
        
        let notification = CKSubscription.NotificationInfo()
        notification.shouldSendContentAvailable = true
        subscription.notificationInfo = notification
        
        do {
            try await database.save(subscription)
        } catch {
            print("구독 설정 실패: \(error)")
        }
    }
}
