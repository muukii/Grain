@_implementationOnly import Darwin.C

import Foundation
import Combine

public struct Serialization {
    
  private let _encode: (any GrainView) throws -> Data
  
  public init(encode: @escaping (any GrainView) throws -> Data) {
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
    
    return .init(encode: {
      try encoder.encode($0)
    })
    
  }
  
  public func encode(_ view: some GrainView) throws -> Data {
    return try _encode(view)
  }
    
}

public struct Context: Codable {
  
  public let filePath: String
  
  public init(filePath: String) {
    self.filePath = filePath
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
}

public struct Header: Codable {
  public let outputConfiguration: OutputConfiguration
  
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
}

public struct OutputConfiguration: Codable {

  public var fileExtension: String?
    
  public init(fileExtension: String? = nil) {
    self.fileExtension = fileExtension
  }
    
}

public func serialize(
  name: String? = nil,
  serialization: Serialization = .json,
  outputConfiguration: OutputConfiguration = .init(fileExtension: "json"),
  @GrainBuilder _ thunk: () throws -> some GrainView
) {
  
  do {
    let value = try thunk()
        
    let data = try serialization.encode(value)
    let text = String(data: data, encoding: .utf8)!
    
    // write output
    do {
      if let optIdx = CommandLine.arguments.firstIndex(of: "-fileno-output") {
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
    
    // write header
    do {
      if let optIdx = CommandLine.arguments.firstIndex(of: "-fileno-header") {
        if let outputFileDesc = Int32(CommandLine.arguments[optIdx + 1]) {
          guard let fd = fdopen(outputFileDesc, "w") else {
            return
          }
          fputs(Header.init(outputConfiguration: outputConfiguration).json(), fd)
          fclose(fd)
        }
      } else {
      }
    }
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
