// PatternEditorView.swift
// HapticDemo - Core Haptics 샘플
// 패턴 에디터 - 커스텀 햅틱 패턴 생성 및 편집

import SwiftUI

// MARK: - 패턴 에디터 뷰
struct PatternEditorView: View {
    @EnvironmentObject var hapticManager: HapticEngineManager
    
    // 편집 중인 패턴
    @State private var pattern: HapticPattern = HapticPattern(
        name: "내 패턴",
        description: "커스텀 햅틱 패턴"
    )
    
    // 선택된 이벤트
    @State private var selectedEvent: HapticEvent?
    
    // UI 상태
    @State private var showingAddEvent: Bool = false
    @State private var showingPatternSettings: Bool = false
    @State private var showingSaveAlert: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 타임라인 뷰
                timelineSection
                
                Divider()
                
                // 이벤트 목록
                eventListSection
                
                Divider()
                
                // 선택된 이벤트 편집기
                if let event = selectedEvent {
                    eventEditorSection(event: event)
                } else {
                    emptyEditorSection
                }
                
                // 하단 컨트롤
                bottomControls
            }
            .navigationTitle("패턴 에디터")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            showingPatternSettings = true
                        } label: {
                            Label("패턴 설정", systemImage: "gearshape")
                        }
                        
                        Button {
                            resetPattern()
                        } label: {
                            Label("초기화", systemImage: "arrow.counterclockwise")
                        }
                        
                        Button {
                            showingSaveAlert = true
                        } label: {
                            Label("저장", systemImage: "square.and.arrow.down")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingAddEvent) {
                AddEventSheet { newEvent in
                    pattern.events.append(newEvent)
                    selectedEvent = newEvent
                    hapticManager.playTransientHaptic(intensity: 0.5, sharpness: 0.7)
                }
            }
            .sheet(isPresented: $showingPatternSettings) {
                PatternSettingsSheet(pattern: $pattern)
            }
            .alert("패턴 저장", isPresented: $showingSaveAlert) {
                Button("확인", role: .cancel) {}
            } message: {
                Text("패턴이 저장되었습니다.\n(데모 버전에서는 실제 저장되지 않습니다)")
            }
        }
    }
    
    // MARK: - 타임라인 섹션
    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("타임라인")
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.2f초", pattern.totalDuration))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            // 타임라인 시각화
            TimelineVisualization(
                events: pattern.events,
                selectedEvent: selectedEvent,
                totalDuration: max(pattern.totalDuration, 1.0)
            ) { event in
                selectedEvent = event
            }
            .frame(height: 80)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
        .background(Color(.secondarySystemGroupedBackground))
    }
    
    // MARK: - 이벤트 목록 섹션
    private var eventListSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("이벤트 (\(pattern.events.count)개)")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    showingAddEvent = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            if pattern.events.isEmpty {
                Text("이벤트가 없습니다. + 버튼을 눌러 추가하세요.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(pattern.sortedEvents) { event in
                            EventChip(
                                event: event,
                                isSelected: selectedEvent?.id == event.id
                            ) {
                                selectedEvent = event
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.bottom, 12)
        .background(Color(.systemBackground))
    }
    
    // MARK: - 이벤트 편집기 섹션
    private func eventEditorSection(event: HapticEvent) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("이벤트 편집")
                    .font(.headline)
                
                Spacer()
                
                Button(role: .destructive) {
                    deleteEvent(event)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // 타입 선택
            VStack(alignment: .leading, spacing: 4) {
                Text("타입")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Picker("타입", selection: Binding(
                    get: { event.type },
                    set: { updateEvent(event, type: $0) }
                )) {
                    ForEach(HapticEventType.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // 시간 슬라이더
            ParameterSlider(
                title: "시작 시간",
                value: Binding(
                    get: { Float(event.relativeTime) },
                    set: { updateEvent(event, relativeTime: TimeInterval($0)) }
                ),
                range: 0...2,
                unit: "초"
            )
            
            // 지속 시간 슬라이더 (연속 타입만)
            if event.type != .transient {
                ParameterSlider(
                    title: "지속 시간",
                    value: Binding(
                        get: { Float(event.duration) },
                        set: { updateEvent(event, duration: TimeInterval($0)) }
                    ),
                    range: 0.01...1,
                    unit: "초"
                )
            }
            
            // 강도 슬라이더
            ParameterSlider(
                title: "강도",
                value: Binding(
                    get: { event.intensity },
                    set: { updateEvent(event, intensity: $0) }
                ),
                range: 0...1,
                unit: "%",
                isPercentage: true
            )
            
            // 선명도 슬라이더
            ParameterSlider(
                title: "선명도",
                value: Binding(
                    get: { event.sharpness },
                    set: { updateEvent(event, sharpness: $0) }
                ),
                range: 0...1,
                unit: "%",
                isPercentage: true
            )
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
    }
    
    // MARK: - 빈 편집기 섹션
    private var emptyEditorSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.tap")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("이벤트를 선택하여 편집하세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.secondarySystemGroupedBackground))
    }
    
    // MARK: - 하단 컨트롤
    private var bottomControls: some View {
        HStack(spacing: 16) {
            // 미리보기 버튼
            Button {
                playPattern()
            } label: {
                Label("미리보기", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(pattern.events.isEmpty)
            
            // 중지 버튼
            Button {
                hapticManager.stopCurrentPlayback()
            } label: {
                Image(systemName: "stop.fill")
                    .font(.headline)
                    .padding()
                    .background(Color(.tertiarySystemFill))
                    .foregroundColor(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }
    
    // MARK: - 헬퍼 메서드
    
    private func playPattern() {
        do {
            try hapticManager.playPattern(pattern)
        } catch {
            // 에러 처리
        }
    }
    
    private func resetPattern() {
        pattern = HapticPattern(
            name: "내 패턴",
            description: "커스텀 햅틱 패턴"
        )
        selectedEvent = nil
    }
    
    private func deleteEvent(_ event: HapticEvent) {
        pattern.events.removeAll { $0.id == event.id }
        if selectedEvent?.id == event.id {
            selectedEvent = nil
        }
        hapticManager.playTransientHaptic(intensity: 0.3, sharpness: 0.5)
    }
    
    private func updateEvent(_ event: HapticEvent, type: HapticEventType? = nil, relativeTime: TimeInterval? = nil, duration: TimeInterval? = nil, intensity: Float? = nil, sharpness: Float? = nil) {
        guard let index = pattern.events.firstIndex(where: { $0.id == event.id }) else { return }
        
        var updated = event
        if let type = type { updated.type = type }
        if let time = relativeTime { updated.relativeTime = time }
        if let dur = duration { updated.duration = dur }
        if let int = intensity { updated.intensity = int }
        if let sharp = sharpness { updated.sharpness = sharp }
        
        pattern.events[index] = updated
        selectedEvent = updated
    }
}

// MARK: - 타임라인 시각화
struct TimelineVisualization: View {
    let events: [HapticEvent]
    let selectedEvent: HapticEvent?
    let totalDuration: TimeInterval
    let onSelect: (HapticEvent) -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경 그리드
                HStack(spacing: 0) {
                    ForEach(0..<10) { i in
                        Rectangle()
                            .fill(Color(.separator).opacity(0.3))
                            .frame(width: 1)
                        Spacer()
                    }
                }
                
                // 베이스라인
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 2)
                    .offset(y: 30)
                
                // 이벤트 마커
                ForEach(events) { event in
                    let xPosition = CGFloat(event.relativeTime / totalDuration) * geometry.size.width
                    
                    EventMarker(
                        event: event,
                        isSelected: selectedEvent?.id == event.id,
                        width: event.type == .transient ? 20 : CGFloat(event.duration / totalDuration) * geometry.size.width
                    )
                    .position(x: xPosition + (event.type == .transient ? 10 : CGFloat(event.duration / totalDuration) * geometry.size.width / 2), y: 40)
                    .onTapGesture {
                        onSelect(event)
                    }
                }
            }
        }
    }
}

// MARK: - 이벤트 마커
struct EventMarker: View {
    let event: HapticEvent
    let isSelected: Bool
    let width: CGFloat
    
    var body: some View {
        Group {
            if event.type == .transient {
                // 일시적 이벤트 - 원형 마커
                Circle()
                    .fill(isSelected ? Color.blue : Color.orange)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    }
            } else {
                // 연속 이벤트 - 직사각형 마커
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.blue : Color.green)
                    .frame(width: max(width, 30), height: 30)
                    .overlay {
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white, lineWidth: 2)
                    }
            }
        }
        .shadow(color: isSelected ? .blue.opacity(0.5) : .clear, radius: 5)
    }
}

// MARK: - 이벤트 칩
struct EventChip: View {
    let event: HapticEvent
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: event.type.iconName)
                    .font(.title3)
                
                Text(event.type.rawValue)
                    .font(.caption2)
                
                Text(String(format: "%.2f초", event.relativeTime))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.tertiarySystemFill))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 파라미터 슬라이더
struct ParameterSlider: View {
    let title: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let unit: String
    var isPercentage: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(formattedValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }
            
            Slider(value: $value, in: range)
        }
    }
    
    private var formattedValue: String {
        if isPercentage {
            return "\(Int(value * 100))%"
        } else {
            return String(format: "%.2f%@", value, unit)
        }
    }
}

// MARK: - 이벤트 추가 시트
struct AddEventSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var eventType: HapticEventType = .transient
    @State private var relativeTime: Float = 0
    @State private var duration: Float = 0.1
    @State private var intensity: Float = 1.0
    @State private var sharpness: Float = 0.5
    
    let onAdd: (HapticEvent) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section("타입") {
                    Picker("이벤트 타입", selection: $eventType) {
                        ForEach(HapticEventType.allCases) { type in
                            Label(type.rawValue, systemImage: type.iconName)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                Section("타이밍") {
                    ParameterSlider(
                        title: "시작 시간",
                        value: $relativeTime,
                        range: 0...2,
                        unit: "초"
                    )
                    
                    if eventType != .transient {
                        ParameterSlider(
                            title: "지속 시간",
                            value: $duration,
                            range: 0.01...1,
                            unit: "초"
                        )
                    }
                }
                
                Section("파라미터") {
                    ParameterSlider(
                        title: "강도",
                        value: $intensity,
                        range: 0...1,
                        unit: "%",
                        isPercentage: true
                    )
                    
                    ParameterSlider(
                        title: "선명도",
                        value: $sharpness,
                        range: 0...1,
                        unit: "%",
                        isPercentage: true
                    )
                }
            }
            .navigationTitle("이벤트 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("추가") {
                        let event = HapticEvent(
                            type: eventType,
                            relativeTime: TimeInterval(relativeTime),
                            duration: TimeInterval(duration),
                            intensity: intensity,
                            sharpness: sharpness
                        )
                        onAdd(event)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 패턴 설정 시트
struct PatternSettingsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var pattern: HapticPattern
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("이름", text: $pattern.name)
                    TextField("설명", text: $pattern.description)
                }
                
                Section("루핑") {
                    Toggle("반복 재생", isOn: $pattern.isLooping)
                    
                    if pattern.isLooping {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("루프 길이")
                                Spacer()
                                Text(String(format: "%.2f초", pattern.loopDuration))
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: Binding(
                                get: { Float(pattern.loopDuration) },
                                set: { pattern.loopDuration = TimeInterval($0) }
                            ), in: 0.5...5)
                        }
                    }
                }
            }
            .navigationTitle("패턴 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    PatternEditorView()
        .environmentObject(HapticEngineManager())
}
