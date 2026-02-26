# HIG Lab — AI Context

This project contains 50 AI Reference documents for Apple frameworks.

## AI Reference Documents

When asked about iOS/Apple framework development, consult the relevant document in `ai-reference/`:

### How to use
1. Identify which framework the user needs
2. Read the corresponding `ai-reference/{framework}.md`
3. Use it as context to generate production-quality Swift/SwiftUI code

### Framework → File mapping

| Framework | File |
|-----------|------|
| SwiftUI | `ai-reference/swiftui.md` |
| Observation (@Observable) | `ai-reference/swiftui-observation.md` |
| SwiftData | `ai-reference/swiftdata.md` |
| WidgetKit | `ai-reference/widgets.md` |
| ActivityKit | `ai-reference/activitykit.md` |
| App Intents | `ai-reference/appintents.md` |
| Foundation Models | `ai-reference/foundation-models.md` |
| TipKit | `ai-reference/tipkit.md` |
| StoreKit 2 | `ai-reference/storekit.md` |
| PassKit | `ai-reference/passkit.md` |
| CloudKit | `ai-reference/cloudkit.md` |
| Authentication Services | `ai-reference/authservices.md` |
| LocalAuthentication | `ai-reference/localauth.md` |
| CryptoKit | `ai-reference/cryptokit.md` |
| HealthKit | `ai-reference/healthkit.md` |
| MapKit | `ai-reference/mapkit.md` |
| Core Location | `ai-reference/corelocation.md` |
| Core ML | `ai-reference/coreml.md` |
| Vision | `ai-reference/vision.md` |
| User Notifications | `ai-reference/notifications.md` |
| SharePlay | `ai-reference/shareplay.md` |
| EventKit | `ai-reference/eventkit.md` |
| Contacts | `ai-reference/contacts.md` |
| MusicKit | `ai-reference/musickit.md` |
| WeatherKit | `ai-reference/weatherkit.md` |
| ARKit | `ai-reference/arkit.md` |
| RealityKit | `ai-reference/realitykit.md` |
| SpriteKit | `ai-reference/spritekit.md` |
| Core Image | `ai-reference/coreimage.md` |
| PencilKit | `ai-reference/pencilkit.md` |
| PDFKit | `ai-reference/pdfkit.md` |
| AVFoundation | `ai-reference/avfoundation.md` |
| AVKit | `ai-reference/avkit.md` |
| PhotosUI | `ai-reference/photosui.md` |
| Core Haptics | `ai-reference/corehaptics.md` |
| ShazamKit | `ai-reference/shazamkit.md` |
| Image Playground | `ai-reference/image-playground.md` |
| Core Bluetooth | `ai-reference/core-bluetooth.md` |
| Core NFC | `ai-reference/core-nfc.md` |
| MultipeerConnectivity | `ai-reference/multipeerconnectivity.md` |
| Network | `ai-reference/network.md` |
| CallKit | `ai-reference/callkit.md` |
| Wi-Fi Aware | `ai-reference/wifi-aware.md` |
| Visual Intelligence | `ai-reference/visual-intelligence.md` |
| AlarmKit | `ai-reference/alarmkit.md` |
| EnergyKit | `ai-reference/energykit.md` |
| PermissionKit | `ai-reference/permissionkit.md` |
| RelevanceKit | `ai-reference/relevancekit.md` |
| AccessorySetupKit | `ai-reference/accessorysetupkit.md` |
| ExtensibleImage | `ai-reference/extensibleimage.md` |

### Code quality standards
- Use Swift Concurrency (async/await, Actor)
- Follow SwiftUI best practices
- Include error handling with custom error types
- Add accessibility support (VoiceOver)
- Use #Preview macros
- Add /// documentation comments
