import Foundation

// 에러별 복구 전략
class ErrorRecoveryManager {
    typealias RecoveryAction = () async throws -> Void
    
    struct RecoveryOption {
        let title: String
        let action: RecoveryAction
    }
    
    // 에러에 대한 복구 옵션 제공
    func recoveryOptions(for error: AccessorySetupError) -> [RecoveryOption] {
        switch error {
        case .sessionNotActivated, .sessionActivationFailed:
            return [
                RecoveryOption(title: "다시 시도") { [weak self] in
                    try await self?.reactivateSession()
                }
            ]
            
        case .pickerCancelled:
            return [] // 사용자 의도적 취소, 복구 불필요
            
        case .bluetoothUnavailable:
            return [
                RecoveryOption(title: "설정 열기") { [weak self] in
                    await self?.openSettings()
                }
            ]
            
        case .connectionLost:
            return [
                RecoveryOption(title: "재연결") { [weak self] in
                    try await self?.attemptReconnect()
                },
                RecoveryOption(title: "기기 재페어링") { [weak self] in
                    try await self?.repairDevice()
                }
            ]
            
        case .pairingFailed(let reason):
            return recoveryForPairingFailure(reason)
            
        default:
            return [
                RecoveryOption(title: "다시 시도") { [weak self] in
                    try await self?.retryLastAction()
                }
            ]
        }
    }
    
    private func recoveryForPairingFailure(_ reason: PairingFailureReason) -> [RecoveryOption] {
        switch reason {
        case .timeout:
            return [
                RecoveryOption(title: "다시 검색") { [weak self] in
                    try await self?.restartDiscovery()
                }
            ]
        case .deviceNotFound:
            return [
                RecoveryOption(title: "기기 전원 확인") { /* 안내 표시 */ },
                RecoveryOption(title: "다시 검색") { [weak self] in
                    try await self?.restartDiscovery()
                }
            ]
        case .userDenied:
            return [] // 사용자 의도
        case .incompatible:
            return [
                RecoveryOption(title: "지원 기기 확인") { /* 도움말 표시 */ }
            ]
        }
    }
    
    // 복구 액션들
    private func reactivateSession() async throws { }
    private func openSettings() async { }
    private func attemptReconnect() async throws { }
    private func repairDevice() async throws { }
    private func retryLastAction() async throws { }
    private func restartDiscovery() async throws { }
}
