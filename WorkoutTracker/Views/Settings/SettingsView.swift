import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @AppStorage(UserSettings.Keys.restTimerDuration) private var restTimerDuration = Constants.defaultRestTimerSeconds
    @AppStorage(UserSettings.Keys.weightIncrement) private var weightIncrement = Constants.defaultWeightIncrement
    @AppStorage(UserSettings.Keys.useMetric) private var useMetric = false

    @State private var showResetConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Rest Timer") {
                    Picker("Default Duration", selection: $restTimerDuration) {
                        Text("60 seconds").tag(60)
                        Text("75 seconds").tag(75)
                        Text("90 seconds").tag(90)
                    }
                }

                Section("Progression") {
                    Picker("Weight Increment", selection: $weightIncrement) {
                        Text("2.5 lbs").tag(2.5)
                        Text("5 lbs").tag(5.0)
                        Text("10 lbs").tag(10.0)
                    }
                }

                Section("Units") {
                    Toggle("Use Metric (kg)", isOn: $useMetric)
                }

                Section {
                    Button("Reset Workout History", role: .destructive) {
                        showResetConfirmation = true
                    }
                } footer: {
                    Text("This will delete all workout sessions and logged sets. Your exercise templates will be preserved.")
                }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All History?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetHistory()
                }
            } message: {
                Text("This cannot be undone. All workout sessions and sets will be permanently deleted.")
            }
        }
    }

    private func resetHistory() {
        do {
            try modelContext.delete(model: ExerciseSet.self)
            try modelContext.delete(model: WorkoutSession.self)
            try modelContext.save()
        } catch {
            print("Failed to reset history: \(error)")
        }
    }
}
