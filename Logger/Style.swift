
import Foundation

public enum Style {
    case short
    case medium
    case long
    case custom(shouldLogFile: Bool,
        shouldLogLine: Bool,
        shouldLogColumn: Bool,
        shouldLogFunction: Bool,
        shouldLogDate: Bool,
        dateFormat: String?)
}
