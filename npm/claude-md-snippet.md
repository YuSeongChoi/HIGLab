# CLAUDE.md Snippet for HIG Lab Auto-Detection

Add the following to your project's `CLAUDE.md` to automatically use HIG Lab AI References when generating Apple framework code.

---

```markdown
## Apple Framework References (HIG Lab)

When generating code for any Apple framework, fetch the corresponding AI Reference from HIG Lab first:

- **Base URL:** `https://m1zz.github.io/HIGLab/ai-reference/`
- **How:** Before writing code for a framework below, fetch `{Base URL}{file}.md` and follow its patterns.

| Framework | File |
|-----------|------|
| SwiftUI | swiftui.md |
| Observation | swiftui-observation.md |
| SwiftData | swiftdata.md |
| WidgetKit | widgets.md |
| ActivityKit | activitykit.md |
| App Intents | appintents.md |
| Foundation Models | foundation-models.md |
| TipKit | tipkit.md |
| StoreKit 2 | storekit.md |
| PassKit | passkit.md |
| CloudKit | cloudkit.md |
| Auth Services | authservices.md |
| LocalAuthentication | localauth.md |
| CryptoKit | cryptokit.md |
| HealthKit | healthkit.md |
| MapKit | mapkit.md |
| Core Location | corelocation.md |
| Core ML | coreml.md |
| Vision | vision.md |
| User Notifications | notifications.md |
| SharePlay | shareplay.md |
| EventKit | eventkit.md |
| Contacts | contacts.md |
| MusicKit | musickit.md |
| WeatherKit | weatherkit.md |
| ARKit | arkit.md |
| RealityKit | realitykit.md |
| SpriteKit | spritekit.md |
| Core Image | coreimage.md |
| PencilKit | pencilkit.md |
| PDFKit | pdfkit.md |
| AVFoundation | avfoundation.md |
| AVKit | avkit.md |
| PhotosUI | photosui.md |
| Core Haptics | corehaptics.md |
| ShazamKit | shazamkit.md |
| Image Playground | image-playground.md |
| Core Bluetooth | core-bluetooth.md |
| Core NFC | core-nfc.md |
| MultipeerConnectivity | multipeerconnectivity.md |
| Network | network.md |
| CallKit | callkit.md |
| Wi-Fi Aware | wifi-aware.md |
| Visual Intelligence | visual-intelligence.md |
| AlarmKit | alarmkit.md |
| EnergyKit | energykit.md |
| PermissionKit | permissionkit.md |
| RelevanceKit | relevancekit.md |
| AccessorySetupKit | accessorysetupkit.md |
| ExtensibleImage | extensibleimage.md |

### Code Standards
- Swift 5.9+, iOS 17+
- SwiftUI over UIKit
- @Observable over ObservableObject
- async/await over completion handlers
- Custom error types with LocalizedError
- VoiceOver accessibility labels
```
