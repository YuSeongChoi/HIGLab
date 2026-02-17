import SwiftUI
import CoreLocation

// MARK: - 알림 상세/편집 뷰
// 새 알림 생성 또는 기존 알림 편집을 위한 폼 뷰입니다.
// 시간/위치 기반 트리거, 반복 주기, 카테고리 등을 설정할 수 있습니다.

struct NotificationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    /// 뷰 모드 (추가/편집)
    let mode: Mode
    
    /// 저장 완료 시 콜백
    let onSave: (NotificationItem) -> Void
    
    // MARK: - 폼 상태
    
    @State private var title: String = ""
    @State private var body: String = ""
    @State private var scheduledDate: Date = Date().addingTimeInterval(3600)
    @State private var repeatInterval: RepeatInterval = .none
    @State private var category: NotificationCategory = .reminder
    @State private var isEnabled: Bool = true
    
    // 위치 기반 옵션
    @State private var isLocationBased: Bool = false
    @State private var selectedLocation: LocationOption = .home
    @State private var triggerOnEntry: Bool = true
    
    // UI 상태
    @State private var showingLocationPicker = false
    @State private var showingDeleteConfirmation = false
    
    enum Mode {
        case add
        case edit(NotificationItem)
        
        var isEditing: Bool {
            if case .edit = self { return true }
            return false
        }
        
        var title: String {
            switch self {
            case .add: "새 알림"
            case .edit: "알림 편집"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // 기본 정보 섹션
                basicInfoSection
                
                // 스케줄 섹션
                scheduleSection
                
                // 트리거 타입 섹션
                triggerTypeSection
                
                // 카테고리 섹션
                categorySection
                
                // 편집 모드일 때 삭제 버튼
                if mode.isEditing {
                    deleteSection
                }
            }
            .navigationTitle(mode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        saveNotification()
                    }
                    .fontWeight(.semibold)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                loadExistingData()
            }
            .confirmationDialog(
                "이 알림을 삭제하시겠습니까?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    deleteNotification()
                }
            } message: {
                Text("이 작업은 되돌릴 수 없습니다.")
            }
        }
    }
    
    // MARK: - 기본 정보 섹션
    
    private var basicInfoSection: some View {
        Section {
            TextField("제목", text: $title)
                .font(.headline)
            
            TextField("내용 (선택사항)", text: $body, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("알림 내용")
        }
    }
    
    // MARK: - 스케줄 섹션
    
    private var scheduleSection: some View {
        Section {
            // 시간 선택
            DatePicker(
                "날짜 및 시간",
                selection: $scheduledDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            
            // 반복 주기 선택
            Picker("반복", selection: $repeatInterval) {
                ForEach(RepeatInterval.allCases, id: \.self) { interval in
                    Label(interval.rawValue, systemImage: interval.symbol)
                        .tag(interval)
                }
            }
        } header: {
            Text("스케줄")
        } footer: {
            if repeatInterval != .none {
                Text("선택한 시간에 \(repeatInterval.rawValue) 알림을 받습니다.")
            }
        }
    }
    
    // MARK: - 트리거 타입 섹션
    
    private var triggerTypeSection: some View {
        Section {
            // 시간/위치 기반 선택
            Toggle(isOn: $isLocationBased.animation()) {
                Label("위치 기반 알림", systemImage: "location.fill")
            }
            
            if isLocationBased {
                // 위치 선택
                Picker("위치", selection: $selectedLocation) {
                    ForEach(LocationOption.allCases, id: \.self) { location in
                        Text(location.displayName).tag(location)
                    }
                }
                
                // 진입/이탈 선택
                Picker("트리거", selection: $triggerOnEntry) {
                    Text("도착할 때").tag(true)
                    Text("떠날 때").tag(false)
                }
                .pickerStyle(.segmented)
            }
        } header: {
            Text("트리거 방식")
        } footer: {
            if isLocationBased {
                Text("\(selectedLocation.displayName)에 \(triggerOnEntry ? "도착" : "이탈")할 때 알림을 받습니다.")
            }
        }
    }
    
    // MARK: - 카테고리 섹션
    
    private var categorySection: some View {
        Section {
            Picker("카테고리", selection: $category) {
                ForEach(NotificationCategory.allCases, id: \.self) { cat in
                    Label(cat.displayName, systemImage: cat.symbol)
                        .tag(cat)
                }
            }
            .pickerStyle(.navigationLink)
            
            Toggle("알림 활성화", isOn: $isEnabled)
        } header: {
            Text("분류")
        } footer: {
            Text("카테고리에 따라 알림에 다른 액션 버튼이 표시됩니다.")
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
                    Label("알림 삭제", systemImage: "trash")
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - 액션
    
    private func loadExistingData() {
        if case .edit(let item) = mode {
            title = item.title
            body = item.body
            scheduledDate = item.scheduledDate
            repeatInterval = item.repeatInterval
            category = item.category
            isEnabled = item.isEnabled
            
            // 위치 기반 알림인 경우
            if item.category == .location {
                isLocationBased = true
            }
        }
    }
    
    private func saveNotification() {
        let itemId: UUID
        if case .edit(let existingItem) = mode {
            itemId = existingItem.id
        } else {
            itemId = UUID()
        }
        
        // 위치 기반일 경우 카테고리를 location으로 변경
        let finalCategory = isLocationBased ? .location : category
        
        let notification = NotificationItem(
            id: itemId,
            title: title.trimmingCharacters(in: .whitespaces),
            body: body.trimmingCharacters(in: .whitespaces),
            scheduledDate: scheduledDate,
            repeatInterval: isLocationBased ? .none : repeatInterval,
            category: finalCategory,
            isEnabled: isEnabled
        )
        
        // 위치 기반 알림 스케줄링
        if isLocationBased {
            Task {
                try? await NotificationService.shared.scheduleLocationBasedNotification(
                    notification,
                    coordinate: selectedLocation.coordinate,
                    radius: 100,
                    onEntry: triggerOnEntry
                )
            }
        }
        
        onSave(notification)
        dismiss()
    }
    
    private func deleteNotification() {
        if case .edit(let item) = mode {
            NotificationStore.shared.deleteNotification(id: item.id)
        }
        dismiss()
    }
}

// MARK: - 위치 옵션

enum LocationOption: String, CaseIterable {
    case home = "집"
    case work = "직장"
    case gym = "헬스장"
    case custom = "사용자 지정"
    
    var displayName: String { rawValue }
    
    /// 샘플 좌표 (실제 앱에서는 사용자 설정 사용)
    var coordinate: CLLocationCoordinate2D {
        switch self {
        case .home:
            CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780) // 서울 시청
        case .work:
            CLLocationCoordinate2D(latitude: 37.5705, longitude: 126.9850) // 종로
        case .gym:
            CLLocationCoordinate2D(latitude: 37.5635, longitude: 126.9750) // 명동
        case .custom:
            CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
        }
    }
}

// MARK: - Preview

#Preview("새 알림") {
    NotificationDetailView(mode: .add) { _ in }
}

#Preview("알림 편집") {
    NotificationDetailView(mode: .edit(.preview)) { _ in }
}
