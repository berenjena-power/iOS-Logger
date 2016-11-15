
import Foundation

public enum Level: Int {
    case disable = 0
    case fatal = 1
    case error = 2
    case warn = 3
    case info = 4
    case debug = 5
    case trace = 6
    case all = 7
    
    var label: String {
        switch self {
        case .trace: return "✏️"
        case .info:  return "🔍"
        case .debug: return "🐛"
        case .error: return "❌❌❌"
        case .fatal: return "☠️☠️☠️"
        case .warn:  return "⚠️⚠️⚠️"
        default: return ""
        }
    }
}
