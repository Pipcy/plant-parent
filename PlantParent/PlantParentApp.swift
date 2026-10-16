import SwiftData
import SwiftUI

@main
struct PlantParentApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Plant.self,
            CareEvent.self,
            ProgressPhoto.self
        ])

        do {
            return try ModelContainer(for: schema)
        } catch {
            fatalError("Could not create the model container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            PlantListView()
        }
        .modelContainer(sharedModelContainer)
    }
}
