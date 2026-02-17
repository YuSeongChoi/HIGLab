import AccessorySetupKit
import Foundation

@Observable
class AccessoryStore {
    private(set) var accessories: [StoredAccessory] = []
    private let defaults = UserDefaults.standard
    private let storageKey = "storedAccessories"
    
    struct StoredAccessory: Identifiable, Codable {
        let id: UUID
        var displayName: String
        var bluetoothIdentifier: UUID?
        var addedDate: Date
        var lastConnected: Date?
        var customName: String?
        
        var name: String {
            customName ?? displayName
        }
    }
    
    init() {
        loadAccessories()
    }
    
    func add(_ accessory: ASAccessory) {
        let stored = StoredAccessory(
            id: UUID(),
            displayName: accessory.displayName,
            bluetoothIdentifier: accessory.bluetoothIdentifier,
            addedDate: Date()
        )
        accessories.append(stored)
        saveAccessories()
    }
    
    func remove(id: UUID) {
        accessories.removeAll { $0.id == id }
        saveAccessories()
    }
    
    func rename(id: UUID, to name: String) {
        guard let index = accessories.firstIndex(where: { $0.id == id }) else { return }
        accessories[index].customName = name
        saveAccessories()
    }
    
    func updateLastConnected(id: UUID) {
        guard let index = accessories.firstIndex(where: { $0.id == id }) else { return }
        accessories[index].lastConnected = Date()
        saveAccessories()
    }
    
    private func saveAccessories() {
        if let data = try? JSONEncoder().encode(accessories) {
            defaults.set(data, forKey: storageKey)
        }
    }
    
    private func loadAccessories() {
        guard let data = defaults.data(forKey: storageKey),
              let stored = try? JSONDecoder().decode([StoredAccessory].self, from: data) else { return }
        accessories = stored
    }
}
