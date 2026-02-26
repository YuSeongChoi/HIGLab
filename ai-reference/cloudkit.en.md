# CloudKit AI Reference

> iCloud data synchronization guide. Read this document to generate CloudKit code.

## Overview

CloudKit is Apple's cloud database service.
It stores data and synchronizes across devices through the user's iCloud account.

## Required Import

```swift
import CloudKit
```

## Project Setup

1. **Add Capabilities**: Signing & Capabilities → + CloudKit
2. **Select Container**: `iCloud.com.yourcompany.appname`
3. **Define Record Types**: Create schema in CloudKit Dashboard

## Core Components

### 1. Container & Database

```swift
// Default container
let container = CKContainer.default()

// Custom container
let container = CKContainer(identifier: "iCloud.com.example.app")

// Database types
let privateDB = container.privateCloudDatabase  // User's personal data
let publicDB = container.publicCloudDatabase    // Shared with all users
let sharedDB = container.sharedCloudDatabase    // Shared data
```

### 2. CKRecord (Data Model)

```swift
// Create record
let record = CKRecord(recordType: "Note")
record["title"] = "Note Title"
record["content"] = "Note Content"
record["createdAt"] = Date()
record["isPinned"] = false

// Asset (file/image)
let imageURL = FileManager.default.temporaryDirectory.appendingPathComponent("image.jpg")
record["image"] = CKAsset(fileURL: imageURL)

// Reference (relationship)
let folderRecordID = CKRecord.ID(recordName: "folder-123")
record["folder"] = CKRecord.Reference(recordID: folderRecordID, action: .deleteSelf)
```

### 3. CRUD Operations

```swift
class CloudKitManager {
    private let database = CKContainer.default().privateCloudDatabase
    
    // CREATE
    func save(_ record: CKRecord) async throws -> CKRecord {
        try await database.save(record)
    }
    
    // READ (single)
    func fetch(recordID: CKRecord.ID) async throws -> CKRecord {
        try await database.record(for: recordID)
    }
    
    // READ (query)
    func fetchNotes() async throws -> [CKRecord] {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Note", predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        let (results, _) = try await database.records(matching: query)
        return results.compactMap { try? $0.1.get() }
    }
    
    // UPDATE
    func update(_ record: CKRecord) async throws -> CKRecord {
        try await database.save(record)  // save also handles update
    }
    
    // DELETE
    func delete(recordID: CKRecord.ID) async throws {
        try await database.deleteRecord(withID: recordID)
    }
}
```

## Complete Working Example

```swift
import SwiftUI
import CloudKit

// MARK: - Model
struct Note: Identifiable {
    let id: CKRecord.ID
    var title: String
    var content: String
    var createdAt: Date
    
    init(record: CKRecord) {
        self.id = record.recordID
        self.title = record["title"] as? String ?? ""
        self.content = record["content"] as? String ?? ""
        self.createdAt = record["createdAt"] as? Date ?? Date()
    }
    
    func toRecord() -> CKRecord {
        let record = CKRecord(recordType: "Note", recordID: id)
        record["title"] = title
        record["content"] = content
        record["createdAt"] = createdAt
        return record
    }
}

// MARK: - ViewModel
@Observable
class NotesViewModel {
    var notes: [Note] = []
    var isLoading = false
    var error: Error?
    
    private let database = CKContainer.default().privateCloudDatabase
    
    func fetchNotes() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let query = CKQuery(recordType: "Note", predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let (results, _) = try await database.records(matching: query)
            notes = results.compactMap { result in
                guard let record = try? result.1.get() else { return nil }
                return Note(record: record)
            }
        } catch {
            self.error = error
        }
    }
    
    func addNote(title: String, content: String) async {
        let record = CKRecord(recordType: "Note")
        record["title"] = title
        record["content"] = content
        record["createdAt"] = Date()
        
        do {
            let saved = try await database.save(record)
            let note = Note(record: saved)
            notes.insert(note, at: 0)
        } catch {
            self.error = error
        }
    }
    
    func deleteNote(_ note: Note) async {
        do {
            try await database.deleteRecord(withID: note.id)
            notes.removeAll { $0.id == note.id }
        } catch {
            self.error = error
        }
    }
}

// MARK: - View
struct NotesListView: View {
    @State private var viewModel = NotesViewModel()
    @State private var showingAddSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.notes) { note in
                    VStack(alignment: .leading) {
                        Text(note.title).font(.headline)
                        Text(note.content).font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        Task { await viewModel.deleteNote(viewModel.notes[index]) }
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                Button("Add", systemImage: "plus") {
                    showingAddSheet = true
                }
            }
            .refreshable {
                await viewModel.fetchNotes()
            }
            .task {
                await viewModel.fetchNotes()
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
}
```

## Advanced Patterns

### 1. Real-time Subscriptions (Push)

```swift
func subscribeToChanges() async throws {
    let subscription = CKQuerySubscription(
        recordType: "Note",
        predicate: NSPredicate(value: true),
        subscriptionID: "note-changes",
        options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion]
    )
    
    let notification = CKSubscription.NotificationInfo()
    notification.shouldSendContentAvailable = true  // Background notification
    subscription.notificationInfo = notification
    
    try await database.save(subscription)
}

// Handle in AppDelegate
func application(_ application: UIApplication,
                 didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
    let notification = CKNotification(fromRemoteNotificationDictionary: userInfo)
    
    if let queryNotification = notification as? CKQueryNotification {
        // Get changed recordID
        if let recordID = queryNotification.recordID {
            // Refresh data
        }
    }
    return .newData
}
```

### 2. Batch Operations

```swift
func batchSave(records: [CKRecord]) async throws {
    let operation = CKModifyRecordsOperation(recordsToSave: records)
    operation.savePolicy = .changedKeys  // Save only changed keys
    
    try await database.modifyRecords(saving: records, deleting: [])
}

func batchDelete(recordIDs: [CKRecord.ID]) async throws {
    try await database.modifyRecords(saving: [], deleting: recordIDs)
}
```

### 3. Zone-based Sync

```swift
// Create custom zone
let zoneID = CKRecordZone.ID(zoneName: "MyZone", ownerName: CKCurrentUserDefaultName)
let zone = CKRecordZone(zoneID: zoneID)
try await database.save(zone)

// Save record in zone
let record = CKRecord(recordType: "Note", recordID: CKRecord.ID(zoneID: zoneID))

// Fetch changes (efficient sync)
func fetchChanges(since token: CKServerChangeToken?) async throws {
    let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
    config.previousServerChangeToken = token
    
    let operation = CKFetchRecordZoneChangesOperation(
        recordZoneIDs: [zoneID],
        configurationsByRecordZoneID: [zoneID: config]
    )
    // ... process changes
}
```

### 4. Sharing

```swift
func share(_ record: CKRecord) async throws -> CKShare {
    let share = CKShare(rootRecord: record)
    share.publicPermission = .readOnly
    
    let (savedRecords, _) = try await database.modifyRecords(
        saving: [record, share],
        deleting: []
    )
    
    return savedRecords.first { $0 is CKShare } as! CKShare
}
```

## Important Notes

1. **iCloud Account Required**
   - Need to check user login status
   - Check with `CKContainer.default().accountStatus()`

2. **Quota Limits**
   - Private DB: Unlimited (uses user's iCloud storage)
   - Public DB: 1GB free per app
   - Use CKAsset for large files

3. **Offline Handling**
   - CloudKit has no offline cache
   - Core Data + CloudKit combination recommended (NSPersistentCloudKitContainer)

4. **Error Handling**
   ```swift
   do {
       try await database.save(record)
   } catch let error as CKError {
       switch error.code {
       case .networkFailure: // Network error
       case .serverRecordChanged: // Conflict
       case .quotaExceeded: // Storage exceeded
       default: break
       }
   }
   ```
