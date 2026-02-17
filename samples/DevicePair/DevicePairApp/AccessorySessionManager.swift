//
//  AccessorySessionManager.swift
//  DevicePair
//
//  액세서리 세션 관리자 - ASAccessorySession을 래핑하여 페어링 기능 제공
//

import Foundation
import AccessorySetupKit
import Combine

// MARK: - 액세서리 세션 매니저

/// AccessorySetupKit의 ASAccessorySession을 관리하는 ObservableObject
/// 액세서리 검색, 페어링, 연결 해제 등 모든 기능을 중앙에서 관리
@MainActor
final class AccessorySessionManager: ObservableObject {
    
    // MARK: - Published 프로퍼티
    
    /// 현재 페어링 상태
    @Published private(set) var pairingState: PairingState = .idle
    
    /// 페어링된 액세서리 목록
    @Published private(set) var pairedAccessories: [Accessory] = []
    
    /// 검색 중 발견된 액세서리 목록
    @Published private(set) var discoveredAccessories: [DiscoveredAccessory] = []
    
    /// 세션 활성화 여부
    @Published private(set) var isSessionActive: Bool = false
    
    /// 블루투스 사용 가능 여부
    @Published private(set) var isBluetoothAvailable: Bool = true
    
    /// 현재 선택된 액세서리
    @Published var selectedAccessory: Accessory?
    
    /// 에러 메시지 (알림용)
    @Published var errorMessage: String?
    
    /// 성공 메시지 (알림용)
    @Published var successMessage: String?
    
    // MARK: - Private 프로퍼티
    
    /// AccessorySetupKit 세션
    private var session: ASAccessorySession?
    
    /// 이벤트 스트림 태스크
    private var eventTask: Task<Void, Never>?
    
    /// 검색 타이머
    private var discoveryTimer: Timer?
    
    /// 검색 타임아웃 (초)
    private let discoveryTimeout: TimeInterval = 30
    
    // MARK: - 초기화
    
    init() {
        setupSession()
        loadSavedAccessories()
    }
    
    deinit {
        eventTask?.cancel()
        discoveryTimer?.invalidate()
    }
    
    // MARK: - 세션 설정
    
    /// ASAccessorySession 초기화 및 이벤트 스트림 설정
    private func setupSession() {
        session = ASAccessorySession()
        
        // 이벤트 스트림 처리
        eventTask = Task { [weak self] in
            guard let self = self,
                  let session = self.session else { return }
            
            for await event in session.eventStream {
                await self.handleSessionEvent(event)
            }
        }
        
        isSessionActive = true
    }
    
    /// 세션 이벤트 처리
    private func handleSessionEvent(_ event: ASAccessoryEvent) async {
        switch event.eventType {
        case .accessoryAdded:
            // 새 액세서리가 추가됨
            if let accessory = event.accessory {
                await handleAccessoryAdded(accessory)
            }
            
        case .accessoryRemoved:
            // 액세서리가 제거됨
            if let accessory = event.accessory {
                await handleAccessoryRemoved(accessory)
            }
            
        case .accessoryChanged:
            // 액세서리 상태 변경
            if let accessory = event.accessory {
                await handleAccessoryChanged(accessory)
            }
            
        case .activated:
            // 세션 활성화됨
            isSessionActive = true
            
        case .invalidated:
            // 세션 무효화됨
            isSessionActive = false
            
        case .migrationComplete:
            // 마이그레이션 완료
            break
            
        case .pickerDidDismiss:
            // 피커 닫힘
            if pairingState == .discovering {
                pairingState = .idle
            }
            
        @unknown default:
            break
        }
    }
    
    // MARK: - 액세서리 검색
    
    /// 액세서리 검색 시작
    func startDiscovery() {
        guard pairingState == .idle || pairingState.isTerminal else {
            errorMessage = "이미 검색 중이거나 페어링이 진행 중입니다"
            return
        }
        
        pairingState = .discovering
        discoveredAccessories = []
        
        // 시스템 피커 표시
        showAccessoryPicker()
        
        // 검색 타임아웃 설정
        discoveryTimer?.invalidate()
        discoveryTimer = Timer.scheduledTimer(withTimeInterval: discoveryTimeout, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.handleDiscoveryTimeout()
            }
        }
    }
    
    /// 액세서리 검색 중지
    func stopDiscovery() {
        discoveryTimer?.invalidate()
        discoveryTimer = nil
        
        if pairingState == .discovering {
            pairingState = .cancelled
            
            // 잠시 후 idle 상태로 복귀
            Task {
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                if pairingState == .cancelled {
                    pairingState = .idle
                }
            }
        }
    }
    
    /// 시스템 액세서리 피커 표시
    private func showAccessoryPicker() {
        // AccessorySetupKit 피커 디스크립터 생성
        // 실제 구현에서는 제조사의 액세서리 정보 파일(.accessory) 사용
        let descriptor = ASPickerDisplayItem(
            name: "스마트 액세서리",
            productImage: UIImage(systemName: "airplayaudio") ?? UIImage(),
            descriptor: ASDiscoveryDescriptor()
        )
        
        session?.showPicker(for: [descriptor]) { [weak self] error in
            Task { @MainActor [weak self] in
                if let error = error {
                    self?.handlePickerError(error)
                }
            }
        }
    }
    
    /// 검색 타임아웃 처리
    private func handleDiscoveryTimeout() {
        if pairingState == .discovering && discoveredAccessories.isEmpty {
            pairingState = .failed(error: .accessoryNotFound)
        } else if !discoveredAccessories.isEmpty {
            pairingState = .discovered(count: discoveredAccessories.count)
        }
        discoveryTimer?.invalidate()
    }
    
    /// 피커 에러 처리
    private func handlePickerError(_ error: Error) {
        let pairingError: PairingError
        
        // ASAccessoryError 타입 체크
        if let accessoryError = error as? ASAccessorySession.PickerError {
            switch accessoryError {
            default:
                pairingError = .unknown(message: error.localizedDescription)
            }
        } else {
            pairingError = .unknown(message: error.localizedDescription)
        }
        
        pairingState = .failed(error: pairingError)
        errorMessage = pairingError.localizedDescription
    }
    
    // MARK: - 페어링
    
    /// 발견된 액세서리와 페어링 시작
    func pairAccessory(_ discovered: DiscoveredAccessory) {
        guard pairingState == .discovered(count: discoveredAccessories.count) else {
            return
        }
        
        pairingState = .pairing(accessoryName: discovered.name)
        
        // 페어링 프로세스 시뮬레이션
        // 실제 구현에서는 ASAccessorySession의 페어링 API 사용
        Task {
            // 인증 단계
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            pairingState = .authenticating
            
            // 설정 단계
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            pairingState = .configuring
            
            // 완료
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // 새 액세서리 생성 및 추가
            let newAccessory = Accessory(
                name: discovered.name,
                category: discovered.category,
                connectionState: .connected,
                lastConnected: Date(),
                manufacturer: "Unknown",
                modelNumber: "N/A"
            )
            
            await addPairedAccessory(newAccessory)
            pairingState = .completed(accessoryName: discovered.name)
            successMessage = "'\(discovered.name)'이(가) 성공적으로 페어링되었습니다"
            
            // 발견 목록에서 제거
            discoveredAccessories.removeAll { $0.id == discovered.id }
        }
    }
    
    /// 페어링 재시도
    func retryPairing() {
        pairingState = .idle
        startDiscovery()
    }
    
    /// 페어링 상태 초기화
    func resetPairingState() {
        pairingState = .idle
        discoveredAccessories = []
        errorMessage = nil
        successMessage = nil
    }
    
    // MARK: - 액세서리 관리
    
    /// 페어링된 액세서리 추가
    private func addPairedAccessory(_ accessory: Accessory) async {
        guard !pairedAccessories.contains(where: { $0.id == accessory.id }) else {
            return
        }
        
        pairedAccessories.append(accessory)
        saveAccessories()
    }
    
    /// 액세서리 연결 해제
    func disconnectAccessory(_ accessory: Accessory) {
        guard let index = pairedAccessories.firstIndex(where: { $0.id == accessory.id }) else {
            return
        }
        
        var updated = pairedAccessories[index]
        updated.connectionState = .disconnected
        pairedAccessories[index] = updated
        
        saveAccessories()
    }
    
    /// 액세서리 다시 연결
    func reconnectAccessory(_ accessory: Accessory) {
        guard let index = pairedAccessories.firstIndex(where: { $0.id == accessory.id }) else {
            return
        }
        
        var updated = pairedAccessories[index]
        updated.connectionState = .connecting
        pairedAccessories[index] = updated
        
        // 연결 시뮬레이션
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            if let idx = pairedAccessories.firstIndex(where: { $0.id == accessory.id }) {
                var reconnected = pairedAccessories[idx]
                reconnected.connectionState = .connected
                reconnected.lastConnected = Date()
                pairedAccessories[idx] = reconnected
                saveAccessories()
            }
        }
    }
    
    /// 액세서리 페어링 해제 (완전 제거)
    func unpairAccessory(_ accessory: Accessory) {
        pairedAccessories.removeAll { $0.id == accessory.id }
        
        if selectedAccessory?.id == accessory.id {
            selectedAccessory = nil
        }
        
        saveAccessories()
        successMessage = "'\(accessory.name)' 페어링이 해제되었습니다"
    }
    
    /// 액세서리 이름 변경
    func renameAccessory(_ accessory: Accessory, to newName: String) {
        guard let index = pairedAccessories.firstIndex(where: { $0.id == accessory.id }) else {
            return
        }
        
        var updated = pairedAccessories[index]
        updated.name = newName
        pairedAccessories[index] = updated
        
        saveAccessories()
    }
    
    /// 액세서리 설정 업데이트
    func updateAccessorySettings(_ accessory: Accessory, settings: AccessorySettings) {
        guard let index = pairedAccessories.firstIndex(where: { $0.id == accessory.id }) else {
            return
        }
        
        var updated = pairedAccessories[index]
        updated.settings = settings
        pairedAccessories[index] = updated
        
        saveAccessories()
    }
    
    // MARK: - 이벤트 핸들러
    
    /// 새 액세서리 추가됨 이벤트 처리
    private func handleAccessoryAdded(_ asAccessory: ASAccessory) async {
        let accessory = Accessory(
            name: asAccessory.displayName,
            category: .other,
            connectionState: .connected,
            lastConnected: Date(),
            manufacturer: "Unknown",
            modelNumber: "Unknown"
        )
        
        await addPairedAccessory(accessory)
    }
    
    /// 액세서리 제거됨 이벤트 처리
    private func handleAccessoryRemoved(_ asAccessory: ASAccessory) async {
        pairedAccessories.removeAll { $0.name == asAccessory.displayName }
        saveAccessories()
    }
    
    /// 액세서리 상태 변경 이벤트 처리
    private func handleAccessoryChanged(_ asAccessory: ASAccessory) async {
        // 상태 변경 처리
        // 실제 구현에서는 ASAccessory의 상태에 따라 업데이트
    }
    
    // MARK: - 영속성
    
    /// 저장된 액세서리 불러오기
    private func loadSavedAccessories() {
        // 실제 구현에서는 UserDefaults 또는 Core Data에서 로드
        // 데모용으로 샘플 데이터 로드
        #if DEBUG
        pairedAccessories = Accessory.sampleAccessories
        #endif
    }
    
    /// 액세서리 목록 저장
    private func saveAccessories() {
        // 실제 구현에서는 UserDefaults 또는 Core Data에 저장
    }
    
    // MARK: - 유틸리티
    
    /// 카테고리별 액세서리 필터링
    func accessories(for category: AccessoryCategory) -> [Accessory] {
        pairedAccessories.filter { $0.category == category }
    }
    
    /// 연결 상태별 액세서리 필터링
    func accessories(withState state: ConnectionState) -> [Accessory] {
        pairedAccessories.filter { $0.connectionState == state }
    }
    
    /// 연결된 액세서리 개수
    var connectedCount: Int {
        pairedAccessories.filter { $0.connectionState == .connected }.count
    }
}
