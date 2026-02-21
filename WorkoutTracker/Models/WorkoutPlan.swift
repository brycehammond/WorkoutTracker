import Foundation
import SwiftData

enum WorkoutPlan {
    case push, pull, legs

    var dayLabel: String {
        switch self {
        case .push: "Day A"
        case .pull: "Day B"
        case .legs: "Day C"
        }
    }

    var sortOrder: Int {
        switch self {
        case .push: 0
        case .pull: 1
        case .legs: 2
        }
    }

    static let rotation: [WorkoutPlan] = [.push, .pull, .legs]

    static func nextDay(after lastSortOrder: Int?) -> Int {
        guard let last = lastSortOrder else { return 0 }
        return (last + 1) % rotation.count
    }
}
