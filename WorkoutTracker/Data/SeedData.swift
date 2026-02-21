import Foundation
import SwiftData

@MainActor
enum SeedData {
    static func seedIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<WorkoutDay>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        guard existingCount == 0 else { return }

        let push = createPushDay()
        let pull = createPullDay()
        let legs = createLegsDay()

        context.insert(push)
        context.insert(pull)
        context.insert(legs)

        try? context.save()
    }

    private static func createPushDay() -> WorkoutDay {
        let day = WorkoutDay(
            name: "Push",
            subtitle: "Chest, Shoulders, Triceps",
            dayLabel: "Day A",
            sortOrder: 0
        )
        day.exercises = [
            Exercise(name: "Chest Press Machine", sortOrder: 0,
                     sfSymbol: "figure.strengthtraining.traditional",
                     defaultWeight: 50,
                     imageName: "equipment-chest-press"),
            Exercise(name: "Pec Deck / Machine Fly", sortOrder: 1,
                     sfSymbol: "figure.arms.open",
                     defaultWeight: 40,
                     imageName: "equipment-pec-deck"),
            Exercise(name: "Shoulder Press Machine", sortOrder: 2,
                     sfSymbol: "figure.strengthtraining.traditional",
                     defaultWeight: 30,
                     imageName: "equipment-shoulder-press"),
            Exercise(name: "Lateral Raise Machine",
                     alternativeName: "or Cable Lateral Raises", sortOrder: 3,
                     sfSymbol: "figure.arms.open",
                     defaultWeight: 20,
                     imageName: "equipment-lateral-raise"),
            Exercise(name: "Tricep Pushdown", sortOrder: 4,
                     sfSymbol: "figure.strengthtraining.functional",
                     defaultWeight: 25,
                     imageName: "equipment-tricep-pushdown"),
            Exercise(name: "Assisted Dip Machine",
                     alternativeName: "if available", sortOrder: 5,
                     sfSymbol: "figure.strengthtraining.traditional",
                     defaultWeight: 30,
                     imageName: "equipment-assisted-dip"),
        ]
        return day
    }

    private static func createPullDay() -> WorkoutDay {
        let day = WorkoutDay(
            name: "Pull",
            subtitle: "Back, Biceps, Rear Delts",
            dayLabel: "Day B",
            sortOrder: 1
        )
        day.exercises = [
            Exercise(name: "Lat Pulldown", sortOrder: 0,
                     sfSymbol: "figure.strengthtraining.traditional",
                     defaultWeight: 50,
                     imageName: "equipment-lat-pulldown"),
            Exercise(name: "Seated Cable Row", sortOrder: 1,
                     sfSymbol: "figure.rowing",
                     defaultWeight: 40,
                     imageName: "equipment-seated-cable-row"),
            Exercise(name: "Rear Delt Fly Machine",
                     alternativeName: "Reverse Pec Deck", sortOrder: 2,
                     sfSymbol: "figure.arms.open",
                     defaultWeight: 30,
                     imageName: "equipment-rear-delt-fly"),
            Exercise(name: "Cable Face Pulls", sortOrder: 3,
                     sfSymbol: "figure.strengthtraining.functional",
                     defaultWeight: 15,
                     imageName: "equipment-face-pulls"),
            Exercise(name: "Bicep Curl Machine",
                     alternativeName: "or Cable Curls", sortOrder: 4,
                     sfSymbol: "figure.strengthtraining.functional",
                     defaultWeight: 25,
                     imageName: "equipment-bicep-curl"),
            Exercise(name: "Assisted Pull-Up Machine",
                     alternativeName: "if available", sortOrder: 5,
                     sfSymbol: "figure.strengthtraining.traditional",
                     defaultWeight: 30,
                     imageName: "equipment-assisted-pullup"),
        ]
        return day
    }

    private static func createLegsDay() -> WorkoutDay {
        let day = WorkoutDay(
            name: "Legs & Core",
            subtitle: "Quads, Hamstrings, Glutes, Core",
            dayLabel: "Day C",
            sortOrder: 2
        )
        day.exercises = [
            Exercise(name: "Leg Press", sortOrder: 0,
                     sfSymbol: "figure.strengthtraining.traditional",
                     defaultWeight: 90,
                     imageName: "equipment-leg-press"),
            Exercise(name: "Leg Extension", sortOrder: 1,
                     sfSymbol: "figure.walk",
                     defaultWeight: 40,
                     imageName: "equipment-leg-extension"),
            Exercise(name: "Leg Curl", sortOrder: 2,
                     sfSymbol: "figure.walk",
                     defaultWeight: 40,
                     imageName: "equipment-leg-curl"),
            Exercise(name: "Hip Adductor Machine", sortOrder: 3,
                     sfSymbol: "figure.flexibility",
                     defaultWeight: 40,
                     imageName: "equipment-hip-adductor"),
            Exercise(name: "Hip Abductor Machine", sortOrder: 4,
                     sfSymbol: "figure.flexibility",
                     defaultWeight: 40,
                     imageName: "equipment-hip-abductor"),
            Exercise(name: "Calf Raise Machine", sortOrder: 5,
                     sfSymbol: "figure.walk",
                     defaultWeight: 50,
                     imageName: "equipment-calf-raise"),
            Exercise(name: "Cable Crunch",
                     alternativeName: "or Ab Machine", sortOrder: 6,
                     sfSymbol: "figure.core.training",
                     defaultWeight: 30,
                     imageName: "equipment-cable-crunch"),
        ]
        return day
    }
}
