import SwiftUI

struct AlarmPickerView: View {
    @Binding var selectedAlarm: AlarmOption
    
    var body: some View {
        Picker("알림", selection: $selectedAlarm) {
            ForEach(AlarmOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
    }
}
