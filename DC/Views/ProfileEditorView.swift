import PhotosUI
import SwiftUI

struct ProfileEditorView: View {
    @Binding var profile: UserProfile
    @Environment(\.dismiss) private var dismiss

    @State private var draft: UserProfile
    @State private var photoItem: PhotosPickerItem?
    @State private var bannerItem: PhotosPickerItem?

    init(profile: Binding<UserProfile>) {
        _profile = profile
        _draft = State(initialValue: profile.wrappedValue)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Photos") {
                    photoRow
                    bannerRow
                }

                Section("Basics") {
                    TextField("Full name", text: $draft.name)
                    TextField("Username", text: $draft.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Job title", text: $draft.role)
                    TextField("Company", text: $draft.company)
                    TextField("Location", text: $draft.location)
                }

                Section {
                    TextField("Headline", text: $draft.bio, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text("Headline")
                } footer: {
                    Text("One line that shows under your name and on your card.")
                }

                Section("About") {
                    TextField("Tell people who you are", text: $draft.about, axis: .vertical)
                        .lineLimit(5...12)
                }

                ExperienceEditorSection(items: $draft.experience)
                educationSection
                SkillsEditorSection(skills: $draft.skills)

                Section("Contact") {
                    TextField("Email", text: $draft.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    TextField("Phone", text: $draft.phone)
                        .keyboardType(.phonePad)
                    TextField("Website", text: $draft.website)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                }

                Section("Card style") {
                    themePicker
                    Toggle("Show contact details on card", isOn: $draft.showContactDetails)
                }

                Section {
                    ForEach($draft.links) { $link in
                        LinkEditorRow(link: $link)
                    }
                    .onDelete { draft.links.remove(atOffsets: $0) }
                    .onMove { draft.links.move(fromOffsets: $0, toOffset: $1) }

                    Button {
                        draft.links.append(BusinessLink(title: "", url: "", icon: "link"))
                    } label: {
                        Label("Add Link", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text("Links")
                } footer: {
                    Text("Swipe left to delete. Drag to rearrange.")
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        profile = draft
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onChange(of: photoItem) { _, item in
                Task {
                    if let data = await ImageLoader.data(from: item, maxDimension: 600) {
                        draft.photoData = data
                    }
                }
            }
            .onChange(of: bannerItem) { _, item in
                Task {
                    if let data = await ImageLoader.data(from: item, maxDimension: 1400) {
                        draft.bannerData = data
                    }
                }
            }
        }
    }

    // MARK: - Education

    private var educationSection: some View {
        Section {
            ForEach($draft.education) { $entry in
                VStack(alignment: .leading, spacing: 8) {
                    TextField("School", text: $entry.school)
                    TextField("Degree", text: $entry.degree)
                        .font(.subheadline)
                    TextField("Years (e.g. 2014 – 2018)", text: $entry.years)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
            .onDelete { draft.education.remove(atOffsets: $0) }

            Button {
                draft.education.append(Education(school: ""))
            } label: {
                Label("Add School", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Education")
        } footer: {
            Text("Swipe left to delete.")
        }
    }

    // MARK: - Photos

    private var photoRow: some View {
        HStack(spacing: 14) {
            AvatarView(
                initials: draft.initials,
                theme: draft.theme,
                photoData: draft.photoData,
                size: 56
            )

            VStack(alignment: .leading, spacing: 4) {
                Text("Profile photo")
                    .font(.subheadline.weight(.semibold))

                HStack(spacing: 12) {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Text(draft.photoData == nil ? "Choose" : "Replace")
                            .font(.caption.weight(.semibold))
                    }

                    if draft.photoData != nil {
                        Button("Remove", role: .destructive) {
                            draft.photoData = nil
                            photoItem = nil
                        }
                        .font(.caption.weight(.semibold))
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }

    private var bannerRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Banner")
                .font(.subheadline.weight(.semibold))

            ZStack {
                if let image = draft.bannerData.flatMap(UIImage.init(data:)) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    draft.theme.gradient
                }
            }
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            HStack(spacing: 12) {
                PhotosPicker(selection: $bannerItem, matching: .images) {
                    Text(draft.bannerData == nil ? "Choose image" : "Replace image")
                        .font(.caption.weight(.semibold))
                }

                if draft.bannerData != nil {
                    Button("Use theme color", role: .destructive) {
                        draft.bannerData = nil
                        bannerItem = nil
                    }
                    .font(.caption.weight(.semibold))
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var themePicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(CardTheme.allCases) { theme in
                    Button {
                        draft.theme = theme
                    } label: {
                        VStack(spacing: 7) {
                            Circle()
                                .fill(theme.gradient)
                                .frame(width: 48, height: 48)
                                .overlay {
                                    if draft.theme == theme {
                                        Image(systemName: "checkmark")
                                            .font(.headline.bold())
                                            .foregroundStyle(.white)
                                    }
                                }

                            Text(theme.title)
                                .font(.caption2)
                                .foregroundStyle(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.vertical, 4)
        }
    }
}

private struct LinkEditorRow: View {
    @Binding var link: BusinessLink

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Menu {
                    ForEach(BusinessLink.availableIcons, id: \.self) { icon in
                        Button {
                            link.icon = icon
                        } label: {
                            Label(iconName(icon), systemImage: icon)
                        }
                    }
                } label: {
                    Image(systemName: link.icon)
                        .frame(width: 36, height: 36)
                        .background(Color.accentColor.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }

                TextField("Link title", text: $link.title)
            }

            TextField("https://example.com", text: $link.url)
                .font(.subheadline)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.vertical, 4)
    }

    private func iconName(_ icon: String) -> String {
        switch icon {
        case "globe": "Website"
        case "briefcase.fill": "Portfolio"
        case "camera.fill": "Photos"
        case "play.rectangle.fill": "Video"
        case "music.note": "Music"
        case "bubble.left.fill": "Social"
        case "doc.text.fill": "Resume"
        default: "Link"
        }
    }
}

enum ImageLoader {
    static func data(from item: PhotosPickerItem?, maxDimension: CGFloat) async -> Data? {
        guard let item,
              let raw = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: raw) else { return nil }

        return downscaled(image, maxDimension: maxDimension).jpegData(compressionQuality: 0.8)
    }

    private static func downscaled(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let longestSide = max(image.size.width, image.size.height)
        guard longestSide > maxDimension else { return image }

        let scale = maxDimension / longestSide
        let target = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        return UIGraphicsImageRenderer(size: target).image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
    }
}

#Preview {
    ProfileEditorView(profile: .constant(.sample))
}
