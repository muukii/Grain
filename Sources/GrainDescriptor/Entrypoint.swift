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

public func serialize(
  serialization: Serialization = .json,
  @GrainBuilder _ thunk: () throws -> some GrainView
) {
  
  do {
    let value = try thunk()
        
    let data = try serialization.encode(value)
    let text = String(data: data, encoding: .utf8)!
    
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
  } catch {
    print("❌ Serialization failed:", error)
  }
}
