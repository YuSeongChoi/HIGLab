import SwiftUI

struct FrameworkDetailView: View {
    let item: FrameworkItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                resourcesCard

                localPathCard

                nextStepCard
            }
            .padding(16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(item.tint.gradient)
                    Image(systemName: item.symbolName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .frame(width: 56, height: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.title3.weight(.bold))
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Label(item.isCompleted ? "완성된 학습 카드" : "진행 예정 카드", systemImage: item.isCompleted ? "checkmark.circle.fill" : "clock")
                .font(.footnote)
                .foregroundStyle(item.isCompleted ? .green : .secondary)
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var resourcesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("학습 링크")
                .font(.headline)

            ForEach(item.links) { resource in
                if let url = resource.url {
                    Link(destination: url) {
                        HStack {
                            Label(resource.kind.title, systemImage: resource.kind.systemImage)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .foregroundStyle(.secondary)
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                    .tint(.primary)
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var localPathCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("로컬 경로")
                .font(.headline)

            pathRow(title: "Site", path: item.localSitePath)
            pathRow(title: "Tutorial", path: item.localTutorialPath)
            if let localSamplePath = item.localSamplePath {
                pathRow(title: "Sample", path: localSamplePath)
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var nextStepCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("다음 단계")
                .font(.headline)
            Text("다음 구현에서는 이 화면 대신 \"샘플 코드를 바탕으로 만든 예제 View\"를 연결하면 됩니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("추천: `Features/Examples/\(item.id.capitalized)ExampleView.swift`")
                .font(.footnote.monospaced())
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func pathRow(title: String, path: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(path)
                .font(.footnote.monospaced())
                .textSelection(.enabled)
        }
    }
}
