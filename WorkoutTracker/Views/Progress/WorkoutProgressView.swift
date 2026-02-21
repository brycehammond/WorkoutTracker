import SwiftUI
import SwiftData

struct WorkoutProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ProgressViewModel?
    @State private var selectedExercise: Exercise?

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    if viewModel.completedSessions.isEmpty {
                        ContentUnavailableView(
                            "No Workouts Yet",
                            systemImage: "chart.line.uptrend.xyaxis",
                            description: Text("Complete your first workout to see progress.")
                        )
                    } else {
                        progressContent(viewModel: viewModel)
                    }
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Progress")
            .onAppear {
                if viewModel == nil {
                    viewModel = ProgressViewModel(modelContext: modelContext)
                } else {
                    viewModel?.fetchData()
                }
            }
        }
    }

    @ViewBuilder
    private func progressContent(viewModel: ProgressViewModel) -> some View {
        List {
            // Exercise progress section
            Section("Exercise Progress") {
                ForEach(viewModel.allExercises) { exercise in
                    NavigationLink {
                        ExerciseHistoryView(exercise: exercise, viewModel: viewModel)
                    } label: {
                        exerciseProgressRow(exercise: exercise, viewModel: viewModel)
                    }
                }
            }

            // Session history
            ForEach(viewModel.sessionsByMonth, id: \.key) { month in
                Section(month.key) {
                    ForEach(month.sessions) { session in
                        NavigationLink {
                            SessionDetailView(session: session)
                        } label: {
                            sessionRow(session)
                        }
                    }
                }
            }
        }
    }

    private func exerciseProgressRow(exercise: Exercise, viewModel: ProgressViewModel) -> some View {
        HStack(spacing: 12) {
            Image(systemName: exercise.sfSymbol)
                .foregroundStyle(.blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise.name)
                    .font(.subheadline)
                if let pb = viewModel.personalBest(for: exercise) {
                    Text("PR: \(Int(pb.weight)) lbs x \(pb.reps)")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            let data = viewModel.chartData(for: exercise)
            if data.count >= 2 {
                let trend = data.last!.weight - data.first!.weight
                if trend > 0 {
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(.green)
                        .font(.caption)
                } else if trend < 0 {
                    Image(systemName: "arrow.down.right")
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }
        }
    }

    private func sessionRow(_ session: WorkoutSession) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(session.workoutDay?.name ?? "Workout")
                    .font(.headline)
                Text(session.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            let completedCount = session.sets.filter(\.isCompleted).count
            Text("\(completedCount) sets")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
