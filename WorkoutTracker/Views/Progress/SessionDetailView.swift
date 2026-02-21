import SwiftUI

struct SessionDetailView: View {
    let session: WorkoutSession

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Date")
                    Spacer()
                    Text(session.date, style: .date)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text("Day")
                    Spacer()
                    Text(session.workoutDay?.name ?? "Unknown")
                        .foregroundStyle(.secondary)
                }
                if let notes = session.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            let grouped = exerciseGroups
            ForEach(grouped, id: \.exercise.id) { group in
                Section(group.exercise.name) {
                    ForEach(group.sets) { set in
                        HStack {
                            Text("Set \(set.setNumber)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .frame(width: 50, alignment: .leading)
                            Spacer()
                            if set.isCompleted {
                                Text("\(Int(set.weight)) lbs")
                                    .font(.subheadline.bold())
                                Text("x \(set.reps)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .font(.caption)
                            } else {
                                Text("Incomplete")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(session.workoutDay?.name ?? "Session")
        .navigationBarTitleDisplayMode(.inline)
    }

    private struct ExerciseGroup {
        let exercise: Exercise
        let sets: [ExerciseSet]
    }

    private var exerciseGroups: [ExerciseGroup] {
        let sortedSets = session.sets.sorted {
            if ($0.exercise?.sortOrder ?? 0) != ($1.exercise?.sortOrder ?? 0) {
                return ($0.exercise?.sortOrder ?? 0) < ($1.exercise?.sortOrder ?? 0)
            }
            return $0.setNumber < $1.setNumber
        }

        var groups: [ExerciseGroup] = []
        var currentExercise: Exercise?
        var currentSets: [ExerciseSet] = []

        for set in sortedSets {
            guard let exercise = set.exercise else { continue }
            if exercise.id != currentExercise?.id {
                if let prev = currentExercise {
                    groups.append(ExerciseGroup(exercise: prev, sets: currentSets))
                }
                currentExercise = exercise
                currentSets = [set]
            } else {
                currentSets.append(set)
            }
        }
        if let last = currentExercise {
            groups.append(ExerciseGroup(exercise: last, sets: currentSets))
        }
        return groups
    }
}
