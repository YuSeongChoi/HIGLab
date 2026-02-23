import SwiftUI

struct FrameworkCardView: View {
    let item: FrameworkItem

    private let cardHeight: CGFloat = 276

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            topVisual

            VStack(alignment: .leading, spacing: 8) {
                completionBadge

                Text(item.name)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(item.description)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 12)

            Spacer(minLength: 0)

            chipRow
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight, alignment: .top)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator).opacity(0.3), lineWidth: 0.6)
        )
    }

    private var topVisual: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(item.tint.gradient)
            Image(systemName: item.symbolName)
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(height: 92)
        .padding(.horizontal, 12)
        .padding(.top, 12)
    }

    private var completionBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
            Text(item.isCompleted ? "완성" : "진행중")
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(item.isCompleted ? Color.green : Color.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.secondarySystemBackground), in: Capsule())
    }

    private var chipRow: some View {
        HStack(spacing: 6) {
            ForEach(item.links) { resource in
                FrameworkResourceChip(kind: resource.kind)
            }
        }
    }
}

private struct FrameworkResourceChip: View {
    let kind: FrameworkResourceKind

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: kind.systemImage)
            Text(kind.title)
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground), in: Capsule())
    }
}
