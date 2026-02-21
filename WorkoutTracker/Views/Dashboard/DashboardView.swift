import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: WorkoutViewModel?
    @State private var showingActiveWorkout = false
    @State private var selectedDay: WorkoutDay?
    @State private var showDiscardAlert = false

    var body: some View {
        NavigationStack {
            Group {
                if let viewModel {
                    dashboardContent(viewModel: viewModel)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Workout")
            .onAppear {
                if viewModel == nil {
                    viewModel = WorkoutViewModel(modelContext: modelContext)
                } else {
                    viewModel?.fetchData()
                }
            }
            .fullScreenCover(item: $selectedDay) { day in
                ActiveWorkoutView(workoutDay: day) {
                    selectedDay = nil
                    viewModel?.fetchData()
                }
            }
        }
    }

    @ViewBuilder
    private func dashboardContent(viewModel: WorkoutViewModel) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                incompleteSessionBanner(viewModel: viewModel)
                nextWorkoutCard(viewModel: viewModel)
                weekSummaryCard(viewModel: viewModel)
                lastWorkoutCard(viewModel: viewModel)
                workoutDaysList(viewModel: viewModel)
            }
            .padding()
        }
    }

    @ViewBuilder
    private func incompleteSessionBanner(viewModel: WorkoutViewModel) -> some View {
        if let incomplete = viewModel.incompleteSession, let day = incomplete.workoutDay {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Incomplete Workout")
                        .font(.subheadline.bold())
                    Spacer()
                }
                Text("You have an unfinished \(day.name) workout from \(incomplete.date, style: .relative) ago.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Button("Resume") {
                        selectedDay = day
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)

                    Button("Discard", role: .destructive) {
                        showDiscardAlert = true
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }
            .padding()
            .background(.orange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .alert("Discard Workout?", isPresented: $showDiscardAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    viewModel.discardIncompleteSession()
                }
            } message: {
                Text("This will permanently delete the incomplete workout session.")
            }
        }
    }

    @ViewBuilder
    private func nextWorkoutCard(viewModel: WorkoutViewModel) -> some View {
        if let nextDay = viewModel.nextWorkoutDay {
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Workout")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(nextDay.name)
                            .font(.title.bold())
                        Text(nextDay.subtitle)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(nextDay.dayLabel)
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.15))
                        .foregroundStyle(.blue)
                        .clipShape(Capsule())
                }

                Button {
                    selectedDay = nextDay
                } label: {
                    Label("Start Workout", systemImage: "play.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    @ViewBuilder
    private func weekSummaryCard(viewModel: WorkoutViewModel) -> some View {
        HStack(spacing: 16) {
            statBox(
                title: "This Week",
                value: "\(viewModel.completedSessionsThisWeek)",
                icon: "calendar"
            )
            statBox(
                title: "Streak",
                value: "\(viewModel.currentStreak) days",
                icon: "flame.fill"
            )
            statBox(
                title: "Total",
                value: "\(viewModel.totalCompletedSessions)",
                icon: "trophy.fill"
            )
        }
    }

    private func statBox(title: String, value: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(value)
                .font(.title3.bold())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func lastWorkoutCard(viewModel: WorkoutViewModel) -> some View {
        if let last = viewModel.lastSession, let day = last.workoutDay {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.secondary)
                    Text("Last Workout")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                HStack {
                    Text(day.name)
                        .font(.headline)
                    Spacer()
                    Text(last.date, style: .relative)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("ago")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private func workoutDaysList(viewModel: WorkoutViewModel) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Workout Days")
                .font(.headline)
                .padding(.horizontal, 4)

            ForEach(viewModel.workoutDays) { day in
                NavigationLink {
                    WorkoutDayListView(workoutDay: day) {
                        selectedDay = day
                    }
                } label: {
                    workoutDayRow(day: day)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func workoutDayRow(day: WorkoutDay) -> some View {
        HStack(spacing: 12) {
            Image(systemName: iconForDay(day))
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 44, height: 44)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(day.name)
                    .font(.headline)
                Text(day.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(day.dayLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func iconForDay(_ day: WorkoutDay) -> String {
        switch day.sortOrder {
        case 0: "figure.strengthtraining.traditional"
        case 1: "figure.rowing"
        case 2: "figure.walk"
        default: "dumbbell.fill"
        }
    }
}
