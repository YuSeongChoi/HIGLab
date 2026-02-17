import SwiftUI
import EventKit

// MARK: - 이벤트 상세/편집 뷰
/// 이벤트를 생성하거나 편집하는 뷰
struct EventDetailView: View {
    @EnvironmentObject var eventKitManager: EventKitManager
    @Environment(\.dismiss) private var dismiss
    
    // 편집 모드 (기존 이벤트가 있으면 편집, 없으면 생성)
    let originalEvent: CalendarEvent?
    let selectedDate: Date
    let onSave: ((CalendarEvent) -> Void)?
    
    // 폼 상태
    @State private var title: String = ""
    @State private var isAllDay: Bool = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var location: String = ""
    @State private var notes: String = ""
    @State private var selectedCalendarId: String = ""
    @State private var hasRecurrence: Bool = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .daily
    @State private var recurrenceInterval: Int = 1
    @State private var alarms: [EventAlarm] = []
    
    // UI 상태
    @State private var showingDeleteConfirmation = false
    @State private var showingRecurrenceSheet = false
    @State private var showingAlarmPicker = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    // 편집 모드 여부
    private var isEditing: Bool {
        originalEvent != nil
    }
    
    init(
        event: CalendarEvent?,
        selectedDate: Date,
        onSave: ((CalendarEvent) -> Void)? = nil
    ) {
        self.originalEvent = event
        self.selectedDate = selectedDate
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 기본 정보 섹션
                basicInfoSection
                
                // 시간 섹션
                timeSection
                
                // 위치 섹션
                locationSection
                
                // 반복 섹션
                recurrenceSection
                
                // 알림 섹션
                alarmSection
                
                // 캘린더 섹션
                calendarSection
                
                // 메모 섹션
                notesSection
                
                // 삭제 버튼 (편집 모드)
                if isEditing {
                    deleteSection
                }
            }
            .navigationTitle(isEditing ? "일정 편집" : "새로운 일정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "저장" : "추가") {
                        Task {
                            await saveEvent()
                        }
                    }
                    .disabled(title.isEmpty || isLoading)
                }
            }
            .alert("오류", isPresented: .constant(errorMessage != nil)) {
                Button("확인") {
                    errorMessage = nil
                }
            } message: {
                if let errorMessage {
                    Text(errorMessage)
                }
            }
            .confirmationDialog("일정 삭제", isPresented: $showingDeleteConfirmation) {
                if originalEvent?.recurrenceRule != nil {
                    Button("이 일정만 삭제", role: .destructive) {
                        Task {
                            await deleteEvent(span: .thisEvent)
                        }
                    }
                    Button("이후 모든 일정 삭제", role: .destructive) {
                        Task {
                            await deleteEvent(span: .futureEvents)
                        }
                    }
                } else {
                    Button("삭제", role: .destructive) {
                        Task {
                            await deleteEvent(span: .thisEvent)
                        }
                    }
                }
                Button("취소", role: .cancel) { }
            }
            .sheet(isPresented: $showingRecurrenceSheet) {
                RecurrencePickerView(
                    frequency: $recurrenceFrequency,
                    interval: $recurrenceInterval,
                    hasRecurrence: $hasRecurrence
                )
            }
            .sheet(isPresented: $showingAlarmPicker) {
                AlarmPickerView(alarms: $alarms)
            }
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    // MARK: - 기본 정보 섹션
    private var basicInfoSection: some View {
        Section {
            TextField("제목", text: $title)
        }
    }
    
    // MARK: - 시간 섹션
    private var timeSection: some View {
        Section {
            Toggle("하루 종일", isOn: $isAllDay)
            
            DatePicker(
                "시작",
                selection: $startDate,
                displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
            )
            
            DatePicker(
                "종료",
                selection: $endDate,
                in: startDate...,
                displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
            )
        }
        .onChange(of: startDate) { _, newValue in
            // 시작일이 종료일보다 늦으면 종료일 조정
            if newValue > endDate {
                endDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue)!
            }
        }
    }
    
    // MARK: - 위치 섹션
    private var locationSection: some View {
        Section {
            HStack {
                Image(systemName: "location")
                    .foregroundStyle(.secondary)
                TextField("위치 추가", text: $location)
            }
        }
    }
    
    // MARK: - 반복 섹션
    private var recurrenceSection: some View {
        Section {
            Button {
                showingRecurrenceSheet = true
            } label: {
                HStack {
                    Image(systemName: "repeat")
                        .foregroundStyle(.secondary)
                    
                    Text("반복")
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text(recurrenceDisplayText)
                        .foregroundStyle(.secondary)
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
        }
    }
    
    // MARK: - 반복 표시 텍스트
    private var recurrenceDisplayText: String {
        guard hasRecurrence else { return "안 함" }
        
        if recurrenceInterval == 1 {
            return recurrenceFrequency.rawValue
        } else {
            switch recurrenceFrequency {
            case .daily: return "\(recurrenceInterval)일마다"
            case .weekly: return "\(recurrenceInterval)주마다"
            case .monthly: return "\(recurrenceInterval)개월마다"
            case .yearly: return "\(recurrenceInterval)년마다"
            }
        }
    }
    
    // MARK: - 알림 섹션
    private var alarmSection: some View {
        Section {
            Button {
                showingAlarmPicker = true
            } label: {
                HStack {
                    Image(systemName: "bell")
                        .foregroundStyle(.secondary)
                    
                    Text("알림")
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    if alarms.isEmpty {
                        Text("없음")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(alarms.count)개")
                            .foregroundStyle(.secondary)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            // 설정된 알림 표시
            ForEach(alarms) { alarm in
                HStack {
                    Text(alarm.displayText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Button {
                        alarms.removeAll { $0.id == alarm.id }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
    
    // MARK: - 캘린더 섹션
    private var calendarSection: some View {
        Section {
            Picker(selection: $selectedCalendarId) {
                ForEach(editableCalendars) { calendar in
                    HStack {
                        Circle()
                            .fill(Color(cgColor: calendar.color))
                            .frame(width: 10, height: 10)
                        Text(calendar.title)
                    }
                    .tag(calendar.id)
                }
            } label: {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                    Text("캘린더")
                }
            }
        }
    }
    
    // MARK: - 편집 가능한 캘린더 목록
    private var editableCalendars: [CalendarInfo] {
        eventKitManager.calendars.filter { $0.allowsModify }
    }
    
    // MARK: - 메모 섹션
    private var notesSection: some View {
        Section("메모") {
            TextEditor(text: $notes)
                .frame(minHeight: 100)
        }
    }
    
    // MARK: - 삭제 섹션
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("일정 삭제")
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - 초기값 설정
    private func setupInitialValues() {
        if let event = originalEvent {
            // 편집 모드: 기존 값 로드
            title = event.title
            isAllDay = event.isAllDay
            startDate = event.startDate
            endDate = event.endDate
            location = event.location ?? ""
            notes = event.notes ?? ""
            selectedCalendarId = event.calendarIdentifier
            alarms = event.alarms
            
            if let rule = event.recurrenceRule {
                hasRecurrence = true
                recurrenceFrequency = rule.frequency
                recurrenceInterval = rule.interval
            }
        } else {
            // 생성 모드: 기본값 설정
            let calendar = Calendar.current
            var start = calendar.date(bySettingHour: calendar.component(.hour, from: Date()) + 1,
                                       minute: 0, second: 0, of: selectedDate) ?? selectedDate
            
            // 선택된 날짜가 오늘인지 확인
            if !calendar.isDateInToday(selectedDate) {
                start = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: selectedDate) ?? selectedDate
            }
            
            startDate = start
            endDate = calendar.date(byAdding: .hour, value: 1, to: start)!
            
            // 기본 캘린더 설정
            if let defaultCalendar = eventKitManager.defaultCalendar() {
                selectedCalendarId = defaultCalendar.id
            } else if let firstCalendar = editableCalendars.first {
                selectedCalendarId = firstCalendar.id
            }
        }
    }
    
    // MARK: - 이벤트 저장
    private func saveEvent() async {
        isLoading = true
        defer { isLoading = false }
        
        var event = CalendarEvent(
            title: title,
            startDate: startDate,
            endDate: endDate,
            isAllDay: isAllDay,
            location: location.isEmpty ? nil : location,
            notes: notes.isEmpty ? nil : notes,
            calendarIdentifier: selectedCalendarId,
            recurrenceRule: hasRecurrence ? RecurrenceRule(
                frequency: recurrenceFrequency,
                interval: recurrenceInterval
            ) : nil,
            alarms: alarms
        )
        
        do {
            if let original = originalEvent {
                // 기존 이벤트 수정
                event = CalendarEvent(
                    title: title,
                    startDate: startDate,
                    endDate: endDate,
                    isAllDay: isAllDay,
                    location: location.isEmpty ? nil : location,
                    notes: notes.isEmpty ? nil : notes,
                    calendarIdentifier: selectedCalendarId,
                    recurrenceRule: hasRecurrence ? RecurrenceRule(
                        frequency: recurrenceFrequency,
                        interval: recurrenceInterval
                    ) : nil,
                    alarms: alarms
                )
                // ID 유지를 위한 특별 처리 필요
                var mutableEvent = event
                // Note: 실제 구현에서는 ID를 유지해야 함
                try await eventKitManager.updateEvent(CalendarEvent(
                    title: title,
                    startDate: startDate,
                    endDate: endDate,
                    isAllDay: isAllDay,
                    location: location.isEmpty ? nil : location,
                    notes: notes.isEmpty ? nil : notes,
                    calendarIdentifier: selectedCalendarId,
                    recurrenceRule: hasRecurrence ? RecurrenceRule(
                        frequency: recurrenceFrequency,
                        interval: recurrenceInterval
                    ) : nil,
                    alarms: alarms
                ))
            } else {
                // 새 이벤트 생성
                try await eventKitManager.createEvent(event)
            }
            
            onSave?(event)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - 이벤트 삭제
    private func deleteEvent(span: EKSpan) async {
        guard let event = originalEvent else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await eventKitManager.deleteEvent(event, span: span)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - 반복 설정 뷰
struct RecurrencePickerView: View {
    @Binding var frequency: RecurrenceFrequency
    @Binding var interval: Int
    @Binding var hasRecurrence: Bool
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Toggle("반복", isOn: $hasRecurrence)
                }
                
                if hasRecurrence {
                    Section("빈도") {
                        Picker("반복 주기", selection: $frequency) {
                            ForEach(RecurrenceFrequency.allCases, id: \.self) { freq in
                                Text(freq.rawValue).tag(freq)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        Stepper("간격: \(intervalText)", value: $interval, in: 1...99)
                    }
                }
            }
            .navigationTitle("반복")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private var intervalText: String {
        switch frequency {
        case .daily: return "\(interval)일"
        case .weekly: return "\(interval)주"
        case .monthly: return "\(interval)개월"
        case .yearly: return "\(interval)년"
        }
    }
}

// MARK: - 알림 설정 뷰
struct AlarmPickerView: View {
    @Binding var alarms: [EventAlarm]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(AlarmPreset.allCases, id: \.offsetMinutes) { preset in
                    Button {
                        let alarm = EventAlarm(offsetMinutes: preset.offsetMinutes)
                        if !alarms.contains(where: { $0.offsetMinutes == preset.offsetMinutes }) {
                            alarms.append(alarm)
                        }
                    } label: {
                        HStack {
                            Text(preset.displayText)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            if alarms.contains(where: { $0.offsetMinutes == preset.offsetMinutes }) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("알림 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - 미리보기
#Preview {
    EventDetailView(event: nil, selectedDate: Date())
        .environmentObject(EventKitManager.shared)
}
