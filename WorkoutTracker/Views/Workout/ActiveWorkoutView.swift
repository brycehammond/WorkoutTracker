import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    let workoutDay: WorkoutDay
    var onDismiss: () -> Void

    @State private var viewModel: ActiveWorkoutViewModel?
    @State private var showWarmup = true
    @State private var showCancelAlert = false
    @State private var showFinishAlert = false
    @State private var showBeginnerBanner = true
    @Query(filter: #Predicate<WorkoutSession> { $0.isCompleted })
    private var completedSessions: [WorkoutSession]

    var body: some View {
        NavigationStack {
            Group {
                if showWarmup {
                    WarmupReminderView(
                        onStart: { beginWorkout() },
                        onSkip: { beginWorkout() }
                    )
                } else if let viewModel {
                    workoutContent(viewModel: viewModel)
                } else {
                    ProgressView("Starting workout...")
                }
            }
            .navigationTitle(workoutDay.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !showWarmup {
                        Button("Cancel") {
                            showCancelAlert = true
                        }
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if let viewModel, !showWarmup {
                        Button("Finish") {
                            if viewModel.completedSetsCount > 0 {
                                showFinishAlert = true
                            }
                        }
                        .bold()
                        .disabled(viewModel.completedSetsCount == 0)
                    }
                }
            }
            .alert("Cancel Workout?", isPresented: $showCancelAlert) {
                Button("Keep Going", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    viewModel?.cancelWorkout()
                    onDismiss()
                }
            } message: {
                Text("Your progress will be lost.")
            }
            .alert("Finish Workout?", isPresented: $showFinishAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Finish") {
                    viewModel?.finishWorkout()
                    onDismiss()
                }
            } message: {
                if let viewModel {
                    Text("You completed \(viewModel.completedSetsCount) of \(viewModel.totalSetsCount) sets.")
                }
            }
            .interactiveDismissDisabled()
        }
        .persistentSystemOverlays(.hidden)
    }

    private func beginWorkout() {
        showWarmup = false
        let vm = ActiveWorkoutViewModel(modelContext: modelContext, workoutDay: workoutDay)
        vm.startWorkout()
        viewModel = vm
    }

    @ViewBuilder
    private func workoutContent(viewModel: ActiveWorkoutViewModel) -> some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 4) {
                    progressHeader(viewModel: viewModel)
                    beginnerBanner

                    ForEach(workoutDay.sortedExercises) { exercise in
                        exerciseCard(exercise: exercise, viewModel: viewModel)
                    }
                }
                .padding()
                .padding(.bottom, viewModel.isRestTimerRunning ? 120 : 0)
            }

            if viewModel.isRestTimerRunning {
                RestTimerView(
                    timeRemaining: viewModel.restTimeRemaining,
                    totalTime: viewModel.restTimerDuration,
                    onDismiss: { viewModel.dismissRestTimer() }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.spring(duration: 0.3), value: viewModel.isRestTimerRunning)
            }
        }
    }

    @ViewBuilder
    private var beginnerBanner: some View {
        if showBeginnerBanner && completedSessions.count < Constants.beginnerPhaseSessionCount {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(.blue)
                Text("Focus on learning the machines and getting comfortable with the movements.")
                    .font(.caption)
                Spacer()
                Button {
                    withAnimation { showBeginnerBanner = false }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.blue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func progressHeader(viewModel: ActiveWorkoutViewModel) -> some View {
        VStack(spacing: 8) {
            ProgressView(value: viewModel.progress)
                .tint(.blue)

            HStack {
                Text("\(viewModel.completedSetsCount) / \(viewModel.totalSetsCount) sets")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
            }
        }
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func exerciseCard(exercise: Exercise, viewModel: ActiveWorkoutViewModel) -> some View {
        let isSkipped = viewModel.isExerciseSkipped(exercise)

        VStack(alignment: .leading, spacing: 12) {
            // Exercise header
            HStack {
                Image(systemName: exercise.sfSymbol)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 32, height: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise.name)
                        .font(.headline)
                    if let alt = exercise.alternativeName {
                        Text(alt)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                if let suggested = viewModel.suggestedWeight(for: exercise) {
                    Label("\(Int(suggested)) lbs", systemImage: "arrow.up.circle.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.green)
                }

                Menu {
                    if isSkipped {
                        Button("Include Exercise") {
                            viewModel.unskipExercise(exercise)
                        }
                    } else {
                        Button("Skip Exercise", role: .destructive) {
                            viewModel.skipExercise(exercise)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundStyle(.secondary)
                }
            }

            if isSkipped {
                Text("Skipped")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                // Set rows
                ForEach(viewModel.setsForExercise(exercise)) { set in
                    ExerciseSetRowView(
                        exerciseSet: set,
                        onComplete: { viewModel.completeSet(set) },
                        onUncomplete: { viewModel.uncompleteSet(set) }
                    )

                    if set.setNumber < exercise.targetSets {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .opacity(isSkipped ? 0.5 : 1.0)
    }
}
