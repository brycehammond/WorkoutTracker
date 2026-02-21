import Foundation
import SwiftData

@Model
final class ExerciseSet {
    var id: UUID
    var exercise: Exercise?
    var session: WorkoutSession?
    var setNumber: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var completedAt: Date?

    init(exercise: Exercise, session: WorkoutSession, setNumber: Int, weight: Double = 0, reps: Int = 0) {
        self.id = UUID()
        self.exercise = exercise
        self.session = session
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = false
    }
}
