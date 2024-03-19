//
//  Log.swift
//  LogProject
//
//  Created by 김현구 on 3/15/24.
//

import UIKit

// MARK: - Log Tag
enum Tag: String {
    case CALL
    case FLOOR
    case MESSAGE
    case GROUP
    case NOTIFY
    case NONE
}

// MARK: - Log Level
enum LogLevel: String {
    case TRACE
    case DEBUG
    case WARNING
    case ERROR
    case FATAL
    case NONE
}

// MARK: - Log
class Log {
    
    static private var logLevel = LogLevel.TRACE
    //    static private var logIdMap = [String: [Tag]]()
        static private var logTagMap = NSMutableDictionary()
    
    static func setLogLevel(_ logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    static func tag(_ format: Tag, file: String = #file, line: Int = #line, function: String = #function) -> Log.Type {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let key = "\(fileName)_\(line)_\(function)"
        if let initValue = logTagMap[key] {
            if var list = initValue as? [Tag] {
                list.append(format)
            }
        } else {
            logTagMap[key] = [format]
        }
        
        return Log.self
    }
    
    static private func printLog(_ message: String, logLevel: LogLevel, file: String, line: Int, function: String) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let key = "\(fileName)_\(line)_\(function)"
        
        if isNotPrintLog(logLevel: logLevel) {
            logTagMap[key] = nil
            return
        }

        var tag = ""
        
        if logTagMap[key] == nil {
            logTagMap[key] = [Tag.NONE]
        }
        
        if  let tags = logTagMap[key] as? [Tag] {
            for t in tags {
                tag += "[\(t.rawValue)]"
            }
        }
        
        let content = "[\(logLevel.rawValue)] \(tag) [\(fileName)]:\(line) - \(function): \(message)"
        
        NSLog(content)
//        LinphoneManager.instance().printLog(tag, message: content, level: logLevel.linphoneLogLevel)
        
        logTagMap[key] = nil
    }
    
    // trace
    static func t(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.TRACE, file: file, line: line, function: function)
    }
    
    // debug
    static func d(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.DEBUG, file: file, line: line, function: function)
    }
    
    // warning
    static func w(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.WARNING, file: file, line: line, function: function)
    }
    
    // error
    static func e(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.ERROR, file: file, line: line, function: function)
    }
    
    // fatal
    static func f(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        printLog(format, logLevel: LogLevel.FATAL, file: file, line: line, function: function)
    }
    
    static private func isNotPrintLog(logLevel: LogLevel) -> Bool {
        switch self.logLevel {
        case .TRACE:
            return false
            
        case .DEBUG:
            switch logLevel {
            case .TRACE:
                return true
            default:
                return false
            }
            
        case .WARNING:
            switch logLevel {
            case .TRACE, .DEBUG:
                return true
            default:
                return false
            }
            
        case .ERROR:
            switch logLevel {
            case .TRACE, .DEBUG, .WARNING:
                return true
            default:
                return false
            }
            
        case .FATAL:
            switch logLevel {
            case .TRACE, .DEBUG, .WARNING, .ERROR:
                return true
            default:
                return false
            }
            
        case .NONE:
            return true
        }
    }
}
