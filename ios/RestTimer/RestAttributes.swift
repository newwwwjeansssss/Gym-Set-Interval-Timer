import ActivityKit
import Foundation

struct RestAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var start: Date
        var end: Date
    }
}
