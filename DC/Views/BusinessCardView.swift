import SwiftUI

struct BusinessCardView: View {
    let profile: UserProfile
    var compact = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                avatar

                Spacer()

                Image(systemName: "wave.3.right")
                    .font(compact ? .body : .title2)
                    .foregroundStyle(.white.opacity(0.9))
            }

            Spacer(minLength: compact ? 18 : 34)

            Text(profile.name)
                .font(.system(size: compact ? 22 : 29, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            if !profile.jobLine.isEmpty {
                Text(profile.jobLine)
                    .font(compact ? .caption : .subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.top, 4)
            }

            if !compact, !profile.bio.isEmpty {
                Text(profile.bio)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
                    .lineLimit(3)
                    .padding(.top, 18)
            }

            if !compact, profile.showContactDetails {
                Divider()
                    .overlay(.white.opacity(0.3))
                    .padding(.vertical, 18)

                VStack(alignment: .leading, spacing: 10) {
                    contactLine(icon: "envelope.fill", text: profile.email)
                    contactLine(icon: "phone.fill", text: profile.phone)
                    contactLine(icon: "globe", text: profile.website)
                    contactLine(icon: "location.fill", text: profile.location)
                }
            }
        }
        .padding(compact ? 18 : 24)
        .frame(maxWidth: .infinity, minHeight: compact ? 170 : 390, alignment: .topLeading)
        .background(profile.theme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: compact ? 22 : 28, style: .continuous))
        .shadow(color: profile.theme.accent.opacity(0.3), radius: compact ? 12 : 22, y: compact ? 6 : 12)
    }

    private var avatar: some View {
        let size: CGFloat = compact ? 50 : 76

        return ZStack {
            Circle().fill(.white.opacity(0.2))

            if let image = profile.photoData.flatMap(UIImage.init(data:)) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } else {
                Text(profile.initials)
                    .font(.system(size: compact ? 20 : 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: size, height: size)
    }

    private func contactLine(icon: String, text: String) -> some View {
        Group {
            if !text.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .frame(width: 18)
                    Text(text)
                        .lineLimit(1)
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.92))
            }
        }
    }
}

func normalizedURL(from value: String) -> URL? {
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nil }
    if let url = URL(string: trimmed), url.scheme != nil {
        return url
    }
    return URL(string: "https://\(trimmed)")
}

#Preview {
    VStack(spacing: 20) {
        BusinessCardView(profile: .sample, compact: true)
        BusinessCardView(profile: .sample)
    }
    .padding()
}
