import PhotosUI
import SwiftData
import SwiftUI

struct PlantFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let plant: Plant?
    @State private var name: String
    @State private var species: String
    @State private var scientificName: String
    @State private var acquiredOn: Date
    @State private var purchasePriceText: String
    @State private var notes: String
    @State private var photoData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    init(plant: Plant? = nil) {
        self.plant = plant
        _name = State(initialValue: plant?.name ?? "")
        _species = State(initialValue: plant?.species ?? "")
        _scientificName = State(initialValue: plant?.scientificName ?? "")
        _acquiredOn = State(initialValue: plant?.acquiredOn ?? .now)
        _purchasePriceText = State(
            initialValue: plant?.purchasePrice?.formatted(
                .number.precision(.fractionLength(0...2))
            ) ?? ""
        )
        _notes = State(initialValue: plant?.plantNotes ?? "")
        _photoData = State(initialValue: plant?.photoData)
    }

    var body: some View {
        Form {
            Section {
                HStack {
                    Spacer()
                    PlantPhotoView(data: photoData, size: 140)
                    Spacer()
                }
                .listRowBackground(Color.clear)

                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Label(
                        photoData == nil ? "Choose Photo" : "Change Photo",
                        systemImage: "photo"
                    )
                }

                if photoData != nil {
                    Button("Remove Photo", role: .destructive) {
                        photoData = nil
                        selectedPhoto = nil
                    }
                }
            }

            Section("Plant") {
                TextField("Name", text: $name)
                    .textInputAutocapitalization(.words)

                TextField("Species", text: $species)
                    .textInputAutocapitalization(.words)

                TextField("Scientific Name (Optional)", text: $scientificName)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()

                DatePicker(
                    "Date Acquired",
                    selection: $acquiredOn,
                    in: ...Date.now,
                    displayedComponents: .date
                )

                TextField("Purchase Price", text: $purchasePriceText)
                    .keyboardType(.decimalPad)
            }

            Section("Notes") {
                TextField("Optional notes", text: $notes, axis: .vertical)
                    .lineLimit(3...8)
            }
        }
        .navigationTitle(plant == nil ? "Add Plant" : "Edit Plant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .disabled(trimmedName.isEmpty || !isPriceValid)
            }
        }
        .onChange(of: selectedPhoto) {
            loadSelectedPhoto()
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var parsedPurchasePrice: Double? {
        let text = purchasePriceText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        return formatter.number(from: text)?.doubleValue
    }

    private var isPriceValid: Bool {
        purchasePriceText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || (parsedPurchasePrice.map { $0 >= 0 } ?? false)
    }

    private func save() {
        if let plant {
            plant.name = trimmedName
            plant.species = species.trimmingCharacters(in: .whitespacesAndNewlines)
            plant.scientificName = scientificName.trimmingCharacters(in: .whitespacesAndNewlines)
            plant.speciesReferenceID = nil
            plant.acquiredOn = acquiredOn
            plant.purchasePrice = parsedPurchasePrice
            plant.plantNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
            plant.photoData = photoData
        } else {
            let newPlant = Plant(
                name: trimmedName,
                species: species.trimmingCharacters(in: .whitespacesAndNewlines),
                scientificName: scientificName.trimmingCharacters(in: .whitespacesAndNewlines),
                acquiredOn: acquiredOn,
                purchasePrice: parsedPurchasePrice,
                notes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
                photoData: photoData
            )
            modelContext.insert(newPlant)
        }

        dismiss()
    }

    private func loadSelectedPhoto() {
        guard let selectedPhoto else { return }

        Task {
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                await MainActor.run {
                    photoData = data
                }
            }
        }
    }
}
