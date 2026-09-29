import SwiftUI

struct EventEditorView: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss

    @State private var draft: Event
    @State private var hasEndTime: Bool
    @State private var newTopic = ""
    private let isNew: Bool

    init(event: Event? = nil) {
        let existing = event ?? Event(
            title: "",
            startDate: Calendar.current.date(byAdding: .day, value: 7, to: .now) ?? .now,
            isHostedByMe: true
        )

        _draft = State(initialValue: existing)
        _hasEndTime = State(initialValue: existing.endDate != nil)
        isNew = event == nil
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    TextField("Title", text: $draft.title)

                    Picker("Category", selection: $draft.category) {
                        ForEach(EventCategory.allCases) { category in
                            Label(category.title, systemImage: category.icon).tag(category)
                        }
                    }

                    Picker("Format", selection: $draft.format) {
                        ForEach(EventFormat.allCases) { format in
                            Label(format.title, systemImage: format.icon).tag(format)
                        }
                    }
                }

                Section("Description") {
                    TextField("What is this event about?", text: $draft.summary, axis: .vertical)
                        .lineLimit(4...10)
                }

                Section("When") {
                    DatePicker("Starts", selection: $draft.startDate)

                    Toggle("Set an end time", isOn: $hasEndTime)

                    if hasEndTime {
                        DatePicker(
                            "Ends",
                            selection: Binding(
                                get: { draft.endDate ?? draft.startDate.addingTimeInterval(3600 * 2) },
                                set: { draft.endDate = $0 }
                            )
                        )
                    }
                }

                Section("Where") {
                    TextField("Venue", text: $draft.venue)
                    TextField("City", text: $draft.city)
                }

                Section("Details") {
                    TextField("Organizer", text: $draft.organizerName)
                    TextField("Price (e.g. Free, $25)", text: $draft.priceText)

                    Stepper("Capacity: \(draft.capacity)", value: $draft.capacity, in: 1...5000, step: 5)
                }

                Section {
                    ForEach(draft.topics, id: \.self) { topic in
                        Text(topic)
                    }
                    .onDelete { draft.topics.remove(atOffsets: $0) }

                    HStack {
                        TextField("Add a topic", text: $newTopic)
                            .onSubmit(addTopic)

                        Button(action: addTopic) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .disabled(trimmedTopic.isEmpty)
                    }
                } header: {
                    Text("Topics")
                } footer: {
                    Text("Topics make your event easier to find in search.")
                }

                agendaSection

                Section("Card color") {
                    Picker("Color", selection: $draft.theme) {
                        ForEach(CardTheme.allCases) { theme in
                            Text(theme.title).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(isNew ? "Host an Event" : "Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(draft.title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var agendaSection: some View {
        Section {
            ForEach($draft.agenda) { $item in
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Time (e.g. 7:00 PM)", text: $item.time)
                        .font(.subheadline)
                    TextField("What happens", text: $item.title)
                    TextField("Speaker (optional)", text: $item.speaker)
                        .font(.subheadline)
                }
                .padding(.vertical, 4)
            }
            .onDelete { draft.agenda.remove(atOffsets: $0) }

            Button {
                draft.agenda.append(AgendaItem(time: "", title: ""))
            } label: {
                Label("Add Agenda Item", systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Agenda")
        } footer: {
            Text("Swipe left to delete.")
        }
    }

    private var trimmedTopic: String {
        newTopic.trimmingCharacters(in: .whitespaces)
    }

    private func addTopic() {
        let topic = trimmedTopic
        guard !topic.isEmpty, !draft.topics.contains(topic) else { return }
        draft.topics.append(topic)
        newTopic = ""
    }

    private func save() {
        if !hasEndTime {
            draft.endDate = nil
        }

        if draft.organizerName.trimmingCharacters(in: .whitespaces).isEmpty {
            draft.organizerName = store.profile.name
        }

        if isNew {
            draft.isHostedByMe = true
            draft.isAttending = true
            store.add(draft)
        } else {
            store.update(draft)
        }

        dismiss()
    }
}

#Preview {
    EventEditorView()
        .environmentObject(AppStore())
}
