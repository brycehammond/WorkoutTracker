import SwiftUI

struct RestTimerView: View {
    let timeRemaining: Int
    let totalTime: Int
    var onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .foregroundStyle(.blue)
                Text("Rest Timer")
                    .font(.subheadline.bold())
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 16) {
                Text(timeString)
                    .font(.system(.title, design: .monospaced, weight: .bold))
                    .contentTransition(.numericText())

                Spacer()

                ProgressView(value: Double(totalTime - timeRemaining), total: Double(totalTime))
                    .progressViewStyle(.circular)
                    .tint(timerColor)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .padding(.horizontal)
    }

    private var timeString: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var timerColor: Color {
        if timeRemaining <= 10 {
            return .red
        } else if timeRemaining <= 30 {
            return .orange
        }
        return .blue
    }
}
