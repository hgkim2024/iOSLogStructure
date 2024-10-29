//
//  Log.swift
//  LogProject
//
//  Created by 김현구 on 3/15/24.
//

import UIKit
import os

// MARK: - Log Tag
enum Tag: Int {
    // MARK: - 상위 태그
    case CALL
    case FLOOR
    case MESSAGE
    case GROUP
    case NOTIFY
    
    // MARK: - 하위 태그
    case URI
    case NAME
    case ID
    
    case SUCCESS
    case FAIL
    
    // MARK: - NONE 태그
    case NONE
    
    var title: String {
        return switch self {
        case .MESSAGE:
            "MSG" // : Log Level 에 MESSAGE 가 있어 MSG 로 수정
        default:
            String(describing: self)
        }
    }
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
    static private var logTagMap = NSMutableDictionary() // : [String: [Tag]]()
    static private var logger = OSLog(subsystem: "AppName", category: "")
    
    static func setLogLevel(_ logLevel: LogLevel) {
        self.logLevel = logLevel
    }
    
    static private func getKey(file: String, line: Int, function: String) -> String {
        return "\(file)_\(line)_\(function)"
    }
    
    static func tag(_ tag: Tag, file: String = #file, line: Int = #line, function: String = #function) -> Log.Type {
        let key = getKey(file: file, line: line, function: function)
        setTags([tag], key: key)
        
        return Log.self
    }
    
    
    static func tag(_ tags: [Tag], file: String = #file, line: Int = #line, function: String = #function) -> Log.Type {
        let key = getKey(file: file, line: line, function: function)
        setTags(tags, key: key)
        
        return Log.self
    }
    
    static private func setTags(_ tags: [Tag], key: String) {
        if let initValue = logTagMap[key] {
            if var list = initValue as? [Tag] {
                list.append(contentsOf: tags)
                logTagMap[key] = list.filter({$0 != Tag.NONE})
            }
        } else {
            logTagMap[key] = tags.filter({$0 != Tag.NONE})
        }
    }
    
    static private func printLog(_ message: String, logLevel: LogLevel, file: String, line: Int, function: String) {
        let key = getKey(file: file, line: line, function: function)
        guard var tags = logTagMap[key] as? [Tag] else { return }
        tags.sort(by: { $0.rawValue < $1.rawValue })
        
        if isNotPrintLog(logLevel: logLevel) {
            logTagMap[key] = nil
            return
        }
        
        var tag = ""
        
        if logTagMap[key] == nil {
            logTagMap[key] = [Tag.NONE]
        }
        
        for t in tags {
            tag += "[\(t.title)]"
        }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        var imoge: String = "🟢"
        if tags.contains(.FAIL) {
            imoge = "❌"
        }
        let contents = "\(imoge) [\(logLevel.rawValue)] \(tag) [\(fileName)]:\(line) [\(function)]: - \(message)"
        
        os_log("%@", log: logger, type: .debug, contents)
        //        NSLog(contents) // NSLog 사용시 contents 가 길어지면 짤린다.
        
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
