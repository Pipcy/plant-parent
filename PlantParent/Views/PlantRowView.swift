import SwiftUI

struct PlantRowView: View {
    let plant: Plant

    var body: some View {
        HStack(spacing: 14) {
            PlantPhotoView(data: plant.photoData, size: 64)

            VStack(alignment: .leading, spacing: 5) {
                Text(plant.name)
                    .font(.headline)

                if !plant.species.isEmpty {
                    Text(plant.species)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text(ownedText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let lastWatered = plant.latestEvent(of: .water)?.date {
                    Label {
                        Text("Watered \(lastWatered, format: .relative(presentation: .named))")
                    } icon: {
                        Image(systemName: "drop.fill")
                            .foregroundStyle(.blue)
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                } else {
                    Text("Not watered yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var ownedText: String {
        let days = plant.daysOwned
        return "Owned for \(days) \(days == 1 ? "day" : "days")"
    }
}
