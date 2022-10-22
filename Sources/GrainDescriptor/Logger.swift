import Foundation

enum Log {
  
  static func debug(
    file: StaticString = #file,
    line: UInt = #line,
    _ object: @autoclosure () -> Any
  ) {
    
    if CommandLine.arguments.contains("--verbose") {
      print(object())
    }
  }
  
  static func info(
    file: StaticString = #file,
    line: UInt = #line,
    _ object: Any
  ) {    
    print(object)
  }
  
  static func error(
    file: StaticString = #file,
    line: UInt = #line,
    _ object: @autoclosure () -> Any
  ) {
    FileHandle.standardError.write(String(describing: object()).data(using: .utf8)!)
  }
  
}
