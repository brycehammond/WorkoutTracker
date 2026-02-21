import Foundation
import SwiftData

@Model
final class WorkoutSession {
    var id: UUID
    var workoutDay: WorkoutDay?
    var date: Date
    var isCompleted: Bool
    var notes: String?

    @Relationship(deleteRule: .cascade, inverse: \ExerciseSet.session)
    var sets: [ExerciseSet] = []

    var sortedSets: [ExerciseSet] {
        sets.sorted {
            if $0.exercise?.sortOrder != $1.exercise?.sortOrder {
                return ($0.exercise?.sortOrder ?? 0) < ($1.exercise?.sortOrder ?? 0)
            }
            return $0.setNumber < $1.setNumber
        }
    }

    init(workoutDay: WorkoutDay, date: Date = .now) {
        self.id = UUID()
        self.workoutDay = workoutDay
        self.date = date
        self.isCompleted = false
    }
}
