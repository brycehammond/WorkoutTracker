import SwiftUI

struct WeightInputView: View {
    @Binding var weight: Double
    var increment: Double = 5.0

    var body: some View {
        HStack(spacing: 12) {
            Button {
                weight = max(0, weight - increment)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)

            Text("\(formattedWeight) lbs")
                .font(.body.monospacedDigit())
                .frame(minWidth: 80)
                .multilineTextAlignment(.center)

            Button {
                weight += increment
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
        }
        .sensoryFeedback(.selection, trigger: weight)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(formattedWeight) pounds")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: weight += increment
            case .decrement: weight = max(0, weight - increment)
            @unknown default: break
            }
        }
    }

    private var formattedWeight: String {
        weight.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", weight)
            : String(format: "%.1f", weight)
    }
}
