// AlarmManager.swift
// WakeUp - AlarmKit 샘플 프로젝트
// 알람 CRUD 및 시스템 연동 관리자

import Foundation
import AlarmKit
import Observation

// MARK: - 알람 관리자

/// AlarmKit과 연동하여 알람을 관리하는 클래스
/// @Observable 매크로를 사용하여 SwiftUI와 자동 연동
@Observable
@MainActor
public final class AlarmManager {
    
    // MARK: - 속성
    
    /// 현재 알람 목록
    public private(set) var alarms: [Alarm] = []
    
    /// 로딩 상태
    public private(set) var isLoading: Bool = false
    
    /// 오류 메시지
    public private(set) var errorMessage: String?
    
    /// AlarmKit 권한 상태
    public private(set) var authorizationStatus: AlarmKit.AuthorizationStatus = .notDetermined
    
    // MARK: - 저장 경로
    
    /// 알람 데이터 저장 파일 경로
    private var storageURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("alarms.json")
    }
    
    // MARK: - 초기화
    
    public init() {}
    
    // MARK: - 권한 관리
    
    /// AlarmKit 사용 권한 요청
    public func requestAuthorization() async {
        do {
            let status = try await AlarmKit.requestAuthorization()
            self.authorizationStatus = status
            
            if status == .denied {
                self.errorMessage = "알람 권한이 거부되었습니다. 설정에서 권한을 허용해주세요."
            }
        } catch {
            self.errorMessage = "권한 요청 실패: \(error.localizedDescription)"
            self.authorizationStatus = .denied
        }
    }
    
    /// 현재 권한 상태 확인
    public func checkAuthorizationStatus() async {
        self.authorizationStatus = await AlarmKit.authorizationStatus
    }
    
    // MARK: - CRUD 작업
    
    /// 저장된 알람 불러오기
    public func loadAlarms() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            alarms = try decoder.decode([Alarm].self, from: data)
            
            // AlarmKit과 동기화
            await syncWithAlarmKit()
        } catch {
            // 파일이 없으면 빈 배열로 시작
            alarms = []
        }
    }
    
    /// 알람 저장하기
    private func saveAlarms() async throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        let data = try encoder.encode(alarms)
        try data.write(to: storageURL)
    }
    
    /// 새 알람 추가
    public func addAlarm(_ alarm: Alarm) async {
        var newAlarm = alarm
        newAlarm.createdAt = .now
        newAlarm.modifiedAt = .now
        
        alarms.append(newAlarm)
        alarms.sort { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
        
        do {
            try await saveAlarms()
            
            // AlarmKit에 등록
            if newAlarm.isEnabled {
                try await scheduleAlarm(newAlarm)
            }
        } catch {
            errorMessage = "알람 저장 실패: \(error.localizedDescription)"
        }
    }
    
    /// 알람 수정
    public func updateAlarm(_ alarm: Alarm) async {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else {
            return
        }
        
        var updatedAlarm = alarm
        updatedAlarm.modifiedAt = .now
        
        // 기존 알람 취소
        await cancelAlarm(alarms[index])
        
        alarms[index] = updatedAlarm
        alarms.sort { ($0.hour, $0.minute) < ($1.hour, $1.minute) }
        
        do {
            try await saveAlarms()
            
            // 활성화된 경우 재등록
            if updatedAlarm.isEnabled {
                try await scheduleAlarm(updatedAlarm)
            }
        } catch {
            errorMessage = "알람 수정 실패: \(error.localizedDescription)"
        }
    }
    
    /// 알람 삭제
    public func deleteAlarm(_ alarm: Alarm) async {
        guard let index = alarms.firstIndex(where: { $0.id == alarm.id }) else {
            return
        }
        
        // AlarmKit에서 제거
        await cancelAlarm(alarm)
        
        alarms.remove(at: index)
        
        do {
            try await saveAlarms()
        } catch {
            errorMessage = "알람 삭제 실패: \(error.localizedDescription)"
        }
    }
    
    /// 여러 알람 삭제
    public func deleteAlarms(at offsets: IndexSet) async {
        let alarmsToDelete = offsets.map { alarms[$0] }
        
        for alarm in alarmsToDelete {
            await cancelAlarm(alarm)
        }
        
        alarms.remove(atOffsets: offsets)
        
        do {
            try await saveAlarms()
        } catch {
            errorMessage = "알람 삭제 실패: \(error.localizedDescription)"
        }
    }
    
    /// 알람 활성화/비활성화 토글
    public func toggleAlarm(_ alarm: Alarm) async {
        var updatedAlarm = alarm
        updatedAlarm.isEnabled.toggle()
        await updateAlarm(updatedAlarm)
    }
    
    // MARK: - AlarmKit 연동
    
    /// AlarmKit에 알람 등록
    private func scheduleAlarm(_ alarm: Alarm) async throws {
        let descriptor = alarm.toAlarmDescriptor()
        
        try await AlarmKit.schedule(
            descriptor,
            identifier: alarm.id.uuidString
        )
    }
    
    /// AlarmKit에서 알람 취소
    private func cancelAlarm(_ alarm: Alarm) async {
        do {
            try await AlarmKit.cancel(identifier: alarm.id.uuidString)
        } catch {
            // 이미 취소된 알람인 경우 무시
            print("알람 취소 실패: \(error.localizedDescription)")
        }
    }
    
    /// AlarmKit과 동기화
    private func syncWithAlarmKit() async {
        for alarm in alarms where alarm.isEnabled {
            do {
                try await scheduleAlarm(alarm)
            } catch {
                print("알람 동기화 실패 (\(alarm.label)): \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 유틸리티
    
    /// 다음에 울릴 알람 찾기
    public var nextAlarm: Alarm? {
        alarms
            .filter { $0.isEnabled }
            .compactMap { alarm -> (Alarm, Date)? in
                guard let date = alarm.nextTriggerDate else { return nil }
                return (alarm, date)
            }
            .min { $0.1 < $1.1 }
            .map { $0.0 }
    }
    
    /// 활성화된 알람 개수
    public var enabledAlarmCount: Int {
        alarms.filter { $0.isEnabled }.count
    }
    
    /// 오류 메시지 초기화
    public func clearError() {
        errorMessage = nil
    }
    
    /// 샘플 데이터 로드 (개발용)
    public func loadSampleData() async {
        alarms = Alarm.samples
        do {
            try await saveAlarms()
        } catch {
            print("샘플 데이터 저장 실패: \(error)")
        }
    }
}

// MARK: - AlarmKit 권한 상태 확장

extension AlarmKit.AuthorizationStatus {
    
    /// 권한 상태 표시 문자열
    public var displayText: String {
        switch self {
        case .notDetermined:
            return "권한 요청 필요"
        case .authorized:
            return "허용됨"
        case .denied:
            return "거부됨"
        case .provisional:
            return "임시 허용"
        @unknown default:
            return "알 수 없음"
        }
    }
    
    /// 권한 허용 여부
    public var isAuthorized: Bool {
        switch self {
        case .authorized, .provisional:
            return true
        default:
            return false
        }
    }
}
