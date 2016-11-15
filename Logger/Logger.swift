
import Foundation

public class Logger {

    public let type: Type
    public let name: String
    public var style: Style = .medium
    public var level: Level = .all
    public var restrictions: [Restriction] = [.none]
    public let separator: String = " "
    public let terminator: String = "\n"
    private let mFormatter = DateFormatter(dateFormat: "HH:mm:ss.SSS")
    private let lFormatter = DateFormatter(dateFormat: "yyyy/MM/dd HH:mm:ss.SSS")

    public init(type: Type, name: String) {
        self.type = type
        self.name = name

        if case .file(let path) = type {
            initializeFileForLog(path)
        }
    }

    deinit {
        if case .file(_) = self.type {
            logHandler.closeFile()
        }
    }

    public var isGlobalLogger: Bool {
        get {
            return self === logger
        }
    }

    public var logFilePath: URL? {
        get {
            if case .file(let path) = type {
                return path
            }
            return nil
        }
    }

    public var logFileSize: Int64? {
        get {
            if case .file(let path) = type {
                do {
                    let attr: Dictionary = try FileManager.default.attributesOfItem(atPath: path.path)
                    return Int64((attr as NSDictionary).fileSize()) //Si esto peta que me crucifiquen en la plaza del pueblo
                } catch {
                    return nil
                }
            }
            return nil
        }
    }

    private lazy var loggersQueue: DispatchQueue = {
        return DispatchQueue(label: "com.bq.lib.logger.queue", qos: .background)
    }()

    private lazy var logHandler: FileHandle = {
        if case .file(let path) = self.type {
            do {
                if FileManager.default.fileExists(atPath: path.path) {
                    assertionFailure("The given file for log exists!")
                } else {
                    try "".write(to: path, atomically: true, encoding: String.Encoding.utf8)
                }

                return try FileHandle(forWritingTo: path)
            } catch let error as NSError {
                assertionFailure("Fail to create log file handler: \(error.description) Path: \(path.absoluteString)")
            }
        }

        fatalError("Cannot create logHandler for this type of logger")
    }()

    public func logFatal(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        if level < .fatal { return }
        log(.fatal, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
    }

    public func logError(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        if level < .error { return }
        log(.error, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
    }

    public func logWarning(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        if level < .warn { return }
        log(.warn, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
    }

    public func logInfo(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        if level < .info { return }
        log(.info, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
    }

    public func logDebug(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        if level < .debug { return }
        log(.debug, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
    }

    public func logTrace(_ items: Any..., separator: String? = nil, terminator: String? = nil, file: String = #file, line: Int = #line, column: Int = #column, function: String = #function) {
        if level < .trace { return }
        log(.trace, items: items, separator: separator, terminator: terminator, file: file, line: line, column: column, function: function)
    }

    internal func log(_ logLevel: Level, items: [Any], separator: String?, terminator: String?, file: String, line: Int, column: Int, function: String, date: Date = Date()) {
        let separator = separator ?? self.separator
        let terminator = terminator ?? self.terminator

        let message = buildMessageForLogLevel(items, separator: separator)

        switch type {
        case .console:
            if shouldPrintMessageWithCurrentRestrictions(message) {
                let stringToPrint = stringForCurrentStyle(forFile: false, logLevel: logLevel, message: message, terminator: terminator, file: file, line: line, column: column, function: function, date: date)
                print(stringToPrint, terminator: terminator)
            }
        case .file(let path):
            writeToFileAndPrintLog(path, logLevel: logLevel, message: message, terminator: terminator, file: file, line: line, column: column, function: function, date: date)
        }
    }

    private func buildMessageForLogLevel(_ items: [Any], separator: String) -> String {
        var message = ""

        for (index, item) in items.enumerated() {
            message += String(describing: item) + (index == items.count-1 ? "" : separator)
        }

        return message
    }

    private func stringForCurrentStyle(forFile: Bool, logLevel: Level, message: String, terminator: String, file: String, line: Int, column: Int, function: String, date: Date) -> String {
        var string = String()
        let namePrefix = forFile || isGlobalLogger ? "" : "[\(name)] "
        let level = "\(logLevel.label)"

        switch style {
        case .short:
            string = "\(level) \(namePrefix)\(message)"

        case .medium:
            let stringDate      = "\(mFormatter.string(from: date))"
            let stringLocation  = "[\((file as NSString).lastPathComponent):L\(line)]"

            string = "\(stringDate) ◉ \(level) \(namePrefix)\(message) \(stringLocation)"

        case .long:
            let stringDate         = "\(lFormatter.string(from: date))"
            let stringLocation     = "[\((file as NSString).lastPathComponent):L\(line):C\(column):\(function)]"

            string = "\(stringDate) ◉ \(level) \(namePrefix)\(message) \(stringLocation)"

        case let .custom(shouldLogFile, shouldLogLine, shouldLogColumn, shouldLogFunction, shouldLogDate, dateFormat):
            let hasLocation = shouldLogFile || shouldLogLine || shouldLogColumn || shouldLogFunction
            var stringLocation: String = ""

            if hasLocation { stringLocation += "[" }
            if shouldLogFile { stringLocation += (file as NSString).lastPathComponent }
            if shouldLogFile && (shouldLogFunction || shouldLogLine || shouldLogFile) { stringLocation += ":" }
            if shouldLogLine { stringLocation += "L\(line)" }
            if (shouldLogLine || shouldLogFile) && shouldLogColumn { stringLocation += ":" }
            if shouldLogColumn { stringLocation += "C\(column)" }
            if (shouldLogColumn || shouldLogLine || shouldLogFile) && shouldLogFunction { stringLocation += ":" }
            if shouldLogFunction { stringLocation += "\(function)" }
            if hasLocation { stringLocation += "]" }

            if shouldLogDate {
                var formatter = DateFormatter()
                if let dateFormat = dateFormat {
                    formatter.dateFormat = dateFormat
                } else {
                    formatter = lFormatter
                }
                let stringDate = "[\(formatter.string(from: date))]"
                
                string = "\(stringDate) ◉ \(level) \(namePrefix)\(message) \(stringLocation)"
            }
        }
        
        return string
    }

    private func shouldPrintMessageWithCurrentRestrictions(_ string: String) -> Bool {
        #if RELEASE
            return false
        #endif

        var shouldLog: Bool = true

        for restriction in restrictions {
            shouldLog &= restriction.shouldPrintString(string)
        }
        
        return shouldLog
    }

    private func writeLineToLog(_ line: String) {
        if let dataToLog = "\(line)\n".data(using: String.Encoding.utf8) {
            logHandler.write(dataToLog)
        }
    }

    private func initializeFileForLog(_ path: URL) {
        loggersQueue.async {
            if FileManager.default.fileExists(atPath: path.path) {
                assertionFailure("The given file for log exists!")
            }

            self.writeLineToLog("🗒 Initializing Log File: \(self.name)")
        }
    }

    private func writeToFileAndPrintLog(_ path: URL, logLevel: Level, message: String, terminator: String, file: String, line: Int, column: Int, function: String, date: Date) {
        loggersQueue.async {

            let stringToLog = self.stringForCurrentStyle(forFile: true, logLevel: logLevel, message: message, terminator: terminator, file: file, line: line, column: column, function: function, date: date)
            self.writeLineToLog(stringToLog)

            if self.shouldPrintMessageWithCurrentRestrictions(message) {
                let stringToPrint = self.stringForCurrentStyle(forFile: false, logLevel: logLevel, message: message, terminator: terminator, file: file, line: line, column: column, function: function, date: date)
                print(stringToPrint, terminator: terminator)
            }
        }
    }
}
