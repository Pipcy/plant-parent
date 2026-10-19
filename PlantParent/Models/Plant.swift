import Foundation
import SwiftData

@Model
final class Plant {
    var name: String
    var species: String = ""
    var scientificName: String = ""
    var speciesReferenceID: Int?
    var acquiredOn: Date
    var purchasePrice: Double?
    var plantNotes: String
    var careInstructions: String = ""
    @Attribute(.externalStorage) var photoData: Data?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CareEvent.plant)
    var careEvents: [CareEvent] = []

    @Relationship(deleteRule: .cascade, inverse: \ProgressPhoto.plant)
    var progressPhotos: [ProgressPhoto] = []

    init(
        name: String,
        species: String = "",
        scientificName: String = "",
        speciesReferenceID: Int? = nil,
        acquiredOn: Date = .now,
        purchasePrice: Double? = nil,
        notes: String = "",
        careInstructions: String = "",
        photoData: Data? = nil,
        createdAt: Date = .now
    ) {
        self.name = name
        self.species = species
        self.scientificName = scientificName
        self.speciesReferenceID = speciesReferenceID
        self.acquiredOn = acquiredOn
        self.purchasePrice = purchasePrice
        self.plantNotes = notes
        self.careInstructions = careInstructions
        self.photoData = photoData
        self.createdAt = createdAt
    }

    var daysOwned: Int {
        daysOwned(asOf: .now)
    }

    func daysOwned(asOf date: Date, calendar: Calendar = .current) -> Int {
        let start = calendar.startOfDay(for: acquiredOn)
        let end = calendar.startOfDay(for: date)
        return max(0, calendar.dateComponents([.day], from: start, to: end).day ?? 0)
    }

    func latestEvent(of type: CareEventType) -> CareEvent? {
        careEvents
            .filter { $0.type == type }
            .max { $0.date < $1.date }
    }
}
