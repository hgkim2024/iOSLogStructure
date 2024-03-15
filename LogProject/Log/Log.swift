//
//  Log.swift
//  LogProject
//
//  Created by 김현구 on 3/15/24.
//

import UIKit

// MARK: - Tag
enum Tag: String {
    case CALL
    case FLOOR
    case Message
    case NOTIFY
    case NONE
}

// MARK: - Log
class Log {
    
    static private var isLog = true
    
    static private var logIdMap = [String: Tag]()
    
    static func tag(_ format: Tag, file: String = #file, line: Int = #line, function: String = #function) -> Log.Type {
        if isLog {
            let key = "\(file)_\(line)_\(function)"
            logIdMap[key] = format
        }
        return Log.self
    }
    
    static private func logPrint(_ message: String, file: String, line: Int, function: String) {
        if isLog {
            let key = "\(file)_\(line)_\(function)"
            let tag = logIdMap[key] ?? Tag.NONE
            let content = "[\(file)]:\(line) - \(function): \(message)"
            
            if case Tag.NONE = tag {
                print("\(content)")
            } else {
                print("[\(tag)] - \(content)")
            }
            
            logIdMap[key] = nil
        }
    }
    
    // info
    static func i(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        logPrint(format, file: file, line: line, function: function)
    }
    
    // debug
    static func d(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        logPrint(format, file: file, line: line, function: function)
    }
    
    // warning
    static func w(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        logPrint(format, file: file, line: line, function: function)
    }
    
    // fatal
    static func f(_ format: String, file: String = #file, line: Int = #line, function: String = #function) {
        logPrint(format, file: file, line: line, function: function)
    }
}

// MARK: - Test Function
//func main() {
//    Log.tag(Tag.CALL).i("message")
//    Log.tag(Tag.FLOOR).d("message")
//    Log.tag(Tag.Message).w("message")
//    Log.tag(Tag.NOTIFY).f("message")
//    
//    Log.tag(Tag.NOTIFY).d("asdff")
//    
//    Log.tag(Tag.CALL).tag(Tag.FLOOR).i("asdf")
//
//    
//    IPGLog("")
//    IPGLog(tag: "", message: "", lvl: .LOG_LEVEL_DEBUG)
//    
//    Log.d("asdf")
//}
//
//main()
