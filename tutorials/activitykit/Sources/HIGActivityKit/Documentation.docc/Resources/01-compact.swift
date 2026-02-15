// Dynamic Island - Compact 레이아웃
// Leading(좌)과 Trailing(우) 영역

// Compact Leading: 좌측 - 아이콘 또는 이미지
struct CompactLeadingView: View {
    var body: some View {
        Image(systemName: "bicycle")
            .font(.system(size: 14, weight: .semibold))
    }
}

// Compact Trailing: 우측 - 핵심 숫자/텍스트
struct CompactTrailingView: View {
    let minutesRemaining: Int
    
    var body: some View {
        Text("\(minutesRemaining)분")
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .monospacedDigit()
    }
}
