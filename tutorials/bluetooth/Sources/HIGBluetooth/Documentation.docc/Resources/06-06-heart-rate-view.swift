import SwiftUI

struct HeartRateView: View {
    @State private var manager = BluetoothManager()
    
    var body: some View {
        VStack(spacing: 24) {
            // 현재 심박수
            VStack {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.red)
                    .symbolEffect(.pulse, options: .repeating)
                
                Text("\(manager.currentHeartRate)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                
                Text("BPM")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            
            // 히스토리 차트 (간단한 버전)
            HStack(alignment: .bottom, spacing: 2) {
                ForEach(manager.heartRateHistory.suffix(30), id: \.self) { hr in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(.red.opacity(0.7))
                        .frame(width: 8, height: CGFloat(hr) / 2)
                }
            }
            .frame(height: 100)
        }
        .padding()
    }
}
