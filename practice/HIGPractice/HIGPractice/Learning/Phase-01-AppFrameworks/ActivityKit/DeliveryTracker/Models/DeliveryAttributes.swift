import ActivityKit
import Foundation

struct DeliveryAttributes: ActivityAttributes {
    let orderNumber: String
    let storeName: String
    let storeImageURL: URL?
    let customerAddress: String

    struct ContentState: Codable, Hashable {
        let status: DeliveryStatus
        let estimatedArrival: Date
        let driverName: String?
        let driverImageURL: URL?
    }
}
