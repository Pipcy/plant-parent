import SwiftData
import SwiftUI

struct CareLogView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let plant: Plant
    @State private var type: CareEventType
    @State private var date = Date.now

    init(plant: Plant, initialType: CareEventType) {
        self.plant = plant
        _type = State(initialValue: initialType)
    }

    var body: some View {
        Form {
            Section("Care Type") {
                Picker("Care Type", selection: $type) {
                    ForEach(CareEventType.allCases) { type in
                        Label(type.title, systemImage: type.systemImage)
                            .tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }

            Section("Date") {
                DatePicker(
                    "Care Date",
                    selection: $date,
                    in: ...Date.now,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        }
        .navigationTitle("Log Care")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }

            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
            }
        }
    }

    private func save() {
        let event = CareEvent(type: type, date: date)
        modelContext.insert(event)
        plant.careEvents.append(event)
        dismiss()
    }
}
