
import Foundation
import ArgumentParser
import TSCBasic
import TSCUtility

struct CLIError: Swift.Error, LocalizedError, Equatable {
  
  var errorDescription: String?
  
  static var fileNotFound: Self = .init(errorDescription: "File not found")
  
}

struct CLI: AsyncParsableCommand {
  
  static var configuration: CommandConfiguration = .init(subcommands: [Gen.self])
  
  struct Gen: AsyncParsableCommand {
    
    @Argument var targetFilePath: String
    
    mutating func run() async throws {
            
      let filePath = try AbsolutePath(validating: "\(FileManager.default.currentDirectoryPath)/\(targetFilePath)")
            
      guard FileManager.default.fileExists(filePath: filePath.description) else {
        throw CLIError.fileNotFound
      }
      
      let foundPath = try TSCBasic.Process.checkNonZeroExit(arguments: ["/usr/bin/xcrun", "--find", "swiftc"]).spm_chomp()
      
      let swiftc = try AbsolutePath(validating: foundPath)
      
      try withTemporaryDirectory { workingPath, completion in        
        
        completion(workingPath)
        
      }
    }
    
  }
  
}

extension FileManager {
  func fileExists(filePath: String) -> Bool {
    var isDirectory = ObjCBool(false)
    return self.fileExists(atPath: filePath, isDirectory: &isDirectory)
  }
}

@main
enum Main {
  static func main() async {
    await CLI.main()
  }
}
