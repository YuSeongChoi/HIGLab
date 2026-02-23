import SwiftUI

struct FrameworkDetailView: View {
    @EnvironmentObject private var progressStore: LearningProgressStore

    let item: FrameworkItem

    private var statusBinding: Binding<LearningStatus> {
        Binding(
            get: { progressStore.status(for: item) },
            set: { progressStore.setStatus($0, for: item) }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard
                progressCard
                resourcesCard
                localPathCard
                checklistCard
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
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("학습 상태")
                .font(.headline)

            Picker("학습 상태", selection: statusBinding) {
                ForEach(LearningStatus.allCases) { status in
                    Text(status.title).tag(status)
                }
            }
            .pickerStyle(.segmented)
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

    private var checklistCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘 할 일")
                .font(.headline)

            ForEach(DailyChecklistItem.allCases) { task in
                Button {
                    progressStore.toggle(task, for: item)
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: progressStore.isChecked(task, for: item) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(progressStore.isChecked(task, for: item) ? Color.green : Color.secondary)
                        Text(task.title)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }

            let completedCount = progressStore.completedCount(for: item)
            let totalCount = DailyChecklistItem.allCases.count
            Text("완료: \(completedCount)/\(totalCount)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var nextStepCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("다음 단계")
                .font(.headline)
            Text("다음 구현에서는 이 화면 대신 샘플 코드를 바탕으로 만든 예제 View를 연결하면 됩니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("추천: Features/Examples/\(item.id.capitalized)ExampleView.swift")
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
