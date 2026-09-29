import SwiftUI

struct EventCardView: View {
    let event: Event
    var compact = false
    var showsActions = true

    @EnvironmentObject private var store: AppStore

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            banner

            VStack(alignment: .leading, spacing: 10) {
                Text(event.title)
                    .font(.system(size: compact ? 16 : 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                if !event.organizerName.isEmpty {
                    Text("by \(event.organizerName)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 5) {
                    detailLine(icon: "clock", text: "\(event.dateLine) · \(event.timeLine)")

                    if !event.locationLine.isEmpty {
                        detailLine(icon: event.format.icon, text: event.locationLine)
                    }
                }

                if !compact {
                    attendeeLine
                }

                if showsActions {
                    footer
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var banner: some View {
        ZStack(alignment: .topLeading) {
            event.theme.gradient

            HStack(alignment: .top) {
                VStack(spacing: 0) {
                    Text(event.monthShort)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(event.theme.accent)

                    Text(event.dayNumber)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
                .frame(width: 48, height: 48)
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Label(event.category.title, systemImage: event.category.icon)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.22))
                        .foregroundStyle(.white)
                        .clipShape(Capsule())

                    if event.isAttending {
                        Label("Going", systemImage: "checkmark.circle.fill")
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.white)
                            .foregroundStyle(event.theme.accent)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(12)
        }
        .frame(height: compact ? 76 : 88)
        .clipped()
    }

    private func detailLine(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption2)
                .foregroundStyle(event.theme.accent)
                .frame(width: 14)

            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }

    private var attendeeLine: some View {
        let known = store.connectionsAttending(event)

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text("\(event.totalAttendees) going")
                    .font(.caption.weight(.semibold))

                Text("·")
                    .foregroundStyle(.tertiary)

                Text(event.isFull ? "Full" : "\(event.spotsLeft) spots left")
                    .font(.caption)
                    .foregroundStyle(event.isFull ? .red : .secondary)

                Spacer()

                Text(event.priceText)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(event.isFree ? .green : .primary)
            }

            if !known.isEmpty {
                HStack(spacing: 6) {
                    ForEach(known.prefix(3)) { connection in
                        AvatarView(initials: connection.initials, theme: connection.theme, size: 22)
                    }

                    Text(knownText(known))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }

    private func knownText(_ known: [Connection]) -> String {
        if known.count == 1 {
            return "\(known[0].name) is going"
        }
        return "\(known.count) people you've met are going"
    }

    private var footer: some View {
        HStack(spacing: 10) {
            Button {
                store.toggleAttendance(event)
            } label: {
                Text(event.isAttending ? "Going" : (event.isFull ? "Full" : "Attend"))
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
            }
            .buttonStyle(.borderedProminent)
            .tint(event.isAttending ? .green : event.theme.accent)
            .disabled(event.isFull && !event.isAttending)

            Button {
                store.toggleSaved(event)
            } label: {
                Image(systemName: event.isSaved ? "bookmark.fill" : "bookmark")
                    .font(.subheadline)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
            }
            .buttonStyle(.bordered)
        }
        .padding(.top, 2)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            EventCardView(event: Event.samples[0])
            EventCardView(event: Event.samples[1], compact: true)
        }
        .padding()
    }
    .environmentObject(AppStore())
}
