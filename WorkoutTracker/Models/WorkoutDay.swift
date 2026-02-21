import Foundation
import SwiftData

@Model
final class WorkoutDay {
    var id: UUID
    var name: String
    var subtitle: String
    var dayLabel: String
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \Exercise.workoutDay)
    var exercises: [Exercise] = []

    @Relationship(inverse: \WorkoutSession.workoutDay)
    var sessions: [WorkoutSession] = []

    var sortedExercises: [Exercise] {
        exercises.sorted { $0.sortOrder < $1.sortOrder }
    }

    var sortedSessions: [WorkoutSession] {
        sessions.sorted { $0.date > $1.date }
    }

    init(name: String, subtitle: String, dayLabel: String, sortOrder: Int) {
        self.id = UUID()
        self.name = name
        self.subtitle = subtitle
        self.dayLabel = dayLabel
        self.sortOrder = sortOrder
    }
}
