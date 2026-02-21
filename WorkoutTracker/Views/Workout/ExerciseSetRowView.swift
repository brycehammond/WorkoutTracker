import SwiftUI

struct ExerciseSetRowView: View {
    @Bindable var exerciseSet: ExerciseSet
    var onComplete: () -> Void
    var onUncomplete: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Set number
            Text("Set \(exerciseSet.setNumber)")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(width: 44, alignment: .leading)

            // Weight
            WeightInputView(weight: $exerciseSet.weight)

            Spacer()

            // Reps
            repsControl

            // Complete button
            Button {
                if exerciseSet.isCompleted {
                    onUncomplete()
                } else {
                    onComplete()
                }
            } label: {
                Image(systemName: exerciseSet.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(exerciseSet.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .opacity(exerciseSet.isCompleted ? 0.7 : 1.0)
        .sensoryFeedback(.success, trigger: exerciseSet.isCompleted) { old, new in
            new && !old
        }
        .accessibilityLabel("Set \(exerciseSet.setNumber), \(Int(exerciseSet.weight)) pounds, \(exerciseSet.reps) reps, \(exerciseSet.isCompleted ? "completed" : "not completed")")
    }

    private var repsControl: some View {
        HStack(spacing: 8) {
            Button {
                exerciseSet.reps = max(0, exerciseSet.reps - 1)
            } label: {
                Image(systemName: "minus")
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)

            Text("\(exerciseSet.reps)")
                .font(.body.monospacedDigit().bold())
                .frame(minWidth: 28)
                .multilineTextAlignment(.center)

            Button {
                exerciseSet.reps += 1
            } label: {
                Image(systemName: "plus")
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)

            Text("reps")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
