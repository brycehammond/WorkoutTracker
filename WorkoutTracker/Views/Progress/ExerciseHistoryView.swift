import SwiftUI
import Charts

struct ExerciseHistoryView: View {
    let exercise: Exercise
    let viewModel: ProgressViewModel

    var body: some View {
        List {
            let chartData = viewModel.chartData(for: exercise)

            if chartData.count >= 2 {
                Section {
                    Chart(chartData) { point in
                        LineMark(
                            x: .value("Date", point.date),
                            y: .value("Weight", point.weight)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(.blue)

                        PointMark(
                            x: .value("Date", point.date),
                            y: .value("Weight", point.weight)
                        )
                        .foregroundStyle(.blue)
                    }
                    .chartYAxisLabel("Weight (lbs)")
                    .frame(height: 200)
                } header: {
                    Text("Weight Over Time")
                }
            } else if chartData.isEmpty {
                Section {
                    ContentUnavailableView(
                        "No Data Yet",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Complete workouts with this exercise to see trends.")
                    )
                }
            }

            // Personal best
            if let pb = viewModel.personalBest(for: exercise) {
                Section("Personal Best") {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("\(Int(pb.weight)) lbs x \(pb.reps) reps")
                            .font(.headline)
                        Spacer()
                        if let date = pb.session?.date {
                            Text(date, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Set history
            let sets = viewModel.completedSets(for: exercise)
            if !sets.isEmpty {
                Section("Recent Sets") {
                    ForEach(sets.suffix(15).reversed()) { set in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(Int(set.weight)) lbs x \(set.reps)")
                                    .font(.subheadline)
                                Text("Set \(set.setNumber)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if let date = set.session?.date {
                                Text(date, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
