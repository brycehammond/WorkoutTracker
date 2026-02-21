import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var alternativeName: String?
    var targetSets: Int
    var targetRepsMin: Int
    var targetRepsMax: Int
    var sortOrder: Int
    var sfSymbol: String
    var defaultWeight: Double
    var imageName: String?

    var workoutDay: WorkoutDay?

    @Relationship(inverse: \ExerciseSet.exercise)
    var sets: [ExerciseSet] = []

    var targetRepsRange: String {
        "\(targetRepsMin)-\(targetRepsMax)"
    }

    var displayName: String {
        if let alt = alternativeName {
            return "\(name) (\(alt))"
        }
        return name
    }

    init(
        name: String,
        alternativeName: String? = nil,
        targetSets: Int = Constants.defaultTargetSets,
        targetRepsMin: Int = Constants.defaultTargetRepsMin,
        targetRepsMax: Int = Constants.defaultTargetRepsMax,
        sortOrder: Int,
        sfSymbol: String = "dumbbell.fill",
        defaultWeight: Double = 0,
        imageName: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.alternativeName = alternativeName
        self.targetSets = targetSets
        self.targetRepsMin = targetRepsMin
        self.targetRepsMax = targetRepsMax
        self.sortOrder = sortOrder
        self.sfSymbol = sfSymbol
        self.defaultWeight = defaultWeight
        self.imageName = imageName
    }
}
