// DateTimeTool.swift
// 날짜/시간 도구
// iOS 26+ | FoundationModels
//
// 현재 날짜, 시간, 타임존, 날짜 계산 등을 제공하는 도구

import Foundation
import FoundationModels

// MARK: - 날짜/시간 도구

/// 날짜와 시간 관련 기능을 제공하는 도구
@Generable
struct DateTimeTool: Tool {
    
    // MARK: - Tool 프로토콜 구현
    
    static let name = "datetime"
    
    static let description = """
        현재 날짜, 시간, 요일 등의 정보를 제공합니다.
        날짜 계산, 시간대 변환, D-day 계산 등을 수행할 수 있습니다.
        """
    
    struct Arguments: Codable, Sendable {
        /// 작업 종류 (now, calculate, convert, dday)
        @Guide(description: "수행할 작업: now(현재 시간), calculate(날짜 계산), convert(시간대 변환), dday(D-day)")
        let action: String
        
        /// 대상 날짜 (YYYY-MM-DD 형식)
        @Guide(description: "대상 날짜 (YYYY-MM-DD 형식)")
        let date: String?
        
        /// 추가/감소할 일수
        @Guide(description: "추가하거나 빼낼 일수 (음수 가능)")
        let days: Int?
        
        /// 대상 시간대
        @Guide(description: "대상 시간대 (예: Asia/Tokyo, America/New_York)")
        let timezone: String?
        
        /// 출력 형식
        @Guide(description: "출력 형식 (예: yyyy-MM-dd HH:mm:ss)")
        let format: String?
    }
    
    func call(arguments: Arguments) async throws -> String {
        let action = arguments.action.lowercased()
        
        switch action {
        case "now":
            return formatCurrentDateTime(
                timezone: arguments.timezone,
                format: arguments.format
            )
            
        case "calculate":
            return calculateDate(
                from: arguments.date,
                addDays: arguments.days ?? 0,
                format: arguments.format
            )
            
        case "convert":
            return convertTimezone(
                date: arguments.date,
                to: arguments.timezone ?? "UTC",
                format: arguments.format
            )
            
        case "dday":
            return calculateDDay(
                targetDate: arguments.date ?? "",
                format: arguments.format
            )
            
        default:
            // 기본: 현재 시간 반환
            return formatCurrentDateTime(
                timezone: arguments.timezone,
                format: arguments.format
            )
        }
    }
}

// MARK: - 현재 시간

extension DateTimeTool {
    
    /// 현재 날짜/시간 포맷팅
    func formatCurrentDateTime(
        timezone: String? = nil,
        format: String? = nil
    ) -> String {
        let now = Date()
        let calendar = Calendar.current
        
        // 타임존 설정
        var targetTimezone = TimeZone.current
        if let tzName = timezone,
           let tz = TimeZone(identifier: tzName) {
            targetTimezone = tz
        }
        
        // 기본 정보
        var cal = Calendar.current
        cal.timeZone = targetTimezone
        
        let components = cal.dateComponents(
            [.year, .month, .day, .weekday, .hour, .minute, .second],
            from: now
        )
        
        // 요일 이름
        let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
        let weekday = weekdaySymbols[(components.weekday ?? 1) - 1]
        
        // 포맷된 날짜/시간
        let formatter = DateFormatter()
        formatter.timeZone = targetTimezone
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format ?? "yyyy년 M월 d일 (E) HH:mm:ss"
        let formatted = formatter.string(from: now)
        
        // 추가 정보
        let dayOfYear = cal.ordinality(of: .day, in: .year, for: now) ?? 0
        let weekOfYear = cal.component(.weekOfYear, from: now)
        let isLeapYear = cal.isDateInLeapYear(now)
        
        // AM/PM
        let isPM = (components.hour ?? 0) >= 12
        let hour12 = ((components.hour ?? 0) - 1) % 12 + 1
        
        return """
            📅 현재 날짜 및 시간
            
            🗓️ \(formatted)
            📍 시간대: \(targetTimezone.identifier)
            
            📊 상세 정보:
            • 연도: \(components.year ?? 0)년
            • 월: \(components.month ?? 0)월
            • 일: \(components.day ?? 0)일
            • 요일: \(weekday)요일
            • 시간: \(hour12)시 \(components.minute ?? 0)분 \(components.second ?? 0)초 \(isPM ? "오후" : "오전")
            
            📈 추가 정보:
            • 올해 \(dayOfYear)번째 날
            • 올해 \(weekOfYear)번째 주
            • 윤년: \(isLeapYear ? "예" : "아니오")
            """
    }
    
    /// 간단한 현재 시간 (레거시 인터페이스)
    func getCurrentDateTime(format: String? = nil) -> String {
        formatCurrentDateTime(format: format)
    }
}

// MARK: - 날짜 계산

extension DateTimeTool {
    
    /// 날짜 계산
    func calculateDate(
        from dateString: String?,
        addDays: Int,
        format: String? = nil
    ) -> String {
        let calendar = Calendar.current
        
        // 시작 날짜 파싱
        let startDate: Date
        if let ds = dateString {
            let parser = DateFormatter()
            parser.dateFormat = "yyyy-MM-dd"
            if let parsed = parser.date(from: ds) {
                startDate = parsed
            } else {
                return "❌ 날짜 형식이 올바르지 않습니다. YYYY-MM-DD 형식으로 입력해주세요."
            }
        } else {
            startDate = Date()
        }
        
        // 날짜 계산
        guard let resultDate = calendar.date(byAdding: .day, value: addDays, to: startDate) else {
            return "❌ 날짜 계산에 실패했습니다."
        }
        
        // 포맷팅
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format ?? "yyyy년 M월 d일 (E)"
        
        let startFormatted = formatter.string(from: startDate)
        let resultFormatted = formatter.string(from: resultDate)
        
        // 결과 메시지
        let operation = addDays >= 0 ? "후" : "전"
        let absdays = abs(addDays)
        
        return """
            📅 날짜 계산 결과
            
            시작 날짜: \(startFormatted)
            계산: \(absdays)일 \(operation)
            
            ➡️ 결과: \(resultFormatted)
            """
    }
}

// MARK: - 시간대 변환

extension DateTimeTool {
    
    /// 시간대 변환
    func convertTimezone(
        date: String?,
        to targetTimezone: String,
        format: String? = nil
    ) -> String {
        // 대상 시간대 확인
        guard let toTZ = TimeZone(identifier: targetTimezone) else {
            return """
                ❌ 유효하지 않은 시간대입니다: \(targetTimezone)
                
                사용 가능한 시간대 예시:
                • Asia/Seoul (한국)
                • Asia/Tokyo (일본)
                • America/New_York (미국 동부)
                • America/Los_Angeles (미국 서부)
                • Europe/London (영국)
                • Europe/Paris (프랑스)
                • UTC
                """
        }
        
        // 변환할 날짜
        let sourceDate: Date
        if let ds = date {
            let parser = DateFormatter()
            parser.dateFormat = "yyyy-MM-dd HH:mm:ss"
            parser.timeZone = TimeZone.current
            if let parsed = parser.date(from: ds) {
                sourceDate = parsed
            } else {
                parser.dateFormat = "yyyy-MM-dd"
                if let parsed = parser.date(from: ds) {
                    sourceDate = parsed
                } else {
                    return "❌ 날짜 형식이 올바르지 않습니다."
                }
            }
        } else {
            sourceDate = Date()
        }
        
        // 포맷팅
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format ?? "yyyy년 M월 d일 (E) HH:mm:ss"
        
        // 현재 시간대
        formatter.timeZone = TimeZone.current
        let sourceFormatted = formatter.string(from: sourceDate)
        
        // 대상 시간대
        formatter.timeZone = toTZ
        let targetFormatted = formatter.string(from: sourceDate)
        
        // 시차 계산
        let sourceOffset = TimeZone.current.secondsFromGMT(for: sourceDate)
        let targetOffset = toTZ.secondsFromGMT(for: sourceDate)
        let diffHours = Double(targetOffset - sourceOffset) / 3600
        let diffString = diffHours >= 0 ? "+\(diffHours)시간" : "\(diffHours)시간"
        
        return """
            🌍 시간대 변환 결과
            
            📍 \(TimeZone.current.identifier)
            🕐 \(sourceFormatted)
            
            ⬇️ 변환 (\(diffString))
            
            📍 \(targetTimezone)
            🕐 \(targetFormatted)
            """
    }
}

// MARK: - D-Day 계산

extension DateTimeTool {
    
    /// D-Day 계산
    func calculateDDay(
        targetDate: String,
        format: String? = nil
    ) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 대상 날짜 파싱
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        
        guard let target = parser.date(from: targetDate) else {
            return "❌ 날짜 형식이 올바르지 않습니다. YYYY-MM-DD 형식으로 입력해주세요."
        }
        
        let targetStart = calendar.startOfDay(for: target)
        
        // 일수 차이 계산
        let components = calendar.dateComponents([.day], from: today, to: targetStart)
        guard let dayDiff = components.day else {
            return "❌ 날짜 계산에 실패했습니다."
        }
        
        // 포맷팅
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format ?? "yyyy년 M월 d일 (E)"
        let targetFormatted = formatter.string(from: target)
        
        // 결과 메시지
        let dDayString: String
        let emoji: String
        
        if dayDiff > 0 {
            dDayString = "D-\(dayDiff)"
            emoji = "⏳"
        } else if dayDiff < 0 {
            dDayString = "D+\(abs(dayDiff))"
            emoji = "✅"
        } else {
            dDayString = "D-Day"
            emoji = "🎉"
        }
        
        // 주/월 단위 표시
        let weeks = abs(dayDiff) / 7
        let remainingDays = abs(dayDiff) % 7
        
        var timeBreakdown = ""
        if abs(dayDiff) >= 7 {
            timeBreakdown = "\n• \(weeks)주 \(remainingDays)일"
        }
        
        return """
            \(emoji) D-Day 계산 결과
            
            📅 목표 날짜: \(targetFormatted)
            📅 오늘: \(formatter.string(from: today))
            
            🎯 결과: \(dDayString)\(timeBreakdown)
            """
    }
}

// MARK: - 유틸리티

extension DateTimeTool {
    
    /// 월의 마지막 날 구하기
    func lastDayOfMonth(year: Int, month: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month + 1
        components.day = 0
        
        let calendar = Calendar.current
        if let date = calendar.date(from: components) {
            return calendar.component(.day, from: date)
        }
        return 30
    }
    
    /// 특정 날짜가 주말인지 확인
    func isWeekend(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // 일요일(1) 또는 토요일(7)
    }
    
    /// 두 날짜 사이의 영업일 계산
    func businessDaysBetween(start: Date, end: Date) -> Int {
        let calendar = Calendar.current
        var count = 0
        var current = start
        
        while current <= end {
            if !isWeekend(current) {
                count += 1
            }
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        
        return count
    }
    
    /// 다음 영업일 구하기
    func nextBusinessDay(from date: Date) -> Date {
        let calendar = Calendar.current
        var next = calendar.date(byAdding: .day, value: 1, to: date)!
        
        while isWeekend(next) {
            next = calendar.date(byAdding: .day, value: 1, to: next)!
        }
        
        return next
    }
}

// MARK: - 윤년 체크

extension Calendar {
    
    /// 날짜가 윤년에 속하는지 확인
    func isDateInLeapYear(_ date: Date) -> Bool {
        let year = component(.year, from: date)
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
}
