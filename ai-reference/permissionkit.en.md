# PermissionKit AI Reference

> System permission management guide. You can generate PermissionKit code by reading this document.

## Overview

PermissionKit is a unified permission management framework available in iOS 18+.
It allows you to request and manage various system permissions (camera, microphone, location, photos, etc.) with a consistent API.

## Required Import

```swift
import PermissionKit
```

## Project Setup

### Info.plist (for each required permission)

```xml
<!-- Camera -->
<key>NSCameraUsageDescription</key>
<string>Camera access is required to take photos.</string>

<!-- Microphone -->
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for voice recording.</string>

<!-- Location -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>Required to check your current location.</string>

<!-- Photo Library -->
<key>NSPhotoLibraryUsageDescription</key>
<string>Required to save and load photos.</string>

<!-- Contacts -->
<key>NSContactsUsageDescription</key>
<string>Required to load contacts.</string>

<!-- Notifications -->
<key>NSUserNotificationsUsageDescription</key>
<string>Required to send notifications.</string>

<!-- Health -->
<key>NSHealthShareUsageDescription</key>
<string>Required to read health data.</string>
```

## Core Components

### 1. PermissionManager

```swift
import PermissionKit

// Permission manager
let permissionManager = PermissionManager.shared

// Request single permission
let status = await permissionManager.request(.camera)

// Request multiple permissions at once
let results = await permissionManager.request([.camera, .microphone, .photoLibrary])
```

### 2. PermissionType (Permission Types)

```swift
// Supported permission types
PermissionType.camera           // Camera
PermissionType.microphone       // Microphone
PermissionType.photoLibrary     // Photo Library
PermissionType.location         // Location (when in use)
PermissionType.locationAlways   // Location (always)
PermissionType.contacts         // Contacts
PermissionType.calendar         // Calendar
PermissionType.reminders        // Reminders
PermissionType.notifications    // Notifications
PermissionType.bluetooth        // Bluetooth
PermissionType.motion           // Motion
PermissionType.health           // Health
```

### 3. PermissionStatus (Permission Status)

```swift
// Check permission status
let status = await permissionManager.status(for: .camera)

switch status {
case .notDetermined:
    // Not yet requested
case .authorized:
    // Authorized
case .denied:
    // Denied
case .restricted:
    // Restricted (parental controls, etc.)
case .limited:
    // Limited access (only some photos, etc.)
}
```

## Complete Working Example

```swift
import SwiftUI
import PermissionKit

// MARK: - Permission View Model
@Observable
class PermissionViewModel {
    var permissions: [PermissionItem] = []
    var showingSettingsAlert = false
    
    private let permissionManager = PermissionManager.shared
    
    init() {
        setupPermissions()
    }
    
    func setupPermissions() {
        permissions = [
            PermissionItem(type: .camera, title: "Camera", icon: "camera.fill", description: "Photo and video capture"),
            PermissionItem(type: .microphone, title: "Microphone", icon: "mic.fill", description: "Voice recording"),
            PermissionItem(type: .photoLibrary, title: "Photos", icon: "photo.fill", description: "Save and load photos"),
            PermissionItem(type: .location, title: "Location", icon: "location.fill", description: "Check current location"),
            PermissionItem(type: .contacts, title: "Contacts", icon: "person.crop.circle.fill", description: "Access contacts"),
            PermissionItem(type: .notifications, title: "Notifications", icon: "bell.fill", description: "Receive push notifications"),
            PermissionItem(type: .calendar, title: "Calendar", icon: "calendar", description: "Access calendar events"),
            PermissionItem(type: .motion, title: "Motion", icon: "figure.walk", description: "Steps and activity")
        ]
        
        Task {
            await refreshStatuses()
        }
    }
    
    func refreshStatuses() async {
        for index in permissions.indices {
            let status = await permissionManager.status(for: permissions[index].type)
            await MainActor.run {
                permissions[index].status = status
            }
        }
    }
    
    func requestPermission(_ permission: PermissionItem) async {
        let result = await permissionManager.request(permission.type)
        
        await MainActor.run {
            if let index = permissions.firstIndex(where: { $0.type == permission.type }) {
                permissions[index].status = result
            }
            
            if result == .denied {
                showingSettingsAlert = true
            }
        }
    }
    
    func requestAllPermissions() async {
        let types = permissions.map(\.type)
        let results = await permissionManager.request(types)
        
        await MainActor.run {
            for (type, status) in results {
                if let index = permissions.firstIndex(where: { $0.type == type }) {
                    permissions[index].status = status
                }
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Permission Item
struct PermissionItem: Identifiable {
    let id = UUID()
    let type: PermissionType
    let title: String
    let icon: String
    let description: String
    var status: PermissionStatus = .notDetermined
    
    var statusText: String {
        switch status {
        case .notDetermined: return "Not Requested"
        case .authorized: return "Authorized"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .limited: return "Limited"
        }
    }
    
    var statusColor: Color {
        switch status {
        case .authorized, .limited: return .green
        case .denied, .restricted: return .red
        case .notDetermined: return .orange
        }
    }
}

// MARK: - Main View
struct PermissionManagerView: View {
    @State private var viewModel = PermissionViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                // Request all button
                Section {
                    Button {
                        Task {
                            await viewModel.requestAllPermissions()
                        }
                    } label: {
                        Label("Request All Permissions", systemImage: "checkmark.shield.fill")
                    }
                }
                
                // Permission list
                Section("Permission List") {
                    ForEach(viewModel.permissions) { permission in
                        PermissionRow(
                            permission: permission,
                            onRequest: {
                                Task {
                                    await viewModel.requestPermission(permission)
                                }
                            }
                        )
                    }
                }
                
                // Guide
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("If Permission is Denied")
                            .font(.subheadline.bold())
                        Text("You can change permissions directly in the Settings app.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button("Open Settings") {
                            viewModel.openSettings()
                        }
                        .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Permission Manager")
            .refreshable {
                await viewModel.refreshStatuses()
            }
            .alert("Permission Denied", isPresented: $viewModel.showingSettingsAlert) {
                Button("Go to Settings") {
                    viewModel.openSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Permission was denied. Please change it in Settings.")
            }
        }
    }
}

// MARK: - Permission Row
struct PermissionRow: View {
    let permission: PermissionItem
    let onRequest: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: permission.icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(permission.title)
                    .font(.headline)
                Text(permission.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(permission.statusText)
                    .font(.caption)
                    .foregroundStyle(permission.statusColor)
                
                if permission.status == .notDetermined {
                    Button("Request") {
                        onRequest()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                } else if permission.status == .denied {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                } else if permission.status == .authorized {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PermissionManagerView()
}
```

## Advanced Patterns

### 1. Onboarding Permission Request Flow

```swift
struct OnboardingPermissionView: View {
    @State private var currentStep = 0
    @State private var isCompleted = false
    @Environment(\.dismiss) private var dismiss
    
    let requiredPermissions: [PermissionType] = [
        .camera,
        .microphone,
        .notifications
    ]
    
    var body: some View {
        VStack(spacing: 32) {
            // Progress
            ProgressView(value: Double(currentStep), total: Double(requiredPermissions.count))
                .padding(.horizontal)
            
            Spacer()
            
            // Current permission explanation
            if currentStep < requiredPermissions.count {
                PermissionExplainView(type: requiredPermissions[currentStep])
            } else {
                // Complete
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.green)
                    Text("Setup Complete!")
                        .font(.title.bold())
                }
            }
            
            Spacer()
            
            // Button
            if currentStep < requiredPermissions.count {
                Button {
                    Task {
                        await requestCurrentPermission()
                    }
                } label: {
                    Text("Continue")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Skip") {
                    nextStep()
                }
                .foregroundStyle(.secondary)
            } else {
                Button {
                    dismiss()
                } label: {
                    Text("Get Started")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .padding()
    }
    
    func requestCurrentPermission() async {
        let type = requiredPermissions[currentStep]
        _ = await PermissionManager.shared.request(type)
        await MainActor.run {
            nextStep()
        }
    }
    
    func nextStep() {
        withAnimation {
            currentStep += 1
        }
    }
}

struct PermissionExplainView: View {
    let type: PermissionType
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconFor(type))
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text(titleFor(type))
                .font(.title2.bold())
            
            Text(descriptionFor(type))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
    
    func iconFor(_ type: PermissionType) -> String {
        switch type {
        case .camera: return "camera.fill"
        case .microphone: return "mic.fill"
        case .notifications: return "bell.fill"
        default: return "questionmark.circle"
        }
    }
    
    func titleFor(_ type: PermissionType) -> String {
        switch type {
        case .camera: return "Camera Access"
        case .microphone: return "Microphone Access"
        case .notifications: return "Allow Notifications"
        default: return "Permission Request"
        }
    }
    
    func descriptionFor(_ type: PermissionType) -> String {
        switch type {
        case .camera: return "Camera access is required to capture photos and videos."
        case .microphone: return "Microphone access is required to record audio."
        case .notifications: return "Notification permission is required to receive important alerts."
        default: return "Permission is required to use this feature."
        }
    }
}
```

### 2. Permission Status Monitoring

```swift
class PermissionMonitor: ObservableObject {
    @Published var cameraStatus: PermissionStatus = .notDetermined
    @Published var locationStatus: PermissionStatus = .notDetermined
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Subscribe to permission status changes
        PermissionManager.shared.statusPublisher(for: .camera)
            .receive(on: DispatchQueue.main)
            .assign(to: &$cameraStatus)
        
        PermissionManager.shared.statusPublisher(for: .location)
            .receive(on: DispatchQueue.main)
            .assign(to: &$locationStatus)
        
        // Refresh when app enters foreground
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                Task {
                    await self?.refreshStatuses()
                }
            }
            .store(in: &cancellables)
    }
    
    func refreshStatuses() async {
        let camera = await PermissionManager.shared.status(for: .camera)
        let location = await PermissionManager.shared.status(for: .location)
        
        await MainActor.run {
            self.cameraStatus = camera
            self.locationStatus = location
        }
    }
}
```

### 3. Conditional Feature Access

```swift
struct FeatureView: View {
    @State private var cameraPermission: PermissionStatus = .notDetermined
    
    var body: some View {
        Group {
            switch cameraPermission {
            case .authorized:
                CameraView()
            case .denied, .restricted:
                PermissionDeniedView(
                    permission: .camera,
                    onOpenSettings: openSettings
                )
            case .notDetermined:
                PermissionRequestView(
                    permission: .camera,
                    onRequest: requestPermission
                )
            case .limited:
                LimitedAccessView()
            }
        }
        .task {
            cameraPermission = await PermissionManager.shared.status(for: .camera)
        }
    }
    
    func requestPermission() {
        Task {
            cameraPermission = await PermissionManager.shared.request(.camera)
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
```

## Notes

1. **iOS Version**
   - PermissionKit: iOS 18+ only
   - Use individual framework APIs for earlier versions

2. **Info.plist Required**
   - Usage Description is required for each permission
   - App will crash if missing

3. **Handling Denied Permissions**
   - Denied permissions cannot be re-requested from the app
   - Must guide users to Settings app

4. **Limited Access**
   - Some permissions like Photos can have Limited status
   - Provide appropriate UI for partial access

5. **Testing**
   - Most permissions can be tested on simulator
   - Some (Bluetooth, etc.) require real device
