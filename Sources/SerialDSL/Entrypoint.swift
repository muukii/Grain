@_implementationOnly import Darwin.C

public func serialize(@ValueBuilder _ thunk: () -> some SerialView) {
  
  let value = thunk()
  
  let text = value.renderJSON()
  
  if let optIdx = CommandLine.arguments.firstIndex(of: "-fileno") {
    
    if let outputFileDesc = Int32(CommandLine.arguments[optIdx + 1]) {
      guard let fd = fdopen(outputFileDesc, "w") else {
        return
      }
      fputs(text, fd)
      fclose(fd)
    }
  } else {
    print(text)
  }
}
