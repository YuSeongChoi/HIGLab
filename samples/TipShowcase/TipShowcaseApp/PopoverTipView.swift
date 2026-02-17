import SwiftUI
import TipKit

/// 팝오버 팁 예제 화면
/// .popoverTip() 수정자를 사용하여 특정 UI 요소에 팁을 연결하는 방법을 보여줍니다.
struct PopoverTipView: View {
    // 팁 인스턴스 생성
    private let shareTip = ShareTip()
    
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // 설명 텍스트
                VStack(spacing: 8) {
                    Text("팝오버 팁 예제")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("공유 버튼 위에 팁이 말풍선 형태로 표시됩니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                Spacer()
                
                // 샘플 콘텐츠 카드
                VStack(spacing: 16) {
                    Image(systemName: "photo.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    Text("멋진 사진")
                        .font(.headline)
                    
                    Text("이 콘텐츠를 친구들과 공유해보세요!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(32)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
                
                // MARK: - 팝오버 팁이 연결된 공유 버튼
                Button {
                    showShareSheet = true
                    // 공유 버튼을 누르면 팁 무효화
                    shareTip.invalidate(reason: .actionPerformed)
                } label: {
                    Label("공유하기", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                // 팝오버 팁 연결
                // arrowEdge: 팁 말풍선의 화살표 방향
                .popoverTip(shareTip, arrowEdge: .bottom)
            }
            .padding()
            .navigationTitle("팝오버 팁")
            .sheet(isPresented: $showShareSheet) {
                // 간단한 공유 시트 대체 화면
                ShareSheetPlaceholder()
            }
        }
    }
}

/// 공유 시트 대체 화면
struct ShareSheetPlaceholder: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.green)
                
                Text("공유 완료!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("(이것은 공유 시트 예제입니다)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("공유")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

#Preview {
    PopoverTipView()
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
}
