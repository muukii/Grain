import TSCBasic
import TSCUtility

/// Represents a platform version.
public struct PlatformVersion: Equatable, Hashable, Codable {
  
  /// The unknown platform version.
  public static let unknown: PlatformVersion = .init("0.0.0")
  
  /// The underlying version storage.
  private let version: Version
  
  /// The string representation of the version.
  public var versionString: String {
    var str = "\(version.major).\(version.minor)"
    if version.patch != 0 {
      str += ".\(version.patch)"
    }
    return str
  }
  
  public var major: Int { version.major }
  public var minor: Int { version.minor }
  public var patch: Int { version.patch }
  
  /// Create a platform version given a string.
  ///
  /// The platform version is expected to be in format: X.X.X
  public init(_ version: String) {
    let components = version.split(separator: ".").compactMap({ Int($0) })
    assert(!components.isEmpty && components.count <= 3, version)
    switch components.count {
    case 1:
      self.version = Version(components[0], 0, 0)
    case 2:
      self.version = Version(components[0], components[1], 0)
    case 3:
      self.version = Version(components[0], components[1], components[2])
    default:
      fatalError("Unexpected number of components \(components)")
    }
  }
}

extension PlatformVersion: Comparable {
  public static func < (lhs: PlatformVersion, rhs: PlatformVersion) -> Bool {
    return lhs.version < rhs.version
  }
}

extension PlatformVersion: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(value)
  }
}
