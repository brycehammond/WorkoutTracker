import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                equipmentImage
                exerciseInfo
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var equipmentImage: some View {
        if let imageName = exercise.imageName,
           let uiImage = UIImage(named: imageName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
        } else {
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                Image(systemName: exercise.sfSymbol)
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
            }
            .frame(height: 300)
        }
    }

    private var exerciseInfo: some View {
        VStack(spacing: 16) {
            // Name and alternative
            VStack(spacing: 4) {
                Text(exercise.name)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)
                if let alt = exercise.alternativeName {
                    Text(alt)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 20)

            // Stats row
            HStack(spacing: 24) {
                statBadge(
                    label: "Sets",
                    value: "\(exercise.targetSets)",
                    icon: "repeat"
                )
                statBadge(
                    label: "Reps",
                    value: exercise.targetRepsRange,
                    icon: "flame"
                )
                statBadge(
                    label: "Start Weight",
                    value: "\(Int(exercise.defaultWeight)) lbs",
                    icon: "scalemass"
                )
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
        .offset(y: -30)
    }

    private func statBadge(label: String, value: String, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
            Text(value)
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
