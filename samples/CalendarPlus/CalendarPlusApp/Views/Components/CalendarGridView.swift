import SwiftUI

// MARK: - 월간 캘린더 그리드 뷰
/// 월간 달력을 표시하는 그리드 뷰
struct MonthCalendarGridView: View {
    @Binding var displayedMonth: Date
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    
    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    
    // 그리드 레이아웃
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    
    var body: some View {
        VStack(spacing: 8) {
            // 월 네비게이션
            monthNavigationHeader
            
            // 요일 헤더
            weekdayHeader
            
            // 날짜 그리드
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            isCurrentMonth: calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month),
                            eventCount: eventsCount(for: date)
                        )
                        .onTapGesture {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
            .padding(.horizontal, 8)
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < 0 {
                        // 왼쪽 스와이프 → 다음 달
                        navigateMonth(by: 1)
                    } else if value.translation.width > 0 {
                        // 오른쪽 스와이프 → 이전 달
                        navigateMonth(by: -1)
                    }
                }
        )
    }
    
    // MARK: - 월 네비게이션 헤더
    private var monthNavigationHeader: some View {
        HStack {
            Button {
                navigateMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .padding(8)
            }
            
            Spacer()
            
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    displayedMonth = Date()
                    selectedDate = Date()
                }
            } label: {
                Text("오늘")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Button {
                navigateMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .padding(8)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 요일 헤더
    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(adjustedWeekdaySymbols, id: \.self) { symbol in
                Text(symbol)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - 조정된 요일 심볼 (일요일 시작)
    private var adjustedWeekdaySymbols: [String] {
        // 한국은 일요일 시작이 일반적
        return weekdaySymbols
    }
    
    // MARK: - 월의 날짜들
    private var daysInMonth: [Date?] {
        var days: [Date?] = []
        
        // 월의 첫 날
        guard let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) else {
            return days
        }
        
        // 첫 날의 요일 (일요일 = 1)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // 이전 달의 빈 칸
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // 월의 일수
        guard let range = calendar.range(of: .day, in: .month, for: displayedMonth) else {
            return days
        }
        
        // 해당 월의 모든 날짜
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        // 다음 달의 빈 칸 (6주 채우기)
        while days.count < 42 {
            days.append(nil)
        }
        
        return days
    }
    
    // MARK: - 특정 날짜의 이벤트 수
    private func eventsCount(for date: Date) -> Int {
        events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date) ||
            calendar.isDate(event.endDate, inSameDayAs: date) ||
            (event.startDate < date && event.endDate > date)
        }.count
    }
    
    // MARK: - 월 이동
    private func navigateMonth(by value: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
                displayedMonth = newMonth
            }
        }
    }
}

// MARK: - 날짜 셀
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let eventCount: Int
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 2) {
            // 날짜 숫자
            Text("\(calendar.component(.day, from: date))")
                .font(.system(.body, design: .rounded))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundStyle(textColor)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .clipShape(Circle())
            
            // 이벤트 인디케이터
            HStack(spacing: 2) {
                ForEach(0..<min(eventCount, 3), id: \.self) { _ in
                    Circle()
                        .fill(isSelected ? .white.opacity(0.8) : .blue)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(height: 4)
        }
        .frame(height: 50)
    }
    
    // MARK: - 텍스트 색상
    private var textColor: Color {
        if isSelected {
            return .white
        } else if !isCurrentMonth {
            return .secondary.opacity(0.5)
        } else if isWeekend {
            return calendar.component(.weekday, from: date) == 1 ? .red : .blue
        }
        return .primary
    }
    
    // MARK: - 배경색
    private var backgroundColor: Color {
        if isSelected {
            return .blue
        } else if isToday {
            return .blue.opacity(0.15)
        }
        return .clear
    }
    
    // MARK: - 주말 여부
    private var isWeekend: Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }
}

// MARK: - 주간 캘린더 그리드 뷰
/// 주간 달력을 표시하는 그리드 뷰
struct WeekCalendarGridView: View {
    @Binding var displayedMonth: Date
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    
    private let calendar = Calendar.current
    private let hours = Array(0...23)
    
    var body: some View {
        VStack(spacing: 8) {
            // 주 네비게이션
            weekNavigationHeader
            
            // 주간 날짜 헤더
            weekDayHeader
            
            // 시간별 그리드
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(hours, id: \.self) { hour in
                        HourRowView(
                            hour: hour,
                            weekDates: currentWeekDates,
                            selectedDate: $selectedDate,
                            events: eventsForHour(hour)
                        )
                    }
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < 0 {
                        navigateWeek(by: 1)
                    } else if value.translation.width > 0 {
                        navigateWeek(by: -1)
                    }
                }
        )
    }
    
    // MARK: - 주 네비게이션 헤더
    private var weekNavigationHeader: some View {
        HStack {
            Button {
                navigateWeek(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .padding(8)
            }
            
            Spacer()
            
            Text(weekRangeText)
                .font(.headline)
            
            Spacer()
            
            Button {
                withAnimation {
                    selectedDate = Date()
                    displayedMonth = Date()
                }
            } label: {
                Text("오늘")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
            
            Button {
                navigateWeek(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .padding(8)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 주간 범위 텍스트
    private var weekRangeText: String {
        let dates = currentWeekDates
        guard let first = dates.first, let last = dates.last else { return "" }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M/d"
        
        return "\(formatter.string(from: first)) - \(formatter.string(from: last))"
    }
    
    // MARK: - 주간 날짜 헤더
    private var weekDayHeader: some View {
        HStack(spacing: 0) {
            // 시간 열 공간
            Text("")
                .frame(width: 50)
            
            ForEach(currentWeekDates, id: \.self) { date in
                VStack(spacing: 2) {
                    Text(weekdaySymbol(for: date))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(calendar.isDateInToday(date) ? .bold : .regular)
                        .foregroundStyle(calendar.isDate(date, inSameDayAs: selectedDate) ? .white : dayColor(for: date))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(calendar.isDate(date, inSameDayAs: selectedDate) ? .blue : .clear)
                        )
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .padding(.horizontal, 8)
    }
    
    // MARK: - 요일 심볼
    private func weekdaySymbol(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }
    
    // MARK: - 날짜 색상
    private func dayColor(for date: Date) -> Color {
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 1 { return .red }
        if weekday == 7 { return .blue }
        return .primary
    }
    
    // MARK: - 현재 주의 날짜들
    private var currentWeekDates: [Date] {
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate))!
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: startOfWeek)
        }
    }
    
    // MARK: - 특정 시간의 이벤트
    private func eventsForHour(_ hour: Int) -> [CalendarEvent] {
        events.filter { event in
            let eventHour = calendar.component(.hour, from: event.startDate)
            let eventDay = calendar.startOfDay(for: event.startDate)
            let selectedDay = calendar.startOfDay(for: selectedDate)
            
            // 선택된 주에 포함되고 해당 시간대의 이벤트
            return currentWeekDates.contains { calendar.isDate($0, inSameDayAs: eventDay) } &&
                   eventHour == hour
        }
    }
    
    // MARK: - 주 이동
    private func navigateWeek(by value: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let newDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) {
                selectedDate = newDate
                displayedMonth = newDate
            }
        }
    }
}

// MARK: - 시간 행 뷰
struct HourRowView: View {
    let hour: Int
    let weekDates: [Date]
    @Binding var selectedDate: Date
    let events: [CalendarEvent]
    
    private let calendar = Calendar.current
    
    var body: some View {
        HStack(spacing: 0) {
            // 시간 표시
            Text(hourText)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .trailing)
                .padding(.trailing, 4)
            
            // 각 요일 셀
            ForEach(weekDates, id: \.self) { date in
                WeekDayTimeCell(
                    date: date,
                    hour: hour,
                    events: eventsForDateAndHour(date: date),
                    isSelected: calendar.isDate(date, inSameDayAs: selectedDate)
                )
                .onTapGesture {
                    selectedDate = date
                }
            }
        }
        .frame(height: 50)
    }
    
    // MARK: - 시간 텍스트
    private var hourText: String {
        if hour == 0 {
            return "오전 12"
        } else if hour < 12 {
            return "오전 \(hour)"
        } else if hour == 12 {
            return "오후 12"
        } else {
            return "오후 \(hour - 12)"
        }
    }
    
    // MARK: - 특정 날짜/시간의 이벤트
    private func eventsForDateAndHour(date: Date) -> [CalendarEvent] {
        events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date) &&
            calendar.component(.hour, from: event.startDate) == hour
        }
    }
}

// MARK: - 주간 시간 셀
struct WeekDayTimeCell: View {
    let date: Date
    let hour: Int
    let events: [CalendarEvent]
    let isSelected: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            // 배경
            Rectangle()
                .fill(Color(.systemBackground))
                .border(Color(.separator).opacity(0.3), width: 0.5)
            
            // 이벤트 표시
            if let event = events.first {
                Text(event.title)
                    .font(.caption2)
                    .lineLimit(2)
                    .padding(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(cgColor: event.calendarColor ?? CGColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 1)).opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .padding(1)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 미리보기
#Preview("월간 뷰") {
    MonthCalendarGridView(
        displayedMonth: .constant(Date()),
        selectedDate: .constant(Date()),
        events: []
    )
}

#Preview("주간 뷰") {
    WeekCalendarGridView(
        displayedMonth: .constant(Date()),
        selectedDate: .constant(Date()),
        events: []
    )
}
