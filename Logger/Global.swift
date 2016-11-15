
import Foundation

public let logger = Logger(type: .console, name: "global")

public func logFatal(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    logger.log(.fatal, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
}

public func logError(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    logger.log(.error, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
}

public func logWarning(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    logger.log(.warn, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
}

public func logInfo(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    logger.log(.info, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
}

public func logDebug(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    logger.log(.debug, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
}

public func logTrace(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
    logger.log(.trace, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
}
