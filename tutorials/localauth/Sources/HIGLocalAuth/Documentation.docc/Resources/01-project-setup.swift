// Xcode에서 새 프로젝트 생성

// 1. File → New → Project
// 2. iOS → App 선택
// 3. 설정:
//    - Product Name: SecureVault
//    - Team: 개발자 계정 선택
//    - Organization Identifier: com.yourcompany
//    - Interface: SwiftUI
//    - Language: Swift
//    - Storage: None (또는 SwiftData)

// 4. 프로젝트 생성 후
//    - Signing & Capabilities 확인
//    - Bundle Identifier 확인

// 프로젝트 구조:
// SecureVault/
// ├── SecureVaultApp.swift      // 앱 진입점
// ├── ContentView.swift         // 메인 뷰
// ├── Views/                    // 뷰 파일들
// │   ├── LockScreenView.swift
// │   ├── VaultListView.swift
// │   └── VaultItemDetailView.swift
// ├── Models/                   // 데이터 모델
// │   └── VaultItem.swift
// ├── Services/                 // 서비스
// │   ├── AuthenticationManager.swift
// │   └── KeychainManager.swift
// └── Assets.xcassets           // 이미지, 색상
