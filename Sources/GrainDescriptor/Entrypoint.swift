@_implementationOnly import Darwin.C

@_exported import Foundation
@_exported import Alamofire
@_exported import TSCBasic

public struct Serialization {
    
  private let _encode: (any GrainView) throws -> Data
  public let fileExtension: String
  
  public init(fileExtension: String, encode: @escaping (any GrainView) throws -> Data) {
    self.fileExtension = fileExtension
    self._encode = encode
  }
  
  public static var json: Self {
    
    return .json(
      outputFormatting: [.prettyPrinted, .sortedKeys],
      dateEncodingStrategy: .iso8601,
      dataEncodingStrategy: .base64
    )
    
  }
  
  public static func json(
    outputFormatting: JSONEncoder.OutputFormatting,
    dateEncodingStrategy: JSONEncoder.DateEncodingStrategy,
    dataEncodingStrategy: JSONEncoder.DataEncodingStrategy
  ) -> Self {
    
    let encoder = JSONEncoder()
    
    encoder.outputFormatting = outputFormatting
    encoder.dateEncodingStrategy = dateEncodingStrategy
    encoder.dataEncodingStrategy = dataEncodingStrategy
    
    return .init(
      fileExtension: "json",
      encode: {
        try encoder.encode($0)
    })
    
  }
  
  public func encode(_ view: some GrainView) throws -> Data {
    return try _encode(view)
  }
    
}

public struct Context: Codable {
  
  public let filePath: AbsolutePath
  public let outputDir: AbsolutePath?
  
  public init(
    filePath: AbsolutePath,
    outputDir: AbsolutePath?
  ) {
    self.filePath = filePath
    self.outputDir = outputDir
  }
  
  public func json() -> String {
    let e = JSONEncoder()
    let d = try! e.encode(self)
    return String(data: d, encoding: .utf8)!
  }
    
  public static func decode(_ data: Data) -> Self {
    let d = JSONDecoder()
    let r = try! d.decode(Self.self, from: data)
    return r
  }
  
  public func write(data: Data, into path: AbsolutePath) throws {
    let url = URL(fileURLWithPath: path.pathString)
    try data.write(to: url, options: [.atomic])
  }
    
}

public struct Output {
  
  public enum FileOption {
    case auto
    case named(String)
  }
  
  private let _run: (Context, Data, String) throws -> Void
  
  public init(_ run: @escaping (Context, Data, String) throws -> Void) {
    self._run = run
  }
  
  func run(context: Context, data: Data, fileExtension: String) throws {
    try _run(context, data, fileExtension)
  }
  
  public static var stdout: Self {
    .init { _, data, _ in
      let text = String(data: data, encoding: .utf8)!
      print(text)
    }
  }
  
  public static func file(path: AbsolutePath) -> Self {
    .init { context, data, _ in
      try context.write(data: data, into: path)
      Log.info("Write -> \(path)")
    }
  }
  
  public static var file: Self {
    .file(.auto)
  }
  
  public static func file(_ option: FileOption) -> Self {
    .init { context, data, fileExtension in
      
      let basePath: AbsolutePath
      
      if let outputDir = context.outputDir {
        basePath = outputDir
      } else {
        basePath = context.filePath.parentDirectory
      }
      
      let fileName: String
      switch option {
      case .auto:    
        fileName = [context.filePath.basenameWithoutExt, fileExtension].joined(separator: ".")
      case .named(let name):
        fileName = [name, fileExtension].joined(separator: ".")
      }
                       
      let path = basePath.appending(component: fileName)
      try context.write(data: data, into: path)
      Log.info("Write -> \(path)")
    }
  }
   
}

public func serialize(
  serialization: Serialization = .json,
  output: Output = .stdout,
  @GrainBuilder _ thunk: () throws -> some GrainView
) {
  
  do {
    let value = try thunk()
    let data = try serialization.encode(value)
    try output.run(context: context, data: data, fileExtension: serialization.fileExtension)
  } catch {
    print("❌ Serialization failed:", error)
  }
}

public let context: Context = {
  if let optIdx = CommandLine.arguments.firstIndex(of: "-context") {
    let encodedContext = CommandLine.arguments[optIdx + 1]
    return Context.decode(encodedContext.data(using: .utf8)!)
  } else {
    fatalError("Grain context was not provided")
  }
}()
