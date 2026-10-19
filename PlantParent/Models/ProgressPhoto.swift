import Foundation
import SwiftData

@Model
final class ProgressPhoto {
    @Attribute(.externalStorage) var imageData: Data
    var capturedOn: Date
    var photoNotes: String
    var createdAt: Date
    var plant: Plant?

    init(
        imageData: Data,
        capturedOn: Date = .now,
        notes: String = "",
        plant: Plant? = nil,
        createdAt: Date = .now
    ) {
        self.imageData = imageData
        self.capturedOn = capturedOn
        self.photoNotes = notes
        self.plant = plant
        self.createdAt = createdAt
    }
}
