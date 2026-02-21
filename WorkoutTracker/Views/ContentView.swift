import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Workout", systemImage: "dumbbell.fill") {
                DashboardView()
            }
            Tab("Progress", systemImage: "chart.line.uptrend.xyaxis") {
                WorkoutProgressView()
            }
            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
