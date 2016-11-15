
import Foundation

public enum Restriction {
    case none
    case containing(string: String)
    case ignoring(string: String)
    case equal(string: String)
    
    public func shouldPrintString(_ string: String) -> Bool {
        switch self {
        case .containing(let s):
            return string.contains(s)
        case .equal(let s):
            return (string == s)
        case .ignoring(let s):
            return !string.contains(s)
        case .none:
            return true
        }
    }
}
