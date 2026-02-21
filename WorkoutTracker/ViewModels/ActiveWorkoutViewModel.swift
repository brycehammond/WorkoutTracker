import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class ActiveWorkoutViewModel {
    private let modelContext: ModelContext
    let workoutDay: WorkoutDay

    var session: WorkoutSession?
    var exerciseSets: [Exercise: [ExerciseSet]] = [:]
    var skippedExercises: Set<UUID> = []

    // Rest timer
    var isRestTimerRunning = false
    var restTimeRemaining: Int = Constants.defaultRestTimerSeconds
    var restTimerDuration: Int = Constants.defaultRestTimerSeconds
    private var restTimerTask: Task<Void, Never>?

    // State
    var showWarmupReminder = true
    var showFinishConfirmation = false
    var showCancelConfirmation = false

    init(modelContext: ModelContext, workoutDay: WorkoutDay) {
        self.modelContext = modelContext
        self.workoutDay = workoutDay

        let savedDuration = UserDefaults.standard.integer(forKey: "restTimerDuration")
        if savedDuration > 0 {
            self.restTimerDuration = savedDuration
            self.restTimeRemaining = savedDuration
        }
    }

    func startWorkout() {
        let newSession = WorkoutSession(workoutDay: workoutDay)
        modelContext.insert(newSession)
        session = newSession

        for exercise in workoutDay.sortedExercises {
            var sets: [ExerciseSet] = []
            let lastWeightAndReps = lastSessionData(for: exercise)

            for setNum in 1...exercise.targetSets {
                let set = ExerciseSet(
                    exercise: exercise,
                    session: newSession,
                    setNumber: setNum,
                    weight: lastWeightAndReps[setNum - 1]?.weight ?? 0,
                    reps: lastWeightAndReps[setNum - 1]?.reps ?? exercise.targetRepsMax
                )
                modelContext.insert(set)
                sets.append(set)
            }
            exerciseSets[exercise] = sets
        }
        try? modelContext.save()
    }

    private func lastSessionData(for exercise: Exercise) -> [Int: (weight: Double, reps: Int)] {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { session in
                session.isCompleted
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 5

        guard let sessions = try? modelContext.fetch(descriptor) else { return [:] }

        for pastSession in sessions {
            guard pastSession.workoutDay?.id == workoutDay.id else { continue }
            let pastSets = pastSession.sets
                .filter { $0.exercise?.id == exercise.id && $0.isCompleted }
                .sorted { $0.setNumber < $1.setNumber }

            if !pastSets.isEmpty {
                var result: [Int: (weight: Double, reps: Int)] = [:]
                for set in pastSets {
                    result[set.setNumber - 1] = (weight: set.weight, reps: set.reps)
                }
                return result
            }
        }
        return [:]
    }

    func setsForExercise(_ exercise: Exercise) -> [ExerciseSet] {
        (exerciseSets[exercise] ?? []).sorted { $0.setNumber < $1.setNumber }
    }

    func completeSet(_ set: ExerciseSet) {
        set.isCompleted = true
        set.completedAt = .now
        try? modelContext.save()

        // Start rest timer
        startRestTimer()
    }

    func uncompleteSet(_ set: ExerciseSet) {
        set.isCompleted = false
        set.completedAt = nil
        try? modelContext.save()
    }

    func skipExercise(_ exercise: Exercise) {
        skippedExercises.insert(exercise.id)
    }

    func unskipExercise(_ exercise: Exercise) {
        skippedExercises.remove(exercise.id)
    }

    func isExerciseSkipped(_ exercise: Exercise) -> Bool {
        skippedExercises.contains(exercise.id)
    }

    func finishWorkout() {
        guard let session else { return }
        session.isCompleted = true
        // Remove sets for skipped exercises
        for exercise in workoutDay.sortedExercises where isExerciseSkipped(exercise) {
            for set in setsForExercise(exercise) {
                modelContext.delete(set)
            }
        }
        try? modelContext.save()
        stopRestTimer()
    }

    func cancelWorkout() {
        if let session {
            modelContext.delete(session)
            try? modelContext.save()
        }
        stopRestTimer()
    }

    // MARK: - Rest Timer

    func startRestTimer() {
        stopRestTimer()
        restTimeRemaining = restTimerDuration
        isRestTimerRunning = true

        restTimerTask = Task {
            while restTimeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                restTimeRemaining -= 1
            }
            if !Task.isCancelled {
                isRestTimerRunning = false
            }
        }
    }

    func stopRestTimer() {
        restTimerTask?.cancel()
        restTimerTask = nil
        isRestTimerRunning = false
    }

    func dismissRestTimer() {
        stopRestTimer()
    }

    // MARK: - Progress Tracking

    var completedSetsCount: Int {
        exerciseSets.values.flatMap { $0 }.filter(\.isCompleted).count
    }

    var totalSetsCount: Int {
        let activeExercises = workoutDay.sortedExercises.filter { !isExerciseSkipped($0) }
        return activeExercises.reduce(0) { $0 + $1.targetSets }
    }

    var progress: Double {
        guard totalSetsCount > 0 else { return 0 }
        return Double(completedSetsCount) / Double(totalSetsCount)
    }

    // MARK: - Progression Detection

    func shouldSuggestWeightIncrease(for exercise: Exercise) -> Bool {
        let lastSets = lastCompletedSets(for: exercise)
        guard lastSets.count == exercise.targetSets else { return false }
        return lastSets.allSatisfy { $0.reps >= exercise.targetRepsMax }
    }

    func suggestedWeight(for exercise: Exercise) -> Double? {
        guard shouldSuggestWeightIncrease(for: exercise) else { return nil }
        let lastSets = lastCompletedSets(for: exercise)
        guard let maxWeight = lastSets.map(\.weight).max() else { return nil }
        let increment = UserDefaults.standard.double(forKey: "weightIncrement")
        let effectiveIncrement = increment > 0 ? increment : Constants.defaultWeightIncrement
        return maxWeight + effectiveIncrement
    }

    private func lastCompletedSets(for exercise: Exercise) -> [ExerciseSet] {
        var descriptor = FetchDescriptor<WorkoutSession>(
            predicate: #Predicate<WorkoutSession> { session in
                session.isCompleted
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        descriptor.fetchLimit = 5

        guard let sessions = try? modelContext.fetch(descriptor) else { return [] }

        for pastSession in sessions {
            guard pastSession.workoutDay?.id == workoutDay.id else { continue }
            let sets = pastSession.sets
                .filter { $0.exercise?.id == exercise.id && $0.isCompleted }
                .sorted { $0.setNumber < $1.setNumber }
            if !sets.isEmpty { return sets }
        }
        return []
    }
}
