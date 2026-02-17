//
//  BLEScannerApp.swift
//  BLEScanner
//
//  BLE 스캐너 앱의 진입점
//

import SwiftUI

/// BLE Scanner 앱 진입점
@main
struct BLEScannerApp: App {
    
    // MARK: - State Objects
    
    /// Bluetooth 매니저 (앱 전체에서 공유)
    @StateObject private var bluetoothManager = BluetoothManager.shared
    
    /// 연결 관리자
    @StateObject private var deviceConnection = DeviceConnection.shared
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bluetoothManager)
                .environmentObject(deviceConnection)
        }
    }
}
