import SwiftUI

struct CreateEventView: View {
    @State private var title = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600)
    
    var body: some View {
        Form {
            Section("이벤트 정보") {
                TextField("제목", text: $title)
            }
            
            Section("시간") {
                DatePicker("시작", selection: $startDate)
                DatePicker("종료", selection: $endDate)
            }
        }
        .navigationTitle("새 이벤트")
    }
}
