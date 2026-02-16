import SwiftUI

struct NameSettingView: View {
    @ObservedObject var peerManager: PeerManager
    @State private var newName: String = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("표시 이름") {
                    TextField("이름을 입력하세요", text: $newName)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Text("이 이름은 다른 기기에 표시됩니다.")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .navigationTitle("이름 설정")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        peerManager.updateName(newName)
                        dismiss()
                    }
                    .disabled(newName.isEmpty)
                }
            }
            .onAppear {
                newName = peerManager.displayName
            }
        }
    }
}
