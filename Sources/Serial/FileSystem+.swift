import TSCBasic
import Foundation

extension FileSystem {
  public func readFileContents(_ path: AbsolutePath) throws -> Data {
    return try Data(self.readFileContents(path).contents)
  }
  
  public func readFileContents(_ path: AbsolutePath) throws -> String {
    return try String(decoding: self.readFileContents(path), as: UTF8.self)
  }
  
  public func writeFileContents(_ path: AbsolutePath, data: Data) throws {
    return try self.writeFileContents(path, bytes: .init(data))
  }
  
  public func writeFileContents(_ path: AbsolutePath, string: String) throws {
    return try self.writeFileContents(path, bytes: .init(encodingAsUTF8: string))
  }
  
  public func writeFileContents(_ path: AbsolutePath, provider: () -> String) throws {
    return try self.writeFileContents(path, string: provider())
  }
}
