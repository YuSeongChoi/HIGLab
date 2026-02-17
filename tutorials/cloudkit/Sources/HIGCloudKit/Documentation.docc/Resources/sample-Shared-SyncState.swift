// SyncState.swift
// CloudNotes - 동기화 상태 관리
//
// CloudKit 동기화 상태를 표현하는 열거형입니다.

import Foundation
import SwiftUI

// MARK: - SyncState

/// CloudKit 동기화 상태를 나타내는 열거형
enum SyncState: Equatable {
    /// 대기 상태 (초기 상태)
    case idle
    
    /// 동기화 진행 중
    case syncing(message: String)
    
    /// 동기화 완료
    case synced
    
    /// 오류 발생
    case error(Error)
    
    /// 오프라인 상태
    case offline
    
    // MARK: - Equatable
    
    static func == (lhs: SyncState, rhs: SyncState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.syncing(let lhsMessage), .syncing(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.synced, .synced):
            return true
        case (.error, .error):
            // 에러는 메시지로 비교 (Error 자체는 Equatable이 아님)
            return true
        case (.offline, .offline):
            return true
        default:
            return false
        }
    }
}

// MARK: - UI 헬퍼

extension SyncState {
    
    /// 상태에 따른 시스템 이미지 이름
    var iconName: String {
        switch self {
        case .idle:
            return "cloud"
        case .syncing:
            return "arrow.triangle.2.circlepath"
        case .synced:
            return "checkmark.icloud"
        case .error:
            return "exclamationmark.icloud"
        case .offline:
            return "icloud.slash"
        }
    }
    
    /// 상태에 따른 색상
    var color: Color {
        switch self {
        case .idle:
            return .secondary
        case .syncing:
            return .blue
        case .synced:
            return .green
        case .error:
            return .red
        case .offline:
            return .orange
        }
    }
    
    /// 상태 설명 텍스트
    var description: String {
        switch self {
        case .idle:
            return "대기 중"
        case .syncing(let message):
            return message
        case .synced:
            return "동기화 완료"
        case .error(let error):
            return "오류: \(error.localizedDescription)"
        case .offline:
            return "오프라인"
        }
    }
    
    /// 동기화 중인지 여부
    var isSyncing: Bool {
        if case .syncing = self {
            return true
        }
        return false
    }
    
    /// 오류 상태인지 여부
    var hasError: Bool {
        if case .error = self {
            return true
        }
        return false
    }
}

// MARK: - 네트워크 상태 모니터

import Network

/// 네트워크 연결 상태를 모니터링하는 클래스
@MainActor
final class NetworkMonitor: ObservableObject {
    
    /// 싱글톤 인스턴스
    static let shared = NetworkMonitor()
    
    /// 네트워크 연결 여부
    @Published private(set) var isConnected = true
    
    /// 연결 타입 (Wi-Fi, 셀룰러 등)
    @Published private(set) var connectionType: NWInterface.InterfaceType?
    
    /// 네트워크 모니터
    private let monitor = NWPathMonitor()
    
    /// 모니터링 큐
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    private init() {
        startMonitoring()
    }
    
    /// 모니터링 시작
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        monitor.start(queue: queue)
    }
    
    /// 모니터링 중지
    func stopMonitoring() {
        monitor.cancel()
    }
}

// MARK: - 동기화 충돌 해결

/// 동기화 충돌 해결 전략
enum ConflictResolution {
    /// 서버 데이터 우선
    case serverWins
    
    /// 클라이언트 데이터 우선
    case clientWins
    
    /// 병합 (가능한 경우)
    case merge
    
    /// 사용자에게 선택 요청
    case askUser
}

/// 충돌 정보
struct SyncConflict {
    /// 충돌이 발생한 노트 ID
    let noteID: String
    
    /// 로컬 버전
    let localNote: Note
    
    /// 서버 버전
    let serverNote: Note
    
    /// 충돌 발생 시간
    let detectedAt: Date
}
