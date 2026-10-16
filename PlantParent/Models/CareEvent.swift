import Foundation
import SwiftData

enum CareEventType: String, CaseIterable, Identifiable {
    case water
    case fertilize
    case repot

    var id: String { rawValue }

    var title: String {
        switch self {
        case .water: "Water"
        case .fertilize: "Feed"
        case .repot: "Repot"
        }
    }

    var pastTenseTitle: String {
        switch self {
        case .water: "Watered"
        case .fertilize: "Fed"
        case .repot: "Repotted"
        }
    }

    var systemImage: String {
        switch self {
        case .water: "drop.fill"
        case .fertilize: "leaf.fill"
        case .repot: "arrow.triangle.2.circlepath"
        }
    }
}

@Model
final class CareEvent {
    var typeRawValue: String
    var date: Date
    var createdAt: Date
    var plant: Plant?

    init(
        type: CareEventType,
        date: Date = .now,
        plant: Plant? = nil,
        createdAt: Date = .now
    ) {
        self.typeRawValue = type.rawValue
        self.date = date
        self.plant = plant
        self.createdAt = createdAt
    }

    var type: CareEventType {
        get { CareEventType(rawValue: typeRawValue) ?? .water }
        set { typeRawValue = newValue.rawValue }
    }
}
