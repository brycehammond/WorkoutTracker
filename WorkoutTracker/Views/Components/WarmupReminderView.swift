import SwiftUI

struct WarmupReminderView: View {
    var onStart: () -> Void
    var onSkip: () -> Void

    @State private var timeRemaining = Constants.warmupDurationSeconds
    @State private var isTimerRunning = false
    @State private var timerTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.walk")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("Warm Up First!")
                .font(.title2.bold())

            Text("Start with 5-10 minutes of light cardio\n(treadmill, bike, or elliptical)")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if isTimerRunning {
                Text(timerString)
                    .font(.system(.largeTitle, design: .monospaced, weight: .bold))
                    .contentTransition(.numericText())
                    .padding()

                Button("Done Warming Up") {
                    stopTimer()
                    onStart()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button {
                    startTimer()
                } label: {
                    Label("Start 5-Min Timer", systemImage: "timer")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }

            Button("Skip Warm-Up") {
                stopTimer()
                onSkip()
            }
            .foregroundStyle(.secondary)
        }
        .padding(32)
        .onDisappear {
            stopTimer()
        }
    }

    private var timerString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private func startTimer() {
        isTimerRunning = true
        timerTask = Task {
            while timeRemaining > 0 && !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                timeRemaining -= 1
            }
        }
    }

    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
        isTimerRunning = false
    }
}
