import SwiftUI

struct WorkoutDayListView: View {
    let workoutDay: WorkoutDay
    var onStartWorkout: () -> Void

    var body: some View {
        List {
            Section {
                ForEach(workoutDay.sortedExercises) { exercise in
                    exerciseRow(exercise)
                }
            } header: {
                Text("\(workoutDay.sortedExercises.count) exercises")
            } footer: {
                Text("All exercises: \(Constants.defaultTargetSets) sets of \(Constants.defaultTargetRepsMin)-\(Constants.defaultTargetRepsMax) reps")
            }
        }
        .navigationTitle(workoutDay.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    onStartWorkout()
                } label: {
                    Label("Start", systemImage: "play.fill")
                }
            }
        }
    }

    private func exerciseRow(_ exercise: Exercise) -> some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.sfSymbol)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 36, height: 36)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.body)
                if let alt = exercise.alternativeName {
                    Text(alt)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text("\(exercise.targetSets) x \(exercise.targetRepsRange)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.secondary.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(.vertical, 4)
    }
}
