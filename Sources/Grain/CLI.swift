import ArgumentParser
import Foundation
import TSCBasic
import TSCUtility
import GrainDescriptor

let RUNTIME_NAME = "GrainDescriptor"

struct CLIError: Swift.Error, LocalizedError, Equatable {

  var errorDescription: String?

  static var fileNotFound: Self = .init(errorDescription: "File not found")
  static var runtimeNotFound: Self = .init(errorDescription: "Runtime not found")

}

struct CLI: AsyncParsableCommand {
  
  static var configuration: CommandConfiguration {
    .init(
      commandName: "Grain",
      abstract: "",
      usage: "",
      version: "---",
      shouldDisplay: true,
      subcommands: [Render.self],
      defaultSubcommand: Render.self,
      helpNames: .long
    )
  }

  struct Render: AsyncParsableCommand {
    
    struct DomainError: Swift.Error, LocalizedError, Equatable {
      
      var errorDescription: String?
      
      static var failedToCompile: Self = .init(errorDescription: "Failed to compile")
      static var couldNotCreateOutputFile: Self = .init(errorDescription: "Could not create output file")
      static var failureInMakingOutput: Self = .init(errorDescription: "Failure in makiing output")
      
    }

    @Argument var targetFilePaths: [String]
    @Option(name: .customLong("output")) var outputDirectory: String?
    @Flag var verbose = false

    func run() async throws {

      let validatedPaths = targetFilePaths.map {
        AbsolutePath($0, relativeTo: localFileSystem.currentWorkingDirectory!)
      }
            
      await withThrowingTaskGroup(of: Void.self) { group in
        
        for path in validatedPaths {
          group.addTask {
                        
            let context = GrainDescriptor.Context(
              filePath: path,
              outputDir: outputDirectory.map { AbsolutePath($0, relativeTo: localFileSystem.currentWorkingDirectory!) }
            )
            
            try await self.render(path, context: context)
          }
        }

      }      
    }

    private func render(_ targetFilePath: AbsolutePath, context: GrainDescriptor.Context) async throws {

      guard localFileSystem.exists(targetFilePath) else {
        throw CLIError.fileNotFound
      }

      let swiftCompilerPath = try AbsolutePath(
        validating: try TSCBasic.Process.checkNonZeroExit(
          arguments: [
            "/usr/bin/xcrun", "--find", "swiftc",
          ]
        )
        .spm_chomp()
      )
            
      let triple = Triple.getHostTriple(usingSwiftCompiler: swiftCompilerPath)
      
      /// a directory path of this process binary
      let applicationDirPath = try Utils.hostBinDir(fileSystem: localFileSystem)

      var runtimeFrameworksPath: AbsolutePath {
                
        if localFileSystem.exists(applicationDirPath.appending(component: "lib\(RUNTIME_NAME).dylib")) {
          // a case of releasing
          return applicationDirPath
        }
        
        // in development 
        return applicationDirPath.appending(
          components: "PackageFrameworks",
          "\(RUNTIME_NAME).framework"
        )
      }
      
      var libraryPath: AbsolutePath {
        if runtimeFrameworksPath.extension == "framework" {
          return runtimeFrameworksPath.appending(component: RUNTIME_NAME)
        } else {
          // note: this is not correct for all platforms, but we only actually use it on macOS.
          return runtimeFrameworksPath.appending(component: "lib\(RUNTIME_NAME).dylib")
        }
      }
      
      Log.debug("""
applicationPath: \(applicationDirPath)
runtimeFrameworksPath: \(runtimeFrameworksPath)
""")

      guard localFileSystem.exists(libraryPath) else {
        throw CLIError.runtimeNotFound
      }

      let target = try Utils.computeMinimumDeploymentTarget(
        of: libraryPath
      )

      let sdkPath = try Utils.sdk()

      var cmd: [String] = []
      cmd += [swiftCompilerPath.pathString]
      
      if runtimeFrameworksPath.extension == "framework" {
        cmd += [
          "-F", runtimeFrameworksPath.parentDirectory.pathString,
          "-framework", RUNTIME_NAME,
          "-Xlinker", "-rpath", "-Xlinker", runtimeFrameworksPath.parentDirectory.pathString,
        ]
      } else {
        cmd += [
          "-L", runtimeFrameworksPath.pathString,
          "-l\(RUNTIME_NAME)",
          "-Xlinker", "-rpath", "-Xlinker", runtimeFrameworksPath.pathString
        ]
      }
      
      cmd += ["-target", triple.tripleString(forPlatformVersion: target!.versionString)]

      cmd += ["-sdk", sdkPath.pathString]
      cmd += Utils.flags()

      cmd += [targetFilePath.pathString]
      cmd += [
//        "-Xfrontend", "-disable-implicit-concurrency-module-import",
        "-Xfrontend", "-disable-implicit-string-processing-module-import",
        "-I", applicationDirPath.pathString,
      ]
      cmd += ["-swift-version", "5"]

      return try await withTemporaryDirectory { workingPath in

        let compiledFile = workingPath.appending(component: "compiled")
        
        // make a binary
        do {
          
          cmd += ["-o", compiledFile.pathString]
          
          Log.debug("Make executable binary\n\(cmd.joined(separator: "\\\n"))")
          
          // compile
          let result = try await TSCBasic.Process.popen(
            arguments: cmd,
            environment: ProcessInfo.processInfo.environment,
            loggingHandler: { log in }
          )
          
          // Return now if there was an error.
          if result.exitStatus != .terminated(code: 0) {
            let output = try result.utf8stderrOutput()
            Log.error("\(output)\n\(cmd.joined(separator: " "))")
            throw DomainError.failedToCompile
          }
          
        }
        
        // make an output
        do {
                
          var cmd: [String] = []
          
          cmd += [compiledFile.pathString]
          
          cmd += ["-context", context.json()]

          let result = try await TSCBasic.Process.popen(
            arguments: cmd,
            environment: ProcessInfo.processInfo.environment,
            loggingHandler: { log in }
          )

          // Return now if there was an error.
          if result.exitStatus != .terminated(code: 0) {
            
            let output = try result.utf8stderrOutput()
            Log.error("\(output)\n\(cmd.joined(separator: " "))")
            
            throw DomainError.failureInMakingOutput
          }
          
          Log.info(try result.utf8Output())
   
        }
        
      }
    }

  }

}

func withTemporaryDirectory<R>(_ work: @escaping (AbsolutePath) async throws -> R) async throws -> R {
  
  try await withCheckedThrowingContinuation { continuation in
    
    do {
      try withTemporaryDirectory { path, completion -> Void in
        Task {
          do {
            let r = try await work(path)
            completion(path)
            continuation.resume(returning: r)
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
    fileSystem: FileSystem
  ) throws -> AbsolutePath {
                 
    return try AbsolutePath(validating: (Bundle.main.executablePath! as NSString).resolvingSymlinksInPath).parentDirectory
  }
}

@main
enum Main {
  static func main() async {
    await CLI.main()
  }
}
