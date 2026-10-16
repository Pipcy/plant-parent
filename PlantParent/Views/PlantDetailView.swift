import SwiftData
import SwiftUI

struct PlantDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Bindable var plant: Plant

    @State private var isEditing = false
    @State private var isLoggingCare = false
    @State private var isAddingProgressPhoto = false
    @State private var logType: CareEventType = .water
    @State private var isConfirmingDelete = false

    var body: some View {
        List {
            Section {
                VStack(spacing: 14) {
                    PlantPhotoView(data: plant.photoData, size: 180)

                    VStack(spacing: 4) {
                        Text(plant.name)
                            .font(.title2.bold())
                        if !plant.species.isEmpty {
                            Text(plant.species)
                                .foregroundStyle(.secondary)
                        }
                        if !plant.scientificName.isEmpty,
                           plant.scientificName != plant.species {
                            Text(plant.scientificName)
                                .font(.subheadline)
                                .italic()
                                .foregroundStyle(.secondary)
                        }
                        Text(ownedText)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .listRowBackground(Color.clear)
            }

            Section("Care") {
                VStack(spacing: 12) {
                    careButton(for: .water, color: .blue)

                    HStack(spacing: 12) {
                        careButton(for: .fertilize, color: .green)
                        careButton(for: .repot, color: .orange)
                    }
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

                careSummary(for: .water)
                careSummary(for: .fertilize)
                careSummary(for: .repot)

                Button {
                    logType = .water
                    isLoggingCare = true
                } label: {
                    Label("Log a Different Date", systemImage: "calendar.badge.plus")
                }
            }

            Section("Care Instruction") {
                TextEditor(text: $plant.careInstructions)
                    .frame(minHeight: 110)
                    .overlay(alignment: .topLeading) {
                        if plant.careInstructions.isEmpty {
                            Text("Add care instructions…")
                                .foregroundStyle(.tertiary)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                                .allowsHitTesting(false)
                        }
                    }
                    .accessibilityLabel("Care instructions")
            }

            Section("Progress Photos") {
                if plant.progressPhotos.isEmpty {
                    ContentUnavailableView {
                        Label("No Progress Photos", systemImage: "camera")
                    } description: {
                        Text("Take dated photos to follow \(plant.name)'s growth.")
                    }
                } else {
                    ProgressPhotoGalleryView(photos: plant.progressPhotos)
                }

                Button {
                    isAddingProgressPhoto = true
                } label: {
                    Label("Add Progress Photo", systemImage: "camera.fill")
                }
            }

            if !plant.plantNotes.isEmpty {
                Section("Notes") {
                    Text(plant.plantNotes)
                }
            }

            Section("Care History") {
                if sortedEvents.isEmpty {
                    Text("No care logged yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedEvents) { event in
                        CareEventRow(event: event)
                            .swipeActions {
                                Button("Delete", role: .destructive) {
                                    modelContext.delete(event)
                                }
                            }
                    }
                }
            }

            Section {
                Button("Delete Plant", role: .destructive) {
                    isConfirmingDelete = true
                }
            }
        }
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            NavigationStack {
                PlantFormView(plant: plant)
            }
        }
        .sheet(isPresented: $isLoggingCare) {
            NavigationStack {
                CareLogView(plant: plant, initialType: logType)
            }
        }
        .sheet(isPresented: $isAddingProgressPhoto) {
            NavigationStack {
                ProgressPhotoFormView(plant: plant)
            }
        }
        .confirmationDialog(
            "Delete \(plant.name)?",
            isPresented: $isConfirmingDelete,
            titleVisibility: .visible
        ) {
            Button("Delete Plant", role: .destructive) {
                modelContext.delete(plant)
                dismiss()
            }
        } message: {
            Text("This also deletes all of its care history. This action cannot be undone.")
        }
    }

    private var sortedEvents: [CareEvent] {
        plant.careEvents.sorted { $0.date > $1.date }
    }

    private var ownedText: String {
        let days = plant.daysOwned
        return "Owned for \(days) \(days == 1 ? "day" : "days")"
    }

    private func careButton(for type: CareEventType, color: Color) -> some View {
        Button {
            log(type, on: .now)
        } label: {
            HStack {
                Image(systemName: type.systemImage)
                    .foregroundStyle(color)
                Text(type.title)
                    .foregroundStyle(.white)
            }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        }
        .buttonStyle(.borderedProminent)
        .tint(careButtonBackground)
        .accessibilityHint("Logs this care action for today")
    }

    private var careButtonBackground: Color {
        if colorScheme == .dark {
            Color(red: 0.13, green: 0.25, blue: 0.17)
        } else {
            Color(red: 0.39, green: 0.51, blue: 0.37)
        }
    }

    private func careSummary(for type: CareEventType) -> some View {
        HStack {
            Label(type.pastTenseTitle, systemImage: type.systemImage)
            Spacer()
            if let date = plant.latestEvent(of: type)?.date {
                Text(date, format: .dateTime.month(.abbreviated).day().year())
                    .foregroundStyle(.secondary)
            } else {
                Text("Never")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func log(_ type: CareEventType, on date: Date) {
        let event = CareEvent(type: type, date: date)
        modelContext.insert(event)
        plant.careEvents.append(event)
    }
}

private struct CareEventRow: View {
    let event: CareEvent

    var body: some View {
        Label {
            HStack {
                Text(event.type.pastTenseTitle)
                Spacer()
                Text(event.date, format: .dateTime.month(.abbreviated).day().year())
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: event.type.systemImage)
                .foregroundStyle(eventColor)
        }
    }

    private var eventColor: Color {
        switch event.type {
        case .water: .blue
        case .fertilize: .green
        case .repot: .orange
        }
    }
}
