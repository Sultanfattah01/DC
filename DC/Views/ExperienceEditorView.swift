import SwiftUI

struct ExperienceEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var draft: Experience

    private let isNew: Bool
    private let onSave: (Experience) -> Void

    init(experience: Experience? = nil, onSave: @escaping (Experience) -> Void) {
        _draft = State(initialValue: experience ?? Experience(title: "", company: ""))
        isNew = experience == nil
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Role") {
                    TextField("Job title", text: $draft.title)
                    TextField("Company", text: $draft.company)
                    TextField("Location", text: $draft.location)
                }

                Section {
                    TextField("Start year", text: $draft.startYear)
                        .keyboardType(.numberPad)
                    TextField("End year", text: $draft.endYear)
                        .keyboardType(.numberPad)
                } header: {
                    Text("Dates")
                } footer: {
                    Text("Leave the end year empty if this is your current role.")
                }

                Section("What you did") {
                    TextField("Summary", text: $draft.summary, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(isNew ? "Add Position" : "Edit Position")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(draft)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

struct ExperienceEditorSection: View {
    @Binding var items: [Experience]

    @State private var editingItem: Experience?
    @State private var isAdding = false

    var body: some View {
        Section {
            ForEach(items) { item in
                Button {
                    editingItem = item
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title.isEmpty ? "Untitled role" : item.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)

                        Text([item.company, item.dateRange].filter { !$0.isEmpty }.joined(separator: " · "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { items.remove(atOffsets: $0) }
            .onMove { items.move(fromOffsets: $0, toOffset: $1) }

            Button {
                isAdding = true
            } label: {
                Label("Add Position", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Experience")
        } footer: {
            Text("Tap a role to edit it. Swipe left to delete.")
        }
        .sheet(isPresented: $isAdding) {
            ExperienceEditorView { items.append($0) }
        }
        .sheet(item: $editingItem) { item in
            ExperienceEditorView(experience: item) { updated in
                guard let index = items.firstIndex(where: { $0.id == updated.id }) else { return }
                items[index] = updated
            }
        }
    }
}

struct SkillsEditorSection: View {
    @Binding var skills: [String]
    @State private var newSkill = ""

    var body: some View {
        Section {
            ForEach(skills, id: \.self) { skill in
                Text(skill)
            }
            .onDelete { skills.remove(atOffsets: $0) }

            HStack {
                TextField("Add a skill", text: $newSkill)
                    .onSubmit(addSkill)

                Button(action: addSkill) {
                    Image(systemName: "plus.circle.fill")
                }
                .disabled(trimmedSkill.isEmpty)
            }
        } header: {
            Text("Skills")
        } footer: {
            Text("Swipe left to remove a skill.")
        }
    }

    private var trimmedSkill: String {
        newSkill.trimmingCharacters(in: .whitespaces)
    }

    private func addSkill() {
        let skill = trimmedSkill
        guard !skill.isEmpty, !skills.contains(skill) else { return }
        skills.append(skill)
        newSkill = ""
    }
}

#Preview {
    ExperienceEditorView { _ in }
}
