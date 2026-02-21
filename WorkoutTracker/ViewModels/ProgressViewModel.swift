import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class ProgressViewModel {
    private let modelContext: ModelContext

    var completedSessions: [WorkoutSession] = []
    var allExercises: [Exercise] = []

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }

    func fetchData() {
        let sessionDescriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        completedSessions = (try? modelContext.fetch(sessionDescriptor)) ?? []

        let exerciseDescriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        allExercises = (try? modelContext.fetch(exerciseDescriptor)) ?? []
    }

    var sessionsByMonth: [(key: String, sessions: [WorkoutSession])] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"

        let grouped = Dictionary(grouping: completedSessions) { session in
            formatter.string(from: session.date)
        }

        return grouped
            .map { (key: $0.key, sessions: $0.value.sorted { $0.date > $1.date }) }
            .sorted { lhs, rhs in
                guard let lDate = lhs.sessions.first?.date,
                      let rDate = rhs.sessions.first?.date else { return false }
                return lDate > rDate
            }
    }

    func completedSets(for exercise: Exercise) -> [ExerciseSet] {
        exercise.sets
            .filter { $0.isCompleted && $0.session?.isCompleted == true }
            .sorted { ($0.session?.date ?? .distantPast) < ($1.session?.date ?? .distantPast) }
    }

    func personalBest(for exercise: Exercise) -> ExerciseSet? {
        let completed = completedSets(for: exercise)
        return completed
            .filter { $0.reps >= exercise.targetRepsMax }
            .max { $0.weight < $1.weight }
    }

    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let weight: Double
    }

    func chartData(for exercise: Exercise) -> [ChartDataPoint] {
        let sets = completedSets(for: exercise)

        // Group by session date and take max weight per session
        let grouped = Dictionary(grouping: sets) { set in
            Calendar.current.startOfDay(for: set.session?.date ?? .now)
        }

        return grouped
            .compactMap { date, sets in
                guard let maxWeight = sets.map(\.weight).max(), maxWeight > 0 else { return nil }
                return ChartDataPoint(date: date, weight: maxWeight)
            }
            .sorted { $0.date < $1.date }
    }
}
