import SwiftUI
import SwiftData

@main
struct WorkoutTrackerApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                WorkoutDay.self,
                Exercise.self,
                WorkoutSession.self,
                ExerciseSet.self,
            ])
            let config = ModelConfiguration(schema: schema)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    SeedData.seedIfNeeded(context: modelContainer.mainContext)
                }
        }
        .modelContainer(modelContainer)
    }
}
