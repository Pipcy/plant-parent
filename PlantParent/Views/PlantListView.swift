import SwiftData
import SwiftUI

struct PlantListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.name) private var plants: [Plant]
    @State private var isAddingPlant = false

    var body: some View {
        NavigationStack {
            Group {
                if plants.isEmpty {
                    ContentUnavailableView {
                        Label("No Plants Yet", systemImage: "leaf")
                    } description: {
                        Text("Add your first plant to start tracking its care.")
                    } actions: {
                        Button("Add Plant") {
                            isAddingPlant = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                } else {
                    List {
                        ForEach(plants) { plant in
                            NavigationLink(value: plant) {
                                PlantRowView(plant: plant)
                            }
                        }
                        .onDelete(perform: deletePlants)
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("My Plants")
            .navigationDestination(for: Plant.self) { plant in
                PlantDetailView(plant: plant)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingPlant = true
                    } label: {
                        Label("Add Plant", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingPlant) {
                NavigationStack {
                    PlantFormView()
                }
            }
        }
        .tint(.green)
    }

    private func deletePlants(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(plants[index])
        }
    }
}

#Preview {
    PlantListView()
        .modelContainer(for: [Plant.self, CareEvent.self, ProgressPhoto.self], inMemory: true)
}
