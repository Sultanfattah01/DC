import SwiftUI

struct AvatarView: View {
    let initials: String
    let theme: CardTheme
    var photoData: Data?
    var size: CGFloat = 44

    var body: some View {
        ZStack {
            Circle().fill(theme.gradient)

            if let image = photoData.flatMap(UIImage.init(data:)) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Text(initials)
                    .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    var action: (() -> Void)?
    var actionLabel = "Edit"
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(title)
                    .font(.headline)

                Spacer()

                if let action {
                    Button(actionLabel, action: action)
                        .font(.subheadline)
                }
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct AboutText: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct ExperienceList: View {
    let items: [Experience]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack(alignment: .top, spacing: 14) {
                    VStack(spacing: 0) {
                        Image(systemName: "building.2.fill")
                            .font(.caption)
                            .foregroundStyle(accent)
                            .frame(width: 34, height: 34)
                            .background(accent.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 9))

                        if index < items.count - 1 {
                            Rectangle()
                                .fill(Color(.separator))
                                .frame(width: 1)
                                .frame(maxHeight: .infinity)
                                .padding(.top, 4)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.title)
                            .font(.subheadline.weight(.semibold))

                        if !item.company.isEmpty {
                            Text(item.company)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        HStack(spacing: 6) {
                            if !item.dateRange.isEmpty {
                                Text(item.dateRange)
                            }
                            if !item.location.isEmpty {
                                Text("·")
                                Text(item.location)
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(.tertiary)

                        if !item.summary.isEmpty {
                            Text(item.summary)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 3)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct EducationList: View {
    let items: [Education]
    let accent: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(items) { item in
                HStack(alignment: .top, spacing: 14) {
                    Image(systemName: "graduationcap.fill")
                        .font(.caption)
                        .foregroundStyle(accent)
                        .frame(width: 34, height: 34)
                        .background(accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 9))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.school)
                            .font(.subheadline.weight(.semibold))

                        if !item.degree.isEmpty {
                            Text(item.degree)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        if !item.years.isEmpty {
                            Text(item.years)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }
}

struct SkillChips: View {
    let skills: [String]
    let accent: Color

    var body: some View {
        FlowLayout(spacing: 8) {
            ForEach(skills, id: \.self) { skill in
                Text(skill)
                    .font(.footnote.weight(.medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(accent.opacity(0.12))
                    .foregroundStyle(accent)
                    .clipShape(Capsule())
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if rowWidth > 0, rowWidth + spacing + size.width > maxWidth {
                totalHeight += rowHeight + spacing
                rowWidth = size.width
                rowHeight = size.height
            } else {
                rowWidth += rowWidth > 0 ? spacing + size.width : size.width
                rowHeight = max(rowHeight, size.height)
            }
        }

        return CGSize(width: maxWidth == .infinity ? rowWidth : maxWidth, height: totalHeight + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }

            subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
