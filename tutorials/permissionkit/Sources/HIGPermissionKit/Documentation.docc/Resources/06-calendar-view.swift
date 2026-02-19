#if canImport(PermissionKit)
import PermissionKit
import EventKit
import SwiftUI

// 캘린더 일정 표시 뷰
struct CalendarEventsView: View {
    @State private var events: [EKEvent] = []
    @State private var isLoading = false
    
    private let eventStore = EKEventStore()
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("일정 로딩 중...")
                } else if events.isEmpty {
                    ContentUnavailableView {
                        Label("일정 없음", systemImage: "calendar.badge.exclamationmark")
                    } description: {
                        Text("다가오는 일정이 없습니다.")
                    }
                } else {
                    List(events, id: \.eventIdentifier) { event in
                        EventRow(event: event)
                    }
                }
            }
            .navigationTitle("다가오는 일정")
            .task {
                await loadEvents()
            }
        }
    }
    
    private func loadEvents() async {
        isLoading = true
        
        // 오늘부터 30일 후까지의 일정 가져오기
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(
            withStart: startDate,
            end: endDate,
            calendars: nil
        )
        
        let fetchedEvents = eventStore.events(matching: predicate)
        
        await MainActor.run {
            events = fetchedEvents.sorted { $0.startDate < $1.startDate }
            isLoading = false
        }
    }
}

struct EventRow: View {
    let event: EKEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // 캘린더 색상 인디케이터
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(cgColor: event.calendar.cgColor))
                .frame(width: 4, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(event.startDate, style: .date)
                    Text(event.startDate, style: .time)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if event.isAllDay {
                Text("종일")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

// iOS 26 PermissionKit - HIG Lab
#endif
