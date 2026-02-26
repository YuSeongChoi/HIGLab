# 🍎 HIG Lab

> **Hands-on Apple Frameworks, one at a time**

🇰🇷 [한국어](README.md) | 🇺🇸 **English**

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Learn the **top 50** of Apple's 367 frameworks through practical, hands-on projects. Each technology includes:

1. **📝 Blog Post** — HIG guideline walkthrough + real-world examples
2. **📚 DocC Tutorial** — Step-by-step guide you can follow right in Xcode (10+ chapters)
3. **💻 Sample Project** — Production-quality SwiftUI app (avg. 5,000+ lines)
4. **🛠️ AI Skills** — Ready-to-use config files for Claude Code, Cursor, and Copilot

🌐 **Live Site**: [m1zz.github.io/HIGLab](https://m1zz.github.io/HIGLab/)

> 🌱 **New to iOS?** → Start with the [Getting Started Guide (GETTING_STARTED.md)](GETTING_STARTED.md)!

---

## 📊 Progress

| Category | Done | Progress |
|----------|------|----------|
| 📝 Blog | **50/50** | 100% ✅ |
| 📚 DocC | **50/50** (10+ chapters) | 100% ✅ |
| 💻 Samples | **43** (covering all 50) | 100% ✅ |
| 🛠️ Skills | **3** (Claude/Cursor/Copilot) | 100% ✅ |

> **🎉 Project Complete!** Full coverage of all 50 technologies

### 📈 Project Scale
- **Total sample projects**: 43
- **Total Swift files**: 468
- **Total lines of code**: 148,411
- **Average sample size**: 3,450 lines (senior-level quality)

---

## 💻 Sample Projects (43)

### 🚀 Phase 1: App Frameworks

| Sample | Technology | Size | Description |
|--------|-----------|------|-------------|
| [WeatherWidget](samples/WeatherWidget/) | WidgetKit, WeatherKit | 5,577 lines | All widget sizes + interactive |
| [TaskMaster](samples/TaskMaster/) | SwiftUI, SwiftData, Observation | 1,647 lines | CRUD + sync |
| [DeliveryTracker](samples/DeliveryTracker/) | ActivityKit | 1,766 lines | Live Activity + Dynamic Island |
| [SiriTodo](samples/SiriTodo/) | App Intents | 5,689 lines | 12 intents + widgets |
| [AIChatbot](samples/AIChatbot/) | Foundation Models | 6,285 lines | Tool use + streaming |

### 💳 Phase 2: App Services

| Sample | Technology | Size | Description |
|--------|-----------|------|-------------|
| [SubscriptionApp](samples/SubscriptionApp/) | StoreKit 2 | 2,043 lines | Subscriptions + IAP |
| [PremiumApp](samples/PremiumApp/) | StoreKit 2 | 1,900 lines | IAP + restore |
| [CartFlow](samples/CartFlow/) | PassKit | 5,391 lines | Full Apple Pay implementation |
| [CloudNotes](samples/CloudNotes/) | CloudKit | 1,952 lines | iCloud sync |
| [SecureVault](samples/SecureVault/) | AuthServices, LocalAuth, CryptoKit | 5,935 lines | Sign in with Apple + biometrics + encryption |
| [HealthTracker](samples/HealthTracker/) | HealthKit | 3,929 lines | Steps/heart rate/sleep/workouts |
| [PlaceExplorer](samples/PlaceExplorer/) | MapKit | 1,793 lines | Maps + POI |
| [LocationTracker](samples/LocationTracker/) | Core Location | 3,429 lines | GPS + geofencing |
| [MLClassifier](samples/MLClassifier/) | Core ML | 5,502 lines | Vision + real-time classification |
| [VisionScanner](samples/VisionScanner/) | Vision, Visual Intelligence | 2,131 lines | OCR + object detection |
| [NotifyMe](samples/NotifyMe/) | User Notifications | 2,684 lines | Local/push notifications |
| [TipShowcase](samples/TipShowcase/) | TipKit | 6,694 lines | All scenarios |
| [WatchParty](samples/WatchParty/) | SharePlay | 3,296 lines | GroupActivity + synced playback |

### 🎮 Phase 3: Graphics & Media

| Sample | Technology | Size | Description |
|--------|-----------|------|-------------|
| [ARFurniture](samples/ARFurniture/) | ARKit, RealityKit | 2,064 lines | AR furniture placement |
| [SpaceShooter](samples/SpaceShooter/) | SpriteKit | 2,804 lines | 2D shooting game |
| [FilterLab](samples/FilterLab/) | Core Image | 2,516 lines | 30+ filters + Metal kernel |
| [SketchPad](samples/SketchPad/) | PencilKit | 1,750 lines | Drawing app |
| [PDFReader](samples/PDFReader/) | PDFKit | 3,057 lines | PDF viewer/editor |
| [CameraApp](samples/CameraApp/) | AVFoundation | 6,046 lines | Full camera features |
| [MusicPlayer](samples/MusicPlayer/) | MusicKit, AVKit | 1,591 lines | Apple Music integration |
| [PhotoGallery](samples/PhotoGallery/) | PhotosUI | 6,326 lines | Gallery + editing |
| [HapticDemo](samples/HapticDemo/) | Core Haptics | 2,757 lines | Haptic pattern editor |
| [SoundMatch](samples/SoundMatch/) | ShazamKit | 5,484 lines | Music recognition + MusicKit |
| [ImageMaker](samples/ImageMaker/) | Image Playground | 2,775 lines | AI image generation |

### 🔧 Phase 4: System & Network

| Sample | Technology | Size | Description |
|--------|-----------|------|-------------|
| [BLEScanner](samples/BLEScanner/) | Core Bluetooth | 2,237 lines | BLE device connection |
| [NFCReader](samples/NFCReader/) | Core NFC | 3,599 lines | Tag read/write |
| [PeerChat](samples/PeerChat/) | MultipeerConnectivity | 2,677 lines | P2P chat |
| [NetMonitor](samples/NetMonitor/) | Network | 2,447 lines | Network monitoring |
| [VoIPPhone](samples/VoIPPhone/) | CallKit | 2,840 lines | VoIP calls |
| [CalendarPlus](samples/CalendarPlus/) | EventKit | 3,306 lines | Calendar + reminders |
| [ContactBook](samples/ContactBook/) | Contacts | 3,330 lines | Contact management |
| [DirectShare](samples/DirectShare/) | Wi-Fi Aware | 2,718 lines | AP-free P2P transfer |

### 🆕 Phase 5: iOS 26

| Sample | Technology | Size | Description |
|--------|-----------|------|-------------|
| [WakeUp](samples/WakeUp/) | AlarmKit | 2,761 lines | System alarms |
| [GreenCharge](samples/GreenCharge/) | EnergyKit | 4,399 lines | Power grid forecast |
| [PermissionHub](samples/PermissionHub/) | PermissionKit | 3,497 lines | Unified permission management |
| [SmartFeed](samples/SmartFeed/) | RelevanceKit | 3,921 lines | Content recommendation |
| [DevicePair](samples/DevicePair/) | AccessorySetupKit | 2,729 lines | Accessory pairing |
| [SmartCrop](samples/SmartCrop/) | ExtensibleImage | 3,137 lines | AI image editing |

---

## 📚 DocC Tutorials (50)

All tutorials have **10+ chapters**.

```bash
# Example: run a tutorial
cd tutorials/widgets
swift package generate-documentation --target HIGWidgets
```

---

## 🏆 Senior-Level Code Quality

Every sample project targets **9/10 quality** by a 10-year Apple developer standard:

- ✅ **Full API coverage** — Uses each framework's key classes/protocols
- ✅ **Error handling** — Custom error types + LocalizedError
- ✅ **Swift Concurrency** — async/await + Actor patterns
- ✅ **Accessibility** — VoiceOver support
- ✅ **Documentation** — Full /// doc comments
- ✅ **SwiftUI Previews** — #Preview macros throughout

---

## 📁 Project Structure

```
HIGLab/
├── site/                    # 📝 Blog posts (50)
│   ├── index.html
│   └── {framework}/01-*.html
├── tutorials/              # 📚 DocC tutorials (50)
│   └── {framework}/        # Swift Package + DocC
├── samples/               # 💻 Sample projects (43)
│   └── {SampleName}/      # Complete SwiftUI apps
├── ai-reference/          # 🤖 AI Reference (50)
│   └── {framework}.md
├── skills/                # 🛠️ AI Skills (Claude/Cursor/Copilot)
│   ├── claude-code/
│   ├── cursor/
│   └── copilot/
└── SSOT.json              # Single Source of Truth
```

---

## 🤖 AI Reference (50)

Reference documents designed to help AI generate accurate iOS code.

👉 **[Usage Guide](ai-reference/HOW-TO-USE.md)** — Prompt tips, examples, troubleshooting
👉 **[Full Document List](ai-reference/README.md)** — All 50 AI Reference catalog

### App Frameworks (8)
| Document | Description |
|----------|-------------|
| [swiftui.md](ai-reference/swiftui.md) | SwiftUI basics |
| [swiftui-observation.md](ai-reference/swiftui-observation.md) | @Observable state management |
| [swiftdata.md](ai-reference/swiftdata.md) | SwiftData CRUD |
| [widgets.md](ai-reference/widgets.md) | WidgetKit implementation |
| [activitykit.md](ai-reference/activitykit.md) | Live Activity, Dynamic Island |
| [appintents.md](ai-reference/appintents.md) | Siri & Shortcuts integration |
| [foundation-models.md](ai-reference/foundation-models.md) | On-device LLM |
| [tipkit.md](ai-reference/tipkit.md) | Feature tips & onboarding |

### App Services (16)
| Document | Description |
|----------|-------------|
| [storekit.md](ai-reference/storekit.md) | In-app purchases & subscriptions |
| [passkit.md](ai-reference/passkit.md) | Apple Pay & Wallet |
| [cloudkit.md](ai-reference/cloudkit.md) | iCloud sync |
| [authservices.md](ai-reference/authservices.md) | Sign in with Apple |
| [localauth.md](ai-reference/localauth.md) | Face ID / Touch ID |
| [cryptokit.md](ai-reference/cryptokit.md) | Encryption & hashing |
| [healthkit.md](ai-reference/healthkit.md) | Health data |
| [mapkit.md](ai-reference/mapkit.md) | Maps & POI |
| [corelocation.md](ai-reference/corelocation.md) | GPS & geofencing |
| [coreml.md](ai-reference/coreml.md) | On-device ML |
| [vision.md](ai-reference/vision.md) | Image analysis & OCR |
| [notifications.md](ai-reference/notifications.md) | Push/local notifications |
| [shareplay.md](ai-reference/shareplay.md) | FaceTime shared experiences |
| [eventkit.md](ai-reference/eventkit.md) | Calendar & reminders |
| [contacts.md](ai-reference/contacts.md) | Contact management |
| [musickit.md](ai-reference/musickit.md) | Apple Music integration |

### Graphics & Media (13)
| Document | Description |
|----------|-------------|
| [arkit.md](ai-reference/arkit.md) | Augmented reality |
| [realitykit.md](ai-reference/realitykit.md) | 3D rendering |
| [spritekit.md](ai-reference/spritekit.md) | 2D game engine |
| [coreimage.md](ai-reference/coreimage.md) | Image filters |
| [pencilkit.md](ai-reference/pencilkit.md) | Apple Pencil drawing |
| [pdfkit.md](ai-reference/pdfkit.md) | PDF viewer/editor |
| [avfoundation.md](ai-reference/avfoundation.md) | Camera & audio |
| [avkit.md](ai-reference/avkit.md) | Video playback |
| [photosui.md](ai-reference/photosui.md) | Photo library |
| [corehaptics.md](ai-reference/corehaptics.md) | Haptic feedback |
| [shazamkit.md](ai-reference/shazamkit.md) | Music recognition |
| [image-playground.md](ai-reference/image-playground.md) | AI image generation |
| [weatherkit.md](ai-reference/weatherkit.md) | Weather data |

### System & Network (6)
| Document | Description |
|----------|-------------|
| [core-bluetooth.md](ai-reference/core-bluetooth.md) | BLE device connection |
| [core-nfc.md](ai-reference/core-nfc.md) | NFC tag read/write |
| [multipeerconnectivity.md](ai-reference/multipeerconnectivity.md) | P2P communication |
| [network.md](ai-reference/network.md) | Low-level networking |
| [callkit.md](ai-reference/callkit.md) | VoIP calls |
| [wifi-aware.md](ai-reference/wifi-aware.md) | Wi-Fi direct connection |

### iOS 18+ Apple Intelligence (7)
| Document | Description |
|----------|-------------|
| [visual-intelligence.md](ai-reference/visual-intelligence.md) | Visual analysis |
| [alarmkit.md](ai-reference/alarmkit.md) | Alarm clock |
| [energykit.md](ai-reference/energykit.md) | Energy data |
| [permissionkit.md](ai-reference/permissionkit.md) | Unified permission management |
| [relevancekit.md](ai-reference/relevancekit.md) | Context-based recommendations |
| [accessorysetupkit.md](ai-reference/accessorysetupkit.md) | Accessory pairing |
| [extensibleimage.md](ai-reference/extensibleimage.md) | Image editing extensions |

> 💡 Feed these docs to Claude, GPT, or Cursor for accurate iOS code generation!

---

## 🚀 Getting Started

### Browse the Blog
```bash
open https://m1zz.github.io/HIGLab/
```

### Run DocC Tutorials
```bash
cd tutorials/widgets
swift package --disable-sandbox preview-documentation --target HIGWidgets
```

### Run Sample Projects
See the `README.md` inside each sample folder.

```bash
cd samples/WeatherWidget
cat README.md
```

---

## 🤖 AI Agent Support

We support [llms.txt](https://m1zz.github.io/HIGLab/llms.txt) for efficient AI agent consumption.

| Endpoint | Description |
|----------|-------------|
| [`/llms.txt`](https://m1zz.github.io/HIGLab/llms.txt) | Project summary + 50 AI Reference links |
| [`/llms-full.txt`](https://m1zz.github.io/HIGLab/llms-full.txt) | All 50 AI References combined (markdown) |
| [`/ai-reference/*.md`](https://m1zz.github.io/HIGLab/ai-reference/) | Individual framework reference docs |

> 💡 Provide the `llms.txt` URL to Claude, GPT, or Cursor for accurate iOS code generation.

---

## 🛠️ AI Skills — AI Coding Tool Integration

### What are Skills?

Config files that help AI coding tools (Claude Code, Cursor, Copilot) generate **more accurate iOS code**.

**Problem**: AI often uses deprecated APIs or doesn't know iOS 17+ patterns (`@Observable`, `SwiftData`).  
**Solution**: HIG Lab's AI Reference as Skills gives AI access to best practices for 50 Apple frameworks.

👉 **[Installation Guide](skills/README.md)**

---

### 📦 Quick Install

#### Claude Code — `/hig` Command

```bash
# Global install (available in all projects)
mkdir -p ~/.claude/commands
curl -o ~/.claude/commands/hig.md https://raw.githubusercontent.com/M1zz/HIGLab/main/skills/claude-code/hig.md
```

#### Cursor

```bash
# Copy to project root
curl -o .cursorrules https://raw.githubusercontent.com/M1zz/HIGLab/main/skills/cursor/.cursorrules
```

#### GitHub Copilot

```bash
mkdir -p .github
curl -o .github/copilot-instructions.md https://raw.githubusercontent.com/M1zz/HIGLab/main/skills/copilot/copilot-instructions.md
```

---

### 💡 Usage Examples

#### Using `/hig` Command in Claude Code

```
You: /hig storekit
     Add in-app purchase functionality

AI:  (Automatically fetches StoreKit 2 AI Reference)
     I'll implement using Product.products(for:) with @Observable pattern...
```

Korean keywords also work:

```
/hig 인앱결제    → StoreKit 2
/hig 위젯       → WidgetKit
/hig list      → All 50 frameworks
```

#### Before & After

| | Before (without Skills) | After (with Skills) |
|---|---|---|
| State | `@StateObject`, `ObservableObject` | ✅ `@Observable` (iOS 17+) |
| Data | Core Data + `@FetchRequest` | ✅ SwiftData + `@Query` |
| IAP | StoreKit 1 completion handlers | ✅ StoreKit 2 async/await |
| Errors | `print(error)` | ✅ `LocalizedError` protocol |

---

### 🔧 Supported Tools

| Tool | File | Description |
|------|------|-------------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | `skills/claude-code/hig.md` | `/hig` slash command |
| [Cursor](https://cursor.sh) | `skills/cursor/.cursorrules` | Auto context awareness |
| [GitHub Copilot](https://github.com/features/copilot) | `skills/copilot/copilot-instructions.md` | VS Code auto-apply |
| Other AI | `llms.txt` / `llms-full.txt` | URL: `https://m1zz.github.io/HIGLab/llms.txt` |

> 💡 Clone the project and open it with your AI coding tool — the AI will automatically reference all 50 framework documents to generate accurate iOS code.

---

## 🤝 Contributing

PRs welcome!

## 📄 License

MIT License. Use freely.

---

Made with ❤️ by [개발자리 (Leeo)](https://youtube.com/@leeo25)
