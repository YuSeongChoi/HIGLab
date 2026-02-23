import Foundation

enum PracticeCatalog {
    private static let repoBase = "https://github.com/YuSeongChoi/HIGLab/tree/main"
    private static let rawBase = "https://raw.githubusercontent.com/YuSeongChoi/HIGLab/main"
    private static let appleDocsBase = "https://developer.apple.com/documentation"

    static let items: [FrameworkItem] = [
        // Phase 1: App Frameworks
        makeItem(id: "widgetkit", name: "WidgetKit", description: "홈/잠금화면 위젯 구현", phase: .appFrameworks, symbolName: "square.grid.2x2.fill", tint: .sky, completed: false, blogSlug: "widgets", docsSlug: "widgetkit", tutorialPath: "tutorials/widgets", samplePath: "samples/WeatherWidget", aiDoc: "widgets.md"),
        makeItem(id: "activitykit", name: "ActivityKit", description: "Live Activity와 Dynamic Island", phase: .appFrameworks, symbolName: "waveform.path.ecg.rectangle.fill", tint: .orange, completed: false, blogSlug: "activitykit", docsSlug: "activitykit", tutorialPath: "tutorials/activitykit", samplePath: "samples/DeliveryTracker", aiDoc: "activitykit.md"),
        makeItem(id: "appintents", name: "App Intents", description: "Siri/Shortcuts 액션 노출", phase: .appFrameworks, symbolName: "waveform.badge.mic", tint: .pink, completed: false, blogSlug: "appintents", docsSlug: "appintents", tutorialPath: "tutorials/appintents", samplePath: "samples/SiriTodo", aiDoc: "appintents.md"),
        makeItem(id: "swiftui", name: "SwiftUI", description: "선언형 UI 설계와 데이터 흐름", phase: .appFrameworks, symbolName: "rectangle.3.group.bubble.left.fill", tint: .indigo, completed: true, blogSlug: "swiftui", docsSlug: "swiftui", tutorialPath: "tutorials/swiftui", samplePath: "samples/TaskMaster", aiDoc: "swiftui.md"),
        makeItem(id: "swiftdata", name: "SwiftData", description: "@Model 기반 로컬 데이터 영속화", phase: .appFrameworks, symbolName: "externaldrive.fill.badge.icloud", tint: .teal, completed: false, blogSlug: "swiftdata", docsSlug: "swiftdata", tutorialPath: "tutorials/swiftdata", samplePath: "samples/TaskMaster", aiDoc: "swiftdata.md"),
        makeItem(id: "observation", name: "Observation", description: "@Observable 상태 관리", phase: .appFrameworks, symbolName: "eye.fill", tint: .mint, completed: false, blogSlug: "observation", docsSlug: "observation", tutorialPath: "tutorials/observation", samplePath: "samples/TaskMaster", aiDoc: "swiftui-observation.md"),
        makeItem(id: "foundationmodels", name: "Foundation Models", description: "온디바이스 LLM 앱 설계", phase: .appFrameworks, symbolName: "brain.head.profile", tint: .cyan, completed: false, blogSlug: "foundationmodels", docsSlug: "foundationmodels", tutorialPath: "tutorials/foundationmodels", samplePath: "samples/AIChatbot", aiDoc: "foundation-models.md"),
        makeItem(id: "tipkit", name: "TipKit", description: "맥락형 힌트/온보딩 UX", phase: .appFrameworks, symbolName: "lightbulb.max.fill", tint: .teal, completed: false, blogSlug: "tipkit", docsSlug: "tipkit", tutorialPath: "tutorials/tipkit", samplePath: "samples/TipShowcase", aiDoc: "tipkit.md"),

        // Phase 2: App Services
        makeItem(id: "storekit2", name: "StoreKit 2", description: "구독/인앱결제 구매 흐름", phase: .appServices, symbolName: "cart.fill.badge.plus", tint: .orange, completed: false, blogSlug: "storekit", docsSlug: "storekit", tutorialPath: "tutorials/storekit", samplePath: "samples/PremiumApp", aiDoc: "storekit.md"),
        makeItem(id: "passkit", name: "PassKit", description: "Apple Pay 및 Wallet 연동", phase: .appServices, symbolName: "creditcard.fill", tint: .sky, completed: false, blogSlug: "passkit", docsSlug: "passkit", tutorialPath: "tutorials/passkit", samplePath: "samples/CartFlow", aiDoc: "passkit.md"),
        makeItem(id: "cloudkit", name: "CloudKit", description: "iCloud 동기화와 공유", phase: .appServices, symbolName: "icloud.fill", tint: .indigo, completed: false, blogSlug: "cloudkit", docsSlug: "cloudkit", tutorialPath: "tutorials/cloudkit", samplePath: "samples/CloudNotes", aiDoc: "cloudkit.md"),
        makeItem(id: "authservices", name: "AuthServices", description: "Sign in with Apple 인증", phase: .appServices, symbolName: "person.badge.key.fill", tint: .teal, completed: false, blogSlug: "authservices", docsSlug: "authenticationservices", tutorialPath: "tutorials/authservices", samplePath: "samples/SecureVault", aiDoc: "authservices.md"),
        makeItem(id: "healthkit", name: "HealthKit", description: "건강 데이터 권한/조회/기록", phase: .appServices, symbolName: "heart.text.square.fill", tint: .pink, completed: false, blogSlug: "healthkit", docsSlug: "healthkit", tutorialPath: "tutorials/healthkit", samplePath: "samples/HealthTracker", aiDoc: "healthkit.md"),
        makeItem(id: "weatherkit", name: "WeatherKit", description: "실시간 날씨/예보 데이터", phase: .appServices, symbolName: "cloud.sun.fill", tint: .cyan, completed: false, blogSlug: "weatherkit", docsSlug: "weatherkit", tutorialPath: "tutorials/weatherkit", samplePath: "samples/WeatherWidget", aiDoc: "weatherkit.md"),
        makeItem(id: "mapkit", name: "MapKit", description: "지도/POI/경로 탐색", phase: .appServices, symbolName: "map.fill", tint: .mint, completed: false, blogSlug: "mapkit", docsSlug: "mapkit", tutorialPath: "tutorials/mapkit", samplePath: "samples/PlaceExplorer", aiDoc: "mapkit.md"),
        makeItem(id: "corelocation", name: "Core Location", description: "위치 추적과 지오펜싱", phase: .appServices, symbolName: "location.fill", tint: .sky, completed: false, blogSlug: "corelocation", docsSlug: "corelocation", tutorialPath: "tutorials/corelocation", samplePath: "samples/LocationTracker", aiDoc: "corelocation.md"),
        makeItem(id: "coreml", name: "Core ML", description: "온디바이스 모델 추론", phase: .appServices, symbolName: "cpu.fill", tint: .indigo, completed: false, blogSlug: "coreml", docsSlug: "coreml", tutorialPath: "tutorials/coreml", samplePath: "samples/MLClassifier", aiDoc: "coreml.md"),
        makeItem(id: "vision", name: "Vision", description: "OCR/객체 인식 기반 분석", phase: .appServices, symbolName: "viewfinder", tint: .orange, completed: false, blogSlug: "vision", docsSlug: "vision", tutorialPath: "tutorials/vision", samplePath: "samples/VisionScanner", aiDoc: "vision.md"),
        makeItem(id: "notifications", name: "User Notifications", description: "로컬/푸시 알림 UX", phase: .appServices, symbolName: "bell.badge.fill", tint: .pink, completed: false, blogSlug: "notifications", docsSlug: "usernotifications", tutorialPath: "tutorials/notifications", samplePath: "samples/NotifyMe", aiDoc: "notifications.md"),
        makeItem(id: "shareplay", name: "SharePlay", description: "공동 경험/상태 동기화", phase: .appServices, symbolName: "person.2.wave.2.fill", tint: .cyan, completed: false, blogSlug: "shareplay", docsSlug: "groupactivities", tutorialPath: "tutorials/shareplay", samplePath: "samples/WatchParty", aiDoc: "shareplay.md"),
        makeItem(id: "eventkit", name: "EventKit", description: "캘린더/리마인더 연동", phase: .appServices, symbolName: "calendar.badge.plus", tint: .teal, completed: false, blogSlug: "eventkit", docsSlug: "eventkit", tutorialPath: "tutorials/eventkit", samplePath: "samples/CalendarPlus", aiDoc: "eventkit.md"),
        makeItem(id: "contacts", name: "Contacts", description: "연락처 조회/편집/저장", phase: .appServices, symbolName: "person.crop.rectangle.stack.fill", tint: .mint, completed: false, blogSlug: "contacts", docsSlug: "contacts", tutorialPath: "tutorials/contacts", samplePath: "samples/ContactBook", aiDoc: "contacts.md"),
        makeItem(id: "musickit", name: "MusicKit", description: "Apple Music 재생/메타", phase: .appServices, symbolName: "music.note", tint: .indigo, completed: false, blogSlug: "musickit", docsSlug: "musickit", tutorialPath: "tutorials/musickit", samplePath: "samples/MusicPlayer", aiDoc: "musickit.md"),

        // Phase 3: Graphics & Media
        makeItem(id: "arkit", name: "ARKit", description: "증강현실 트래킹/배치", phase: .graphicsAndMedia, symbolName: "arkit", tint: .orange, completed: false, blogSlug: "arkit", docsSlug: "arkit", tutorialPath: "tutorials/arkit", samplePath: "samples/ARFurniture", aiDoc: "arkit.md"),
        makeItem(id: "realitykit", name: "RealityKit", description: "3D 렌더링/엔티티 구성", phase: .graphicsAndMedia, symbolName: "cube.transparent.fill", tint: .cyan, completed: false, blogSlug: "realitykit", docsSlug: "realitykit", tutorialPath: "tutorials/realitykit", samplePath: "samples/ARFurniture", aiDoc: "realitykit.md"),
        makeItem(id: "spritekit", name: "SpriteKit", description: "2D 게임 씬/물리 처리", phase: .graphicsAndMedia, symbolName: "gamecontroller.fill", tint: .pink, completed: false, blogSlug: "spritekit", docsSlug: "spritekit", tutorialPath: "tutorials/spritekit", samplePath: "samples/SpaceShooter", aiDoc: "spritekit.md"),
        makeItem(id: "coreimage", name: "Core Image", description: "필터/이미지 프로세싱", phase: .graphicsAndMedia, symbolName: "camera.filters", tint: .indigo, completed: false, blogSlug: "coreimage", docsSlug: "coreimage", tutorialPath: "tutorials/coreimage", samplePath: "samples/FilterLab", aiDoc: "coreimage.md"),
        makeItem(id: "pencilkit", name: "PencilKit", description: "Apple Pencil 드로잉", phase: .graphicsAndMedia, symbolName: "pencil.tip.crop.circle", tint: .teal, completed: false, blogSlug: "pencilkit", docsSlug: "pencilkit", tutorialPath: "tutorials/pencilkit", samplePath: "samples/SketchPad", aiDoc: "pencilkit.md"),
        makeItem(id: "pdfkit", name: "PDFKit", description: "PDF 뷰어/주석/검색", phase: .graphicsAndMedia, symbolName: "doc.richtext.fill", tint: .mint, completed: false, blogSlug: "pdfkit", docsSlug: "pdfkit", tutorialPath: "tutorials/pdfkit", samplePath: "samples/PDFReader", aiDoc: "pdfkit.md"),
        makeItem(id: "avfoundation", name: "AVFoundation", description: "카메라/오디오 캡처", phase: .graphicsAndMedia, symbolName: "camera.fill", tint: .sky, completed: false, blogSlug: "avfoundation", docsSlug: "avfoundation", tutorialPath: "tutorials/avfoundation", samplePath: "samples/CameraApp", aiDoc: "avfoundation.md"),
        makeItem(id: "avkit", name: "AVKit", description: "비디오 재생 UI 컴포넌트", phase: .graphicsAndMedia, symbolName: "play.rectangle.fill", tint: .orange, completed: false, blogSlug: "avkit", docsSlug: "avkit", tutorialPath: "tutorials/avkit", samplePath: "samples/MusicPlayer", aiDoc: "avkit.md"),
        makeItem(id: "photosui", name: "PhotosUI", description: "사진 선택/편집 플로우", phase: .graphicsAndMedia, symbolName: "photo.on.rectangle.angled", tint: .pink, completed: false, blogSlug: "photosui", docsSlug: "photosui", tutorialPath: "tutorials/photosui", samplePath: "samples/PhotoGallery", aiDoc: "photosui.md"),
        makeItem(id: "corehaptics", name: "Core Haptics", description: "맞춤 햅틱 패턴 설계", phase: .graphicsAndMedia, symbolName: "waveform", tint: .indigo, completed: false, blogSlug: "corehaptics", docsSlug: "corehaptics", tutorialPath: "tutorials/corehaptics", samplePath: "samples/HapticDemo", aiDoc: "corehaptics.md"),
        makeItem(id: "shazamkit", name: "ShazamKit", description: "음악 인식/매칭 처리", phase: .graphicsAndMedia, symbolName: "music.mic", tint: .teal, completed: false, blogSlug: "shazamkit", docsSlug: "shazamkit", tutorialPath: "tutorials/shazamkit", samplePath: "samples/SoundMatch", aiDoc: "shazamkit.md"),
        makeItem(id: "imageplayground", name: "Image Playground", description: "생성형 이미지 제작", phase: .graphicsAndMedia, symbolName: "photo.badge.plus", tint: .cyan, completed: false, blogSlug: "imageplayground", docsSlug: "imageplayground", tutorialPath: "tutorials/imageplayground", samplePath: "samples/ImageMaker", aiDoc: "image-playground.md"),

        // Phase 4: System & Network
        makeItem(id: "corebluetooth", name: "Core Bluetooth", description: "BLE 기기 탐색/연결", phase: .systemAndNetwork, symbolName: "dot.radiowaves.left.and.right", tint: .sky, completed: false, blogSlug: "bluetooth", docsSlug: "corebluetooth", tutorialPath: "tutorials/corebluetooth", samplePath: "samples/BLEScanner", aiDoc: "core-bluetooth.md"),
        makeItem(id: "corenfc", name: "Core NFC", description: "NFC 태그 읽기/쓰기", phase: .systemAndNetwork, symbolName: "wave.3.right.circle.fill", tint: .orange, completed: false, blogSlug: "corenfc", docsSlug: "corenfc", tutorialPath: "tutorials/corenfc", samplePath: "samples/NFCReader", aiDoc: "core-nfc.md"),
        makeItem(id: "multipeer", name: "MultipeerConnectivity", description: "P2P 근거리 통신", phase: .systemAndNetwork, symbolName: "person.2.circle.fill", tint: .indigo, completed: false, blogSlug: "multipeer", docsSlug: "multipeerconnectivity", tutorialPath: "tutorials/multipeerconnectivity", samplePath: "samples/PeerChat", aiDoc: "multipeerconnectivity.md"),
        makeItem(id: "network", name: "Network", description: "저수준 네트워크 계층", phase: .systemAndNetwork, symbolName: "network", tint: .mint, completed: false, blogSlug: "network", docsSlug: "network", tutorialPath: "tutorials/network", samplePath: "samples/NetMonitor", aiDoc: "network.md"),
        makeItem(id: "callkit", name: "CallKit", description: "VoIP 통화 UX 통합", phase: .systemAndNetwork, symbolName: "phone.connection.fill", tint: .teal, completed: false, blogSlug: "callkit", docsSlug: "callkit", tutorialPath: "tutorials/callkit", samplePath: "samples/VoIPPhone", aiDoc: "callkit.md"),
        makeItem(id: "wifiaware", name: "Wi-Fi Aware", description: "AP 없는 직접 P2P 연결", phase: .systemAndNetwork, symbolName: "wifi", tint: .cyan, completed: false, blogSlug: "wifiaware", docsSlug: "wifiaware", tutorialPath: "tutorials/wifiaware", samplePath: "samples/DirectShare", aiDoc: "wifi-aware.md"),

        // Phase 5: iOS 26
        makeItem(id: "alarmkit", name: "AlarmKit", description: "시스템 수준 알람 기능", phase: .ios26, symbolName: "alarm.fill", tint: .orange, completed: false, blogSlug: "alarmkit", docsSlug: "alarmkit", tutorialPath: "tutorials/alarmkit", samplePath: "samples/WakeUp", aiDoc: "alarmkit.md"),
        makeItem(id: "energykit", name: "EnergyKit", description: "전력망/에너지 데이터", phase: .ios26, symbolName: "bolt.badge.clock.fill", tint: .mint, completed: false, blogSlug: "energykit", docsSlug: "energykit", tutorialPath: "tutorials/energykit", samplePath: "samples/GreenCharge", aiDoc: "energykit.md"),
        makeItem(id: "permissionkit", name: "PermissionKit", description: "통합 권한 관리 흐름", phase: .ios26, symbolName: "lock.shield.fill", tint: .indigo, completed: false, blogSlug: "permissionkit", docsSlug: "permissionkit", tutorialPath: "tutorials/permissionkit", samplePath: "samples/PermissionHub", aiDoc: "permissionkit.md"),
        makeItem(id: "relevancekit", name: "RelevanceKit", description: "맥락 기반 추천 엔진", phase: .ios26, symbolName: "chart.bar.xaxis", tint: .cyan, completed: false, blogSlug: "relevancekit", docsSlug: "relevancekit", tutorialPath: "tutorials/relevancekit", samplePath: "samples/SmartFeed", aiDoc: "relevancekit.md"),
        makeItem(id: "accessorysetupkit", name: "AccessorySetupKit", description: "액세서리 페어링 UX", phase: .ios26, symbolName: "dot.radiowaves.up.forward", tint: .teal, completed: false, blogSlug: "accessorysetupkit", docsSlug: "accessorysetupkit", tutorialPath: "tutorials/accessorysetupkit", samplePath: "samples/DevicePair", aiDoc: "accessorysetupkit.md"),
        makeItem(id: "extensibleimage", name: "ExtensibleImage", description: "AI 이미지 편집 확장", phase: .ios26, symbolName: "wand.and.stars", tint: .pink, completed: false, blogSlug: "extensibleimage", docsSlug: "extensibleimage", tutorialPath: "tutorials/extensibleimage", samplePath: "samples/SmartCrop", aiDoc: "extensibleimage.md")
    ]

    static func items(for phase: FrameworkPhase) -> [FrameworkItem] {
        items.filter { $0.phase == phase }
    }

    private static func makeItem(
        id: String,
        name: String,
        description: String,
        phase: FrameworkPhase,
        symbolName: String,
        tint: FrameworkTint,
        completed: Bool,
        blogSlug: String,
        docsSlug: String,
        tutorialPath: String,
        samplePath: String?,
        aiDoc: String
    ) -> FrameworkItem {
        let blogURL = URL(string: "\(repoBase)/site/\(blogSlug)")
        let docsURL = URL(string: "\(appleDocsBase)/\(docsSlug)")
        let sampleURL = samplePath.flatMap { URL(string: "\(repoBase)/\($0)") }
        let aiURL = URL(string: "\(rawBase)/ai-reference/\(aiDoc)")

        return FrameworkItem(
            id: id,
            name: name,
            description: description,
            phase: phase,
            symbolName: symbolName,
            tint: tint,
            isCompleted: completed,
            localSitePath: "site/\(blogSlug)",
            localTutorialPath: tutorialPath,
            localSamplePath: samplePath,
            links: [
                FrameworkResourceLink(kind: .docs, url: docsURL),
                FrameworkResourceLink(kind: .blog, url: blogURL),
                FrameworkResourceLink(kind: .sample, url: sampleURL),
                FrameworkResourceLink(kind: .ai, url: aiURL)
            ]
        )
    }
}
