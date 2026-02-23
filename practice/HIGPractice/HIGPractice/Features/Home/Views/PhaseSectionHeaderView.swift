import SwiftUI

struct PhaseSectionHeaderView: View {
    let phase: FrameworkPhase

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(phase.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.primary)
            Text(phase.subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 6)
    }
}
