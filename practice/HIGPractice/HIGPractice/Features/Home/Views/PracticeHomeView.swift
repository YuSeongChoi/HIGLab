import SwiftUI

struct PracticeHomeView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private let phases = FrameworkPhase.allCases

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 28) {
                    ForEach(phases) { phase in
                        VStack(alignment: .leading, spacing: 14) {
                            PhaseSectionHeaderView(phase: phase)

                            LazyVGrid(columns: gridColumns, spacing: 16) {
                                ForEach(PracticeCatalog.items(for: phase)) { item in
                                    NavigationLink(value: item) {
                                        FrameworkCardView(item: item)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("HIG Practice")
            .navigationDestination(for: FrameworkItem.self) { item in
                FrameworkDetailView(item: item)
            }
        }
    }

    private var gridColumns: [GridItem] {
        let minimumWidth: CGFloat = horizontalSizeClass == .regular ? 220 : 160
        return [GridItem(.adaptive(minimum: minimumWidth, maximum: 380), spacing: 16, alignment: .top)]
    }
}
