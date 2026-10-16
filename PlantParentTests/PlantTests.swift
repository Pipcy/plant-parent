import XCTest
import ImageIO
@testable import PlantParent

final class PlantTests: XCTestCase {
    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }

    func testDaysOwnedCountsCalendarDays() throws {
        let acquired = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 10, day: 1))
        )
        let current = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 10, day: 11))
        )
        let plant = Plant(name: "Fern", acquiredOn: acquired)

        XCTAssertEqual(plant.daysOwned(asOf: current, calendar: calendar), 10)
    }

    func testDaysOwnedDoesNotBecomeNegative() throws {
        let acquired = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 10, day: 11))
        )
        let earlierDate = try XCTUnwrap(
            calendar.date(from: DateComponents(year: 2026, month: 10, day: 1))
        )
        let plant = Plant(name: "Fern", acquiredOn: acquired)

        XCTAssertEqual(plant.daysOwned(asOf: earlierDate, calendar: calendar), 0)
    }

    func testLatestEventReturnsNewestMatchingType() throws {
        let plant = Plant(name: "Fern")
        let olderWatering = CareEvent(type: .water, date: Date(timeIntervalSince1970: 100))
        let fertilizing = CareEvent(type: .fertilize, date: Date(timeIntervalSince1970: 300))
        let newerWatering = CareEvent(type: .water, date: Date(timeIntervalSince1970: 200))
        plant.careEvents = [olderWatering, fertilizing, newerWatering]

        XCTAssertTrue(plant.latestEvent(of: .water) === newerWatering)
        XCTAssertTrue(plant.latestEvent(of: .fertilize) === fertilizing)
    }

    func testFertilizeUsesFeedWordingWithoutChangingPersistedValue() {
        XCTAssertEqual(CareEventType.fertilize.title, "Feed")
        XCTAssertEqual(CareEventType.fertilize.pastTenseTitle, "Fed")
        XCTAssertEqual(CareEventType.fertilize.rawValue, "fertilize")

        let event = CareEvent(type: .fertilize)
        XCTAssertEqual(event.typeRawValue, "fertilize")
        XCTAssertEqual(event.type, .fertilize)
    }

    func testRepotCareEventWordingAndPersistence() {
        XCTAssertEqual(CareEventType.repot.title, "Repot")
        XCTAssertEqual(CareEventType.repot.pastTenseTitle, "Repotted")
        XCTAssertEqual(CareEventType.repot.rawValue, "repot")

        let event = CareEvent(type: .repot)
        XCTAssertEqual(event.typeRawValue, "repot")
        XCTAssertEqual(event.type, .repot)
    }

    func testCaptureDateUsesPhotoMetadataAndTimezone() throws {
        let metadata: [String: Any] = [
            kCGImagePropertyExifDictionary as String: [
                kCGImagePropertyExifDateTimeOriginal as String: "2024:06:15 08:30:00",
                kCGImagePropertyExifOffsetTimeOriginal as String: "-07:00"
            ]
        ]

        let captureDate = try XCTUnwrap(ImageMetadata.captureDate(from: metadata))
        var utcCalendar = Calendar(identifier: .gregorian)
        utcCalendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let components = utcCalendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: captureDate
        )

        XCTAssertEqual(components.year, 2024)
        XCTAssertEqual(components.month, 6)
        XCTAssertEqual(components.day, 15)
        XCTAssertEqual(components.hour, 15)
        XCTAssertEqual(components.minute, 30)
    }
}
