import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class WorkoutViewModel {
    private let modelContext: ModelContext

    var workoutDays: [WorkoutDay] = []
    var recentSessions: [WorkoutSession] = []
    var incompleteSession: WorkoutSession?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchData()
    }

    func fetchData() {
        fetchWorkoutDays()
        fetchRecentSessions()
        fetchIncompleteSession()
    }

    private func fetchWorkoutDays() {
        let descriptor = FetchDescriptor<WorkoutDay>(
            sortBy: [SortDescriptor(\.sortOrder)]
        )
        workoutDays = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func fetchRecentSessions() {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate { $0.isCompleted },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 20
        recentSessions = (try? modelContext.fetch(descriptor)) ?? []
    }

    var nextWorkoutDay: WorkoutDay? {
        let lastSortOrder = recentSessions.first?.workoutDay?.sortOrder
        let nextSortOrder = WorkoutPlan.nextDay(after: lastSortOrder)
        return workoutDays.first { $0.sortOrder == nextSortOrder }
    }

    var lastSession: WorkoutSession? {
        recentSessions.first
    }

    var completedSessionsThisWeek: Int {
        let calendar = Calendar.current
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: .now)?.start ?? .now
        return recentSessions.filter { $0.date >= startOfWeek }.count
    }

    var currentStreak: Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: .now)

        let sessionDates = Set(recentSessions.map { calendar.startOfDay(for: $0.date) })

        // Check today and go backwards
        while sessionDates.contains(checkDate) || (streak == 0 && !sessionDates.contains(checkDate)) {
            if sessionDates.contains(checkDate) {
                streak += 1
            } else if streak > 0 {
                break
            }
            guard let previous = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previous
            // Prevent infinite loop if no sessions exist
            if streak == 0 && checkDate < (recentSessions.last?.date ?? .now) {
                break
            }
        }
        return streak
    }

    var totalCompletedSessions: Int {
        recentSessions.count
    }

    private func fetchIncompleteSession() {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { !$0.isCompleted },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        incompleteSession = try? modelContext.fetch(descriptor).first
    }

    func discardIncompleteSession() {
        guard let session = incompleteSession else { return }
        modelContext.delete(session)
        try? modelContext.save()
        incompleteSession = nil
    }
}
