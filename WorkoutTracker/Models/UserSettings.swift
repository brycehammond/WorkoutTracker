import Foundation

enum UserSettings {
    enum Keys {
        static let restTimerDuration = "restTimerDuration"
        static let weightIncrement = "weightIncrement"
        static let useMetric = "useMetric"
    }

    static var restTimerDuration: Int {
        let saved = UserDefaults.standard.integer(forKey: Keys.restTimerDuration)
        return saved > 0 ? saved : Constants.defaultRestTimerSeconds
    }

    static var weightIncrement: Double {
        let saved = UserDefaults.standard.double(forKey: Keys.weightIncrement)
        return saved > 0 ? saved : Constants.defaultWeightIncrement
    }

    static var useMetric: Bool {
        UserDefaults.standard.bool(forKey: Keys.useMetric)
    }

    static func displayWeight(_ lbs: Double) -> Double {
        useMetric ? lbs * Constants.kgConversionFactor : lbs
    }

    static var weightUnit: String {
        useMetric ? "kg" : "lbs"
    }
}
