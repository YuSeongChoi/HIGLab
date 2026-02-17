import SwiftUI
import EventKit

// MARK: - 캘린더 뷰 모드
enum CalendarViewMode: String, CaseIterable {
    case month = "월"
    case week = "주"
    
    var symbolName: String {
        switch self {
        case .month: return "calendar"
        case .week: return "calendar.day.timeline.left"
        }
    }
}

// MARK: - 캘린더 뷰
/// 월간/주간 캘린더와 이벤트 목록을 표시하는 뷰
struct CalendarView: View {
    @EnvironmentObject var eventKitManager: EventKitManager
    
    @State private var viewMode: CalendarViewMode = .month
    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Date()
    @State private var showingEventDetail = false
    @State private var selectedEvent: CalendarEvent?
    @State private var showingNewEvent = false
    @State private var showingCalendarPicker = false
    @State private var selectedCalendarIds: Set<String> = []
    
    private let calendar = Calendar.current
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 뷰 모드 선택
                viewModePicker
                
                // 캘린더 그리드
                calendarSection
                
                Divider()
                
                // 선택된 날짜의 이벤트 목록
                eventListSection
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingCalendarPicker = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        selectedEvent = nil
                        showingNewEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewEvent) {
                EventDetailView(
                    event: nil,
                    selectedDate: selectedDate,
                    onSave: { _ in
                        Task {
                            await loadEventsForCurrentPeriod()
                        }
                    }
                )
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(
                    event: event,
                    selectedDate: selectedDate,
                    onSave: { _ in
                        Task {
                            await loadEventsForCurrentPeriod()
                        }
                    }
                )
            }
            .sheet(isPresented: $showingCalendarPicker) {
                CalendarPickerView(selectedCalendarIds: $selectedCalendarIds)
            }
            .task {
                // 초기 캘린더 선택 (모든 캘린더)
                if selectedCalendarIds.isEmpty {
                    selectedCalendarIds = Set(eventKitManager.calendars.map { $0.id })
                }
                await loadEventsForCurrentPeriod()
            }
            .onChange(of: displayedMonth) {
                Task {
                    await loadEventsForCurrentPeriod()
                }
            }
            .onChange(of: selectedCalendarIds) {
                Task {
                    await loadEventsForCurrentPeriod()
                }
            }
        }
    }
    
    // MARK: - 네비게이션 타이틀
    private var navigationTitle: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"
        return formatter.string(from: displayedMonth)
    }
    
    // MARK: - 뷰 모드 선택기
    private var viewModePicker: some View {
        Picker("뷰 모드", selection: $viewMode) {
            ForEach(CalendarViewMode.allCases, id: \.self) { mode in
                Label(mode.rawValue, systemImage: mode.symbolName)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - 캘린더 섹션
    @ViewBuilder
    private var calendarSection: some View {
        switch viewMode {
        case .month:
            MonthCalendarGridView(
                displayedMonth: $displayedMonth,
                selectedDate: $selectedDate,
                events: eventKitManager.events
            )
        case .week:
            WeekCalendarGridView(
                displayedMonth: $displayedMonth,
                selectedDate: $selectedDate,
                events: eventKitManager.events
            )
        }
    }
    
    // MARK: - 이벤트 목록 섹션
    private var eventListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 날짜 헤더
            HStack {
                Text(selectedDateText)
                    .font(.headline)
                
                Spacer()
                
                if selectedDateEvents.isEmpty == false {
                    Text("\(selectedDateEvents.count)개의 일정")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // 이벤트 리스트
            if selectedDateEvents.isEmpty {
                ContentUnavailableView(
                    "일정 없음",
                    systemImage: "calendar.badge.minus",
                    description: Text("선택한 날짜에 일정이 없습니다")
                )
            } else {
                List {
                    ForEach(selectedDateEvents) { event in
                        EventRowView(event: event)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                selectedEvent = event
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    // MARK: - 선택된 날짜 텍스트
    private var selectedDateText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        return formatter.string(from: selectedDate)
    }
    
    // MARK: - 선택된 날짜의 이벤트
    private var selectedDateEvents: [CalendarEvent] {
        eventKitManager.events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: selectedDate) ||
            calendar.isDate(event.endDate, inSameDayAs: selectedDate) ||
            (event.startDate < selectedDate && event.endDate > selectedDate)
        }
    }
    
    // MARK: - 현재 기간 이벤트 로드
    private func loadEventsForCurrentPeriod() async {
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        // 캘린더 그리드에 표시되는 전후 주 포함
        let startDate = calendar.date(byAdding: .day, value: -7, to: startOfMonth)!
        let endDate = calendar.date(byAdding: .day, value: 7, to: endOfMonth)!
        
        let calendars = selectedCalendarIds.isEmpty ? nil : Array(selectedCalendarIds)
        await eventKitManager.loadEvents(from: startDate, to: endDate, calendars: calendars)
    }
}

// MARK: - 이벤트 행 뷰
struct EventRowView: View {
    let event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // 캘린더 색상 표시
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(cgColor: event.calendarColor ?? CGColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1)))
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.body)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    // 시간 표시
                    if event.isAllDay {
                        Text("하루 종일")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(timeText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // 위치 표시
                    if let location = event.location, !location.isEmpty {
                        Label(location, systemImage: "location")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    
                    // 반복 표시
                    if event.recurrenceRule != nil {
                        Image(systemName: "repeat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - 시간 텍스트
    private var timeText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        
        let start = formatter.string(from: event.startDate)
        let end = formatter.string(from: event.endDate)
        
        return "\(start) - \(end)"
    }
}

// MARK: - 캘린더 선택 뷰
struct CalendarPickerView: View {
    @EnvironmentObject var eventKitManager: EventKitManager
    @Binding var selectedCalendarIds: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(eventKitManager.calendars) { calendar in
                    HStack {
                        // 캘린더 색상
                        Circle()
                            .fill(Color(cgColor: calendar.color))
                            .frame(width: 12, height: 12)
                        
                        VStack(alignment: .leading) {
                            Text(calendar.title)
                                .font(.body)
                            
                            Text(calendar.typeDisplayText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        if selectedCalendarIds.contains(calendar.id) {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if selectedCalendarIds.contains(calendar.id) {
                            selectedCalendarIds.remove(calendar.id)
                        } else {
                            selectedCalendarIds.insert(calendar.id)
                        }
                    }
                }
            }
            .navigationTitle("캘린더 선택")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(selectedCalendarIds.count == eventKitManager.calendars.count ? "전체 해제" : "전체 선택") {
                        if selectedCalendarIds.count == eventKitManager.calendars.count {
                            selectedCalendarIds.removeAll()
                        } else {
                            selectedCalendarIds = Set(eventKitManager.calendars.map { $0.id })
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 미리보기
#Preview {
    CalendarView()
        .environmentObject(EventKitManager.shared)
}
