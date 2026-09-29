import SwiftUI

struct ConnectionEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Connection
    private let isNew: Bool

    init(connection: Connection? = nil) {
        _draft = State(initialValue: connection ?? Connection(name: ""))
        isNew = connection == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Who they are") {
                    TextField("Full name", text: $draft.name)
                    TextField("Job title", text: $draft.role)
                    TextField("Company", text: $draft.company)
                    TextField("Location", text: $draft.location)
                }

                Section {
                    Picker("Relationship", selection: $draft.tag) {
                        ForEach(ConnectionTag.allCases) { tag in
                            Label(tag.title, systemImage: tag.icon).tag(tag)
                        }
                    }

                    TextField("Where you met", text: $draft.metAt)

                    TextField("What you talked about", text: $draft.note, axis: .vertical)
                        .lineLimit(3...6)

                    Toggle("Favorite", isOn: $draft.isFavorite)
                } header: {
                    Text("How you met")
                } footer: {
                    Text("This is the part you'll forget first. Write it down while it's fresh.")
                }

                Section("About them") {
                    TextField("Background", text: $draft.about, axis: .vertical)
                        .lineLimit(3...8)
                }

                ExperienceEditorSection(items: $draft.experience)
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

                Section("Card color") {
                    Picker("Color", selection: $draft.theme) {
                        ForEach(CardTheme.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(isNew ? "Add Person" : "Edit Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(draft.name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        if isNew {
            store.add(draft)
        } else {
            store.update(draft)
        }
        dismiss()
    }
}

#Preview {
    ConnectionEditorView()
        .environmentObject(AppStore())
}
