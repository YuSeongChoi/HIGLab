# higlab-skill

> Official Claude Code skill for Apple framework development — powered by [HIG Lab](https://m1zz.github.io/HIGLab/)

Access 50 Apple framework AI References directly from Claude Code with the `/hig` command.

## Install

```bash
npm install -g higlab-skill
```

This automatically copies the `/hig` command to `~/.claude/commands/hig.md`.

## Usage

In Claude Code:

```
/hig storekit      # Load StoreKit 2 reference
/hig 인앱결제       # Korean keyword matching
/hig list          # Show all 50 frameworks
```

## Supported Frameworks (50)

| Category | Frameworks |
|----------|-----------|
| **UI & Data** | SwiftUI, Observation, SwiftData |
| **Widgets & Activities** | WidgetKit, ActivityKit |
| **AI & Intents** | Foundation Models, App Intents, Visual Intelligence |
| **Tips & Store** | TipKit, StoreKit 2, PassKit |
| **Cloud & Auth** | CloudKit, Auth Services, LocalAuthentication, CryptoKit |
| **Health & Location** | HealthKit, MapKit, Core Location |
| **ML & Vision** | Core ML, Vision |
| **Notifications & Social** | User Notifications, SharePlay |
| **PIM** | EventKit, Contacts, MusicKit, WeatherKit |
| **AR & Graphics** | ARKit, RealityKit, SpriteKit, Core Image, PencilKit, PDFKit |
| **Media** | AVFoundation, AVKit, PhotosUI, Core Haptics, ShazamKit, Image Playground |
| **Connectivity** | Core Bluetooth, Core NFC, MultipeerConnectivity, Network, CallKit, Wi-Fi Aware |
| **System** | AlarmKit, EnergyKit, PermissionKit, RelevanceKit, AccessorySetupKit, ExtensibleImage |

## Uninstall

```bash
higlab-skill-uninstall
npm uninstall -g higlab-skill
```

## CLAUDE.md Integration

For automatic framework detection without `/hig`, copy the snippet from `claude-md-snippet.md` into your project's `CLAUDE.md`.

## Links

- [HIG Lab](https://m1zz.github.io/HIGLab/) — Browse all references
- [GitHub](https://github.com/M1zz/HIGLab)
- [한국어 README](./README.ko.md)

## License

MIT © [M1zz](https://github.com/M1zz)
