# Swift Log Structure
> Log Structure 를 개발하게된 이유는 현재 개발 중인 프로젝트가 디버깅 할 때 99% 로 Log 를 기반으로 한다. 그러나 Log 사용법이 불편했다. “Log 사용이 간편하게 하려면 어떻게 하면 좋을까?” 라는 고민을 시작으로 Log Structure 라는 결과물이 나왔다.
<br>

- 아래와 같이 LogFilter App 에서 Tag Filter 를 사용하여 원하는 Log 를 볼 수 있다.

<img width="95%" alt="LogFilter" src="https://github.com/hgkim2024/Log/assets/163487894/70f4c489-7339-42d0-b3dc-a65be3483295">
<br>
<br>
<br>


## 사용법

```swift
Log.setLogLevel(LogLevel.DEBUG)
Log.tag(.CALL).t("message")
Log.tag(.GROUP).tag(.URI).tag(.FLOOR).e("message")
Log.tag([.CALL, Tag.URI]).d("message")
Log.tag([.MESSAGE, .NOTIFY]).tag(.URI).d("message")
Log.tag(.CALL).tag([.URI, .NAME]).d("message")
```
<br>

- 결과
```
[ERROR] [FLOOR][GROUP][URI] [ViewController.swift]:18 [viewDidLoad()] - message
[DEBUG] [CALL][URI] [ViewController.swift]:19 [viewDidLoad()] - message
[DEBUG] [MSG][NOTIFY][URI] [ViewController.swift]:20 [viewDidLoad()] - message
[DEBUG] [CALL][URI][NAME] [ViewController.swift]:21 [viewDidLoad()] - message
```

## Tag
- 여러개 Tag 를 추가 할 수 있다.
- tag 입력은 Tag enum class 만 가능하며, 단일과 리스트 형태의 파라미터를 허용한다.
- Tag 를 설정하지 않으면 Tag.NONE 으로 할당된다.
- 기본 Dictionary 사용 시 간헐적으로 Tread Crash 발생하여 NSMutableDictionary 를 사용하여 TagId를 저장한다.

```swift
static func tag(_ tag: Tag, file: String = #file, line: Int = #line,function: String = #function) -> Log.Type {
    let key = getKey(file: file, line: line, function: function)
    setTags([tag], key: key)
    
    return Log.self
}


static func tag(_ tags: [Tag], file: String = #file, line: Int =#line, function: String = #function) -> Log.Type {
    let key = getKey(file: file, line: line, function: function)
    setTags(tags, key: key)
    
    return Log.self
}
```
<br>

## Tag Priority
- Tag enum Type 을 Int 로 지정하여 Tag를 오름차순으로 출력한다.
- NONE Tag 는 사용자가 추가해도 출력되지 않는다. Tag 가 없을 때만 NONE Tag 로 출력된다.

```swift
// MARK: - Log Tag
enum Tag: Int {
    // MARK: - 상위 태그
    case CALL
    case FLOOR
    case MESSAGE
    
    // MARK: - 하위 태그
    case URI
    case NAME
    
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
```
<br>

## Log Level
- Log Level 종류는 TRACE, DEBUG, WARNING, ERROR, FATAL 로 총 5가지 Level 이 있다.
- Log Level 종류에 앞 이니셜만 가져와 함수로 만들었다.
```swift
// trace
static func t(_ format: String, file: String = #file, line: Int =#line, function: String = #function) {
    printLog(format, logLevel: LogLevel.TRACE, file: file, line: line, function: function)
}

// debug
static func d(_ format: String, file: String = #file, line: Int =#line, function: String = #function) {
    printLog(format, logLevel: LogLevel.DEBUG, file: file, line: line, function: function)
}

// warning
static func w(_ format: String, file: String = #file, line: Int =#line, function: String = #function) {
    printLog(format, logLevel: LogLevel.WARNING, file: file, line: line, function: function)
}

// error
static func e(_ format: String, file: String = #file, line: Int =#line, function: String = #function) {
    printLog(format, logLevel: LogLevel.ERROR, file: file, line: line, function: function)
}

// fatal
static func f(_ format: String, file: String = #file, line: Int =#line, function: String = #function) {
    printLog(format, logLevel: LogLevel.FATAL, file: file, line: line, function: function)
}
```

- AppDelegate
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
#if DEBUG
    Log.setLogLevel(.TRACE)
#else
    Log.setLogLevel(.ERROR)
#endif
        
    return true
}
```

<br>

## Print Log
- Log Class 에서 Log Level 을 설정하면 해당 기준으로 아래 Level 로그만 출력한다.
- Log Level 에 따라 print 될 때 “[LogLevel]” 이 가장 앞에 표기된다.
- 설정된 태그는 Log Level 뒤에 [Tag1][Tag2][Tag3] ... [TagN] 으로 표기된다.
- NSLog 사용시 Contents 길이가 길어지면 짤리기 때문에 OSLog 로 변경했다.

```swift
static private func printLog(_ message: String, logLevel: LogLevel, file: String, line: Int, function: String) {
    let key = getKey(file: file, line: line, function: function)
    guard var tags = logTagMap[key] as? [Tag] else {
        assert(false)
        return
    }
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
```

<br>
