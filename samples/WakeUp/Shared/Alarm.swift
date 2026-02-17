// Alarm.swift
// WakeUp - AlarmKit 샘플 프로젝트
// iOS 26+ AlarmKit을 활용한 시스템 알람 모델

import Foundation
import AlarmKit

// MARK: - 알람 모델
/// 사용자 알람 정보를 담는 구조체
/// AlarmKit의 AlarmDescriptor와 매핑됨
public struct Alarm: Identifiable, Codable, Sendable {
    
    // MARK: - 속성
    
    /// 고유 식별자
    public var id: UUID
    
    /// 알람 시간 (시, 분)
    public var hour: Int
    public var minute: Int
    
    /// 알람 레이블 (예: "기상", "운동")
    public var label: String
    
    /// 알람 활성화 여부
    public var isEnabled: Bool
    
    /// 반복 요일 설정
    public var repeatDays: WeekdaySet
    
    /// 스누즈 설정
    public var snoozeConfig: SnoozeConfiguration
    
    /// 알람 사운드
    public var sound: AlarmSound
    
    /// 생성 시각
    public var createdAt: Date
    
    /// 마지막 수정 시각
    public var modifiedAt: Date
    
    // MARK: - 초기화
    
    public init(
        id: UUID = UUID(),
        hour: Int = 7,
        minute: Int = 0,
        label: String = "알람",
        isEnabled: Bool = true,
        repeatDays: WeekdaySet = [],
        snoozeConfig: SnoozeConfiguration = .default,
        sound: AlarmSound = .sunrise,
        createdAt: Date = .now,
        modifiedAt: Date = .now
    ) {
        self.id = id
        self.hour = hour
        self.minute = minute
        self.label = label
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
        self.snoozeConfig = snoozeConfig
        self.sound = sound
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
    
    // MARK: - 계산 속성
    
    /// 포맷된 시간 문자열 (예: "07:30")
    public var formattedTime: String {
        String(format: "%02d:%02d", hour, minute)
    }
    
    /// 12시간제 포맷 시간 (예: "오전 7:30")
    public var formattedTime12Hour: String {
        let period = hour < 12 ? "오전" : "오후"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return "\(period) \(displayHour):\(String(format: "%02d", minute))"
    }
    
    /// 다음 알람 시각 계산
    public var nextTriggerDate: Date? {
        guard isEnabled else { return nil }
        
        let calendar = Calendar.current
        let now = Date.now
        
        // 오늘 날짜 기준 알람 시각 생성
        var components = calendar.dateComponents([.year, .month, .day], from: now)
        components.hour = hour
        components.minute = minute
        components.second = 0
        
        guard let todayAlarm = calendar.date(from: components) else {
            return nil
        }
        
        // 반복 알람이 없으면 다음 가능한 시각 반환
        if repeatDays.isEmpty {
            return todayAlarm > now ? todayAlarm : calendar.date(byAdding: .day, value: 1, to: todayAlarm)
        }
        
        // 반복 알람: 다음 해당 요일 찾기
        for dayOffset in 0..<7 {
            guard let candidateDate = calendar.date(byAdding: .day, value: dayOffset, to: todayAlarm) else {
                continue
            }
            
            let weekday = calendar.component(.weekday, from: candidateDate)
            guard let day = Weekday(calendarWeekday: weekday) else {
                continue
            }
            
            // 해당 요일이 반복 설정에 포함되어 있고, 현재 시각 이후인 경우
            if repeatDays.contains(day) && candidateDate > now {
                return candidateDate
            }
        }
        
        return nil
    }
    
    /// 다음 알람까지 남은 시간 문자열
    public var timeUntilNextTrigger: String? {
        guard let nextDate = nextTriggerDate else { return nil }
        
        let interval = nextDate.timeIntervalSince(.now)
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)시간 \(minutes)분 후"
        } else if minutes > 0 {
            return "\(minutes)분 후"
        } else {
            return "곧 울림"
        }
    }
    
    /// 반복 요일 요약 문자열
    public var repeatSummary: String {
        repeatDays.summary
    }
}

// MARK: - AlarmKit 변환

extension Alarm {
    
    /// AlarmKit의 AlarmDescriptor로 변환
    @available(iOS 26.0, *)
    public func toAlarmDescriptor() -> AlarmDescriptor {
        var descriptor = AlarmDescriptor(
            hour: hour,
            minute: minute
        )
        
        // 레이블 설정
        descriptor.label = label
        
        // 반복 요일 설정
        if !repeatDays.isEmpty {
            descriptor.recurrence = AlarmDescriptor.Recurrence(
                weekdays: repeatDays.toAlarmKitWeekdays()
            )
        }
        
        // 스누즈 설정
        descriptor.snooze = AlarmDescriptor.Snooze(
            isEnabled: snoozeConfig.isEnabled,
            duration: TimeInterval(snoozeConfig.durationMinutes * 60),
            maximumCount: snoozeConfig.maxCount
        )
        
        // 사운드 설정
        descriptor.sound = sound.toAlarmKitSound()
        
        return descriptor
    }
}

// MARK: - 샘플 데이터

extension Alarm {
    
    /// 미리보기용 샘플 알람
    public static let preview = Alarm(
        hour: 7,
        minute: 30,
        label: "기상 알람",
        isEnabled: true,
        repeatDays: [.monday, .tuesday, .wednesday, .thursday, .friday],
        sound: .sunrise
    )
    
    /// 샘플 알람 목록
    public static let samples: [Alarm] = [
        Alarm(
            hour: 6,
            minute: 30,
            label: "아침 운동",
            isEnabled: true,
            repeatDays: [.monday, .wednesday, .friday],
            sound: .energetic
        ),
        Alarm(
            hour: 7,
            minute: 0,
            label: "기상",
            isEnabled: true,
            repeatDays: .weekdays,
            sound: .sunrise
        ),
        Alarm(
            hour: 22,
            minute: 30,
            label: "취침 준비",
            isEnabled: false,
            repeatDays: .everyday,
            sound: .gentle
        ),
        Alarm(
            hour: 9,
            minute: 0,
            label: "주말 기상",
            isEnabled: true,
            repeatDays: .weekends,
            sound: .nature
        )
    ]
}
