//
//  BluetoothManager.swift
//  BLEScanner
//
//  CoreBluetooth를 관리하는 중앙 매니저
//

import Foundation
import CoreBluetooth
import Combine

/// Bluetooth 스캔 및 연결을 관리하는 싱글톤 매니저
/// CBCentralManager를 래핑하여 SwiftUI와 연동
final class BluetoothManager: NSObject, ObservableObject {
    
    // MARK: - 싱글톤
    
    static let shared = BluetoothManager()
    
    // MARK: - Published 프로퍼티
    
    /// Bluetooth 상태
    @Published var state: CBManagerState = .unknown
    
    /// 스캔 중 여부
    @Published var isScanning = false
    
    /// 발견된 기기 목록
    @Published var discoveredDevices: [DiscoveredDevice] = []
    
    /// 현재 연결된 기기
    @Published var connectedDevice: DiscoveredDevice?
    
    /// 에러 메시지 (UI 표시용)
    @Published var errorMessage: String?
    
    // MARK: - 스캔 설정
    
    /// 스캔 시 중복 기기 허용 여부
    var allowDuplicates = false
    
    /// 스캔할 서비스 UUID 필터 (nil이면 모든 기기 스캔)
    var serviceUUIDFilter: [CBUUID]?
    
    /// 오래된 기기 자동 제거 시간 (초)
    var staleDeviceTimeout: TimeInterval = 30
    
    // MARK: - Private 프로퍼티
    
    /// CoreBluetooth Central Manager
    private var centralManager: CBCentralManager!
    
    /// 오래된 기기 정리 타이머
    private var cleanupTimer: Timer?
    
    /// Combine 구독 저장소
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 초기화
    
    private override init() {
        super.init()
        
        // CBCentralManager 초기화
        // queue: nil이면 메인 큐 사용
        // options: 상태 복원 지원
        centralManager = CBCentralManager(
            delegate: self,
            queue: nil,
            options: [
                CBCentralManagerOptionShowPowerAlertKey: true
            ]
        )
    }
    
    // MARK: - 스캔 제어
    
    /// BLE 기기 스캔 시작
    func startScanning() {
        // Bluetooth가 켜져있는지 확인
        guard state == .poweredOn else {
            errorMessage = "Bluetooth가 꺼져 있습니다"
            return
        }
        
        // 이미 스캔 중이면 무시
        guard !isScanning else { return }
        
        // 기존 목록 초기화
        discoveredDevices.removeAll()
        
        // 스캔 옵션 설정
        var options: [String: Any] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: allowDuplicates
        ]
        
        // 서비스 필터가 있으면 적용
        centralManager.scanForPeripherals(
            withServices: serviceUUIDFilter,
            options: options
        )
        
        isScanning = true
        errorMessage = nil
        
        // 오래된 기기 정리 타이머 시작
        startCleanupTimer()
        
        print("🔍 BLE 스캔 시작")
    }
    
    /// BLE 기기 스캔 중지
    func stopScanning() {
        guard isScanning else { return }
        
        centralManager.stopScan()
        isScanning = false
        
        // 정리 타이머 중지
        stopCleanupTimer()
        
        print("⏹️ BLE 스캔 중지")
    }
    
    /// 스캔 토글
    func toggleScanning() {
        if isScanning {
            stopScanning()
        } else {
            startScanning()
        }
    }
    
    // MARK: - 연결 관리
    
    /// 기기에 연결
    /// - Parameter device: 연결할 기기
    func connect(to device: DiscoveredDevice) {
        guard state == .poweredOn else {
            errorMessage = "Bluetooth가 꺼져 있습니다"
            return
        }
        
        // 이미 연결된 기기가 있으면 먼저 해제
        if let connected = connectedDevice {
            disconnect(from: connected)
        }
        
        device.connectionState = .connecting
        
        // 연결 타임아웃 옵션
        let options: [String: Any] = [
            CBConnectPeripheralOptionNotifyOnConnectionKey: true,
            CBConnectPeripheralOptionNotifyOnDisconnectionKey: true
        ]
        
        centralManager.connect(device.peripheral, options: options)
        
        print("📶 연결 시도: \(device.name)")
    }
    
    /// 기기 연결 해제
    /// - Parameter device: 연결 해제할 기기
    func disconnect(from device: DiscoveredDevice) {
        device.connectionState = .disconnecting
        centralManager.cancelPeripheralConnection(device.peripheral)
        
        print("📴 연결 해제: \(device.name)")
    }
    
    // MARK: - Private 메서드
    
    /// 오래된 기기 정리 타이머 시작
    private func startCleanupTimer() {
        stopCleanupTimer()
        
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.removeStaleDevices()
        }
    }
    
    /// 오래된 기기 정리 타이머 중지
    private func stopCleanupTimer() {
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }
    
    /// 오래된 기기 제거
    private func removeStaleDevices() {
        let now = Date()
        let threshold = now.addingTimeInterval(-staleDeviceTimeout)
        
        // 연결된 기기는 제거하지 않음
        discoveredDevices.removeAll { device in
            device.lastSeen < threshold && device.connectionState == .disconnected
        }
    }
    
    /// 발견된 기기 업데이트 또는 추가
    private func updateOrAddDevice(peripheral: CBPeripheral, rssi: Int, advertisementData: [String: Any]) {
        // 기존 기기인지 확인
        if let existingIndex = discoveredDevices.firstIndex(where: { $0.id == peripheral.identifier }) {
            // RSSI 업데이트
            discoveredDevices[existingIndex].updateRSSI(rssi)
        } else {
            // 새 기기 추가
            let newDevice = DiscoveredDevice(
                peripheral: peripheral,
                rssi: rssi,
                advertisementData: advertisementData
            )
            
            // 메인 스레드에서 업데이트
            DispatchQueue.main.async { [weak self] in
                self?.discoveredDevices.append(newDevice)
            }
        }
    }
    
    // MARK: - 상태 확인
    
    /// Bluetooth 상태 텍스트
    var stateDescription: String {
        switch state {
        case .unknown:
            return "알 수 없음"
        case .resetting:
            return "재설정 중"
        case .unsupported:
            return "지원되지 않음"
        case .unauthorized:
            return "권한 없음"
        case .poweredOff:
            return "꺼짐"
        case .poweredOn:
            return "켜짐"
        @unknown default:
            return "알 수 없음"
        }
    }
    
    /// Bluetooth 사용 가능 여부
    var isAvailable: Bool {
        state == .poweredOn
    }
}

// MARK: - CBCentralManagerDelegate

extension BluetoothManager: CBCentralManagerDelegate {
    
    /// Bluetooth 상태 변경 콜백
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        DispatchQueue.main.async { [weak self] in
            self?.state = central.state
        }
        
        print("📱 Bluetooth 상태: \(stateDescription)")
        
        // Bluetooth가 꺼지면 스캔 중지
        if central.state != .poweredOn {
            isScanning = false
            stopCleanupTimer()
        }
    }
    
    /// 기기 발견 콜백
    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        // 유효하지 않은 RSSI 무시 (127은 사용 불가 표시)
        guard RSSI.intValue != 127 else { return }
        
        updateOrAddDevice(
            peripheral: peripheral,
            rssi: RSSI.intValue,
            advertisementData: advertisementData
        )
    }
    
    /// 연결 성공 콜백
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("✅ 연결 성공: \(peripheral.name ?? "Unknown")")
        
        // 연결된 기기 찾기
        if let device = discoveredDevices.first(where: { $0.id == peripheral.identifier }) {
            DispatchQueue.main.async { [weak self] in
                device.connectionState = .connected
                self?.connectedDevice = device
            }
            
            // 서비스 검색 시작
            peripheral.delegate = DeviceConnection.shared
            peripheral.discoverServices(nil)
        }
    }
    
    /// 연결 실패 콜백
    func centralManager(
        _ central: CBCentralManager,
        didFailToConnect peripheral: CBPeripheral,
        error: Error?
    ) {
        print("❌ 연결 실패: \(peripheral.name ?? "Unknown")")
        
        if let device = discoveredDevices.first(where: { $0.id == peripheral.identifier }) {
            DispatchQueue.main.async {
                device.connectionState = .disconnected
            }
        }
        
        if let error = error {
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = "연결 실패: \(error.localizedDescription)"
            }
        }
    }
    
    /// 연결 해제 콜백
    func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        print("📴 연결 해제됨: \(peripheral.name ?? "Unknown")")
        
        if let device = discoveredDevices.first(where: { $0.id == peripheral.identifier }) {
            DispatchQueue.main.async {
                device.connectionState = .disconnected
                device.services = []
                device.characteristics = [:]
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            if self?.connectedDevice?.id == peripheral.identifier {
                self?.connectedDevice = nil
            }
        }
        
        if let error = error {
            print("⚠️ 연결 해제 에러: \(error.localizedDescription)")
        }
    }
}
