import ArgumentParser
import Foundation
import TSCBasic
import TSCUtility

struct CLIError: Swift.Error, LocalizedError, Equatable {

  var errorDescription: String?

  static var fileNotFound: Self = .init(errorDescription: "File not found")
  static var runtimeNotFound: Self = .init(errorDescription: "Runtime not found")

}

struct CLI: AsyncParsableCommand {

  static var configuration: CommandConfiguration = .init(subcommands: [Gen.self])

  struct Gen: AsyncParsableCommand {
    
    struct DomainError: Swift.Error, LocalizedError, Equatable {
      
      var errorDescription: String?
      
      static var failedToCompile: Self = .init(errorDescription: "Failed to compile")
      static var couldNotCreateOutputFile: Self = .init(errorDescription: "Could not create output file")
      static var failureInMakingOutput: Self = .init(errorDescription: "Failure iin makiing output")
      
    }

    @Argument var targetFilePath: String

    mutating func run() async throws {

      let filePath = localFileSystem.currentWorkingDirectory!.appending(
        RelativePath(targetFilePath)
      )

      guard localFileSystem.exists(filePath) else {
        throw CLIError.fileNotFound
      }

      let foundPath = try TSCBasic.Process.checkNonZeroExit(arguments: [
        "/usr/bin/xcrun", "--find", "swiftc",
      ]).spm_chomp()

      let swiftc = try AbsolutePath(validating: foundPath)

      let applicationPath = try Utils.hostBinDir(fileSystem: localFileSystem)

      var runtimeFrameworksPath: AbsolutePath {
                
        if localFileSystem.exists(applicationPath.appending(component: "libSerialDSL.dylib")) {
          return applicationPath
        }
        
        return applicationPath.appending(
          components: "PackageFrameworks",
          "SerialDSL.framework"
        )
      }
      
      var libraryPath: AbsolutePath {
        if runtimeFrameworksPath.extension == "framework" {
          return runtimeFrameworksPath.appending(component: "SerialDSL")
        } else {
          // note: this is not correct for all platforms, but we only actually use it on macOS.
          return runtimeFrameworksPath.appending(component: "libSerialDSL.dylib")
        }
      }

      guard localFileSystem.exists(libraryPath) else {
        print(CommandLine.arguments[0], try? AbsolutePath(validating: CommandLine.arguments[0]).parentDirectory)
        throw CLIError.runtimeNotFound
      }

      let target = try Utils.computeMinimumDeploymentTarget(
        of: libraryPath
      )

      let sdkPath = try Utils.sdk()

      var cmd: [String] = []
      cmd += [swiftc.pathString]
      cmd += [
        "-F", runtimeFrameworksPath.parentDirectory.pathString,
        "-framework", "SerialDSL",
        "-Xlinker", "-rpath", "-Xlinker", runtimeFrameworksPath.parentDirectory.pathString,
      ]
      cmd += ["-target", "arm64-apple-macosx\(target!.versionString)"]

      cmd += ["-sdk", sdkPath.pathString]
      cmd += Utils.flags()

      cmd += [filePath.pathString]
      cmd += [
        "-Xfrontend", "-disable-implicit-concurrency-module-import",
        "-Xfrontend", "-disable-implicit-string-processing-module-import",
        "-I", applicationPath.pathString,
      ]

      try await withTemporaryDirectory { workingPath in
        
        let compiledFile = workingPath.appending(component: "compiled")
        
        // make a binary
        do {
          
          cmd += ["-o", compiledFile.pathString]
          
          let result = try await TSCBasic.Process.popen(
            arguments: cmd,
            environment: ProcessInfo.processInfo.environment,
            loggingHandler: { log in }
          )
          
          // Return now if there was an error.
          if result.exitStatus != .terminated(code: 0) {
            throw DomainError.failedToCompile
          }
          
        }
        
        // make an output
        do {
          
          let outputFile = workingPath.appending(component: "output")
          
          guard let outputFileDesc = fopen(outputFile.pathString, "w") else {
            throw DomainError.couldNotCreateOutputFile
          }
          
          var cmd: [String] = []
          
          cmd += [compiledFile.pathString]
          
          cmd += ["-fileno", "\(fileno(outputFileDesc))"]
          
          let result = try await TSCBasic.Process.popen(arguments: cmd, environment: ProcessInfo.processInfo.environment, loggingHandler: { log in })
                    
          fclose(outputFileDesc)
          
          // Return now if there was an error.
          if result.exitStatus != .terminated(code: 0) {
            throw DomainError.failureInMakingOutput
          }
          
          let output: String = try localFileSystem.readFileContents(outputFile)
          
          print(output)
          
        }
        
      }
    }

  }

}

func withTemporaryDirectory(_ work: @escaping (AbsolutePath) async throws -> Void) async throws {
  
  try await withCheckedThrowingContinuation { continuation in
    
    do {
      try withTemporaryDirectory { path, completion -> Void in
        Task {
          do {
            try await work(path)
            completion(path)
            continuation.resume()
          } catch {
            print(error)
            // handle error
            completion(path)
            continuation.resume(throwing: error)
          }
        }
      }
    } catch {
      continuation.resume(throwing: error)
    }
  }
  
}

extension TSCBasic.Process {

  static public func popen(
    arguments: [String],
    environment: [String: String] = ProcessEnv.vars,
    loggingHandler: LoggingHandler? = .none
  ) async throws -> ProcessResult {

    try await withCheckedThrowingContinuation { continuation in

      self.popen(
        arguments: arguments,
        environment: environment,
        loggingHandler: loggingHandler,
        queue: nil
      ) { result in

        switch result {
        case .success(let r):
          continuation.resume(returning: r)
        case .failure(let e):
          continuation.resume(throwing: e)
        }

      }

    }

  }

}

public typealias EnvironmentVariables = [String: String]

enum Utils {

  static func computeMinimumDeploymentTarget(of binaryPath: AbsolutePath) throws -> PlatformVersion?
  {

    let platformName = "MACOS"

    let runResult = try Process.popen(arguments: [
      "/usr/bin/xcrun", "vtool", "-show-build", binaryPath.pathString,
    ])
    var lines = try runResult.utf8Output().components(separatedBy: "\n")
    while !lines.isEmpty {
      let first = lines.removeFirst()
      if first.contains("platform \(platformName)"), let line = lines.first, line.contains("minos")
      {
        return line.components(separatedBy: " ").last.map(PlatformVersion.init(stringLiteral:))
      }
    }
    return nil
  }

  static func flags() -> [String] {
    // Compute common arguments for clang and swift.
    var extraCCFlags: [String] = []
    var extraSwiftCFlags: [String] = []

    if let sdkPaths = sdkPlatformFrameworkPaths(environment: ProcessInfo.processInfo.environment) {
      extraCCFlags += ["-F", sdkPaths.fwk.pathString]
      extraSwiftCFlags += ["-F", sdkPaths.fwk.pathString]
      extraSwiftCFlags += ["-I", sdkPaths.lib.pathString]
      extraSwiftCFlags += ["-L", sdkPaths.lib.pathString]
    }
    return extraSwiftCFlags

  }

  static func sdkPlatformFrameworkPaths(
    environment: EnvironmentVariables = ProcessInfo.processInfo.environment
  ) -> (fwk: AbsolutePath, lib: AbsolutePath)? {

    let platformPath = try? TSCBasic.Process.checkNonZeroExit(
      arguments: ["/usr/bin/xcrun", "--sdk", "macosx", "--show-sdk-platform-path"],
      environment: environment
    ).spm_chomp()

    if let platformPath = platformPath, !platformPath.isEmpty {
      // For XCTest framework.
      let fwk = AbsolutePath(platformPath).appending(
        components: "Developer",
        "Library",
        "Frameworks"
      )

      // For XCTest Swift library.
      let lib = AbsolutePath(platformPath).appending(
        components: "Developer",
        "usr",
        "lib"
      )

      return (fwk, lib)
    }
    return nil
  }

  static func sdk() throws -> AbsolutePath {
    let path = try TSCBasic.Process.checkNonZeroExit(
      arguments: ["/usr/bin/xcrun", "--sdk", "macosx", "--show-sdk-path"],
      environment: ProcessEnv.vars
    ).spm_chomp()
    return AbsolutePath(path)
  }

  static func hostBinDir(
    fileSystem: FileSystem,
    originalWorkingDirectory: AbsolutePath? = nil
  ) throws -> AbsolutePath {
    let originalWorkingDirectory = originalWorkingDirectory ?? fileSystem.currentWorkingDirectory
    guard let cwd = originalWorkingDirectory else {
      return try AbsolutePath(validating: CommandLine.arguments[0]).parentDirectory
    }
    return AbsolutePath(CommandLine.arguments[0], relativeTo: cwd).parentDirectory
  }
}

@main
enum Main {
  static func main() async {
    await CLI.main()
  }
}
