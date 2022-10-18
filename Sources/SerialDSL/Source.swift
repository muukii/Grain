import Foundation

public protocol SerialView: Encodable {
  
  associatedtype Body: SerialView
  
  @ValueBuilder var body: Body { get }
  
}

extension SerialView {
  
  public typealias Object = SerialObject
  public typealias Member = SerialMember
  public typealias Number = SerialNumber
  public typealias Null = SerialNull
  public typealias Boolean = SerialBoolean
  public typealias Array = SerialArray
  
}

extension SerialView {
  
  public func encode(to encoder: Encoder) throws {
    try body.encode(to: encoder)
  }
  
  /// Renders data as JSON in String
  public func renderJSON() -> String {
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let data = try! encoder.encode(self)
    return String(data: data, encoding: .utf8)!
  }
  
}

extension SerialView where Body == Never {
  
  @_spi(JSONNever)
  public var body: Body {
    fatalError()
  }
  
}

extension Never: SerialView {
  
  @_spi(JSONNever)
  public var body: SerialEmtpy {
    return SerialEmtpy()
  }
}

public struct SerialEmtpy: SerialView, Decodable {
  
  public typealias Body = Never
  
  public init() {
    
  }
  
  public func encode(to encoder: Encoder) throws {
    
  }
}

public struct SerialNull: SerialView {
  public typealias Body = Never
  
  public init() {
    
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encodeNil()
  }
}

public struct SerialBoolean: SerialView, Encodable {
  
  public typealias Body = Never
  
  public var value: Bool
  
  public init(_ value: Bool) {
    self.value = value
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
}

public struct SerialNumber: SerialView, Encodable {
  
  public enum Number {
    case int(Int)
    case int8(Int8)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    
    case uint(UInt)
    case uint8(UInt8)
    case uint16(UInt16)
    case uint32(UInt32)
    case uint64(UInt64)
    
    case float(Float)
    case double(Double)
  }
  
  public typealias Body = Never
  
  public var value: Number
  
  public init(_ value: Int) {
    self.value = .int(value)
  }
  
  public init(_ value: Int8) {
    self.value = .int8(value)
  }
  
  public init(_ value: Int16) {
    self.value = .int16(value)
  }
  
  public init(_ value: Int32) {
    self.value = .int32(value)
  }
  
  public init(_ value: Int64) {
    self.value = .int64(value)
  }
  
  public init(_ value: UInt) {
    self.value = .uint(value)
  }
  
  public init(_ value: UInt8) {
    self.value = .uint8(value)
  }
  
  public init(_ value: UInt16) {
    self.value = .uint16(value)
  }
  
  public init(_ value: UInt32) {
    self.value = .uint32(value)
  }
  
  public init(_ value: UInt64) {
    self.value = .uint64(value)
  }
  
  public init(_ value: Float) {
    self.value = .float(value)
  }
  
  public init(_ value: Double) {
    self.value = .double(value)
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    
    switch value {
    case .int(let value):
      try container.encode(value)
    case .int8(let value):
      try container.encode(value)
    case .int16(let value):
      try container.encode(value)
    case .int32(let value):
      try container.encode(value)
    case .int64(let value):
      try container.encode(value)
    case .uint(let value):
      try container.encode(value)
    case .uint8(let value):
      try container.encode(value)
    case .uint16(let value):
      try container.encode(value)
    case .uint32(let value):
      try container.encode(value)
    case .uint64(let value):
      try container.encode(value)
    case .float(let value):
      try container.encode(value)
    case .double(let value):
      try container.encode(value)
    }
    
  }
  
}

public struct SerialString: SerialView, Encodable {
  public typealias Body = Never
  
  public var value: String
  
  public init(_ value: String) {
    self.value = value
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
  
}

public struct SerialArray: SerialView, Encodable {
  
  public typealias Body = Never
  
  public var elements: [any SerialView]
  
  public init(@ElementsBuilder _ elements: () -> [any SerialView]) {
    self.elements = elements()
  }
      
  init(elements: [any SerialView]) {
    self.elements = elements
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try elements.forEach {
      try container.encode($0)
    }
  }
      
  @resultBuilder
  public enum ElementsBuilder {
    
    public static func buildExpression(_ expression: NSNull) -> SerialNull {
      .init()
    }
    
    public static func buildExpression(_ expression: String) -> SerialString {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Bool) -> SerialBoolean {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int8) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int16) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int32) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int64) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt8) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt16) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt32) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt64) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Float) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Double) -> SerialNumber {
      .init(expression)
    }
    
    public static func buildExpression<J: SerialView>(_ component: J) -> J {
      component
    }
    
    public static func buildBlock() -> SerialEmtpy {
      .init()
    }
           
    public static func buildBlock(_ components: [any SerialView]) -> [any SerialView] {
      return components
    }
    
    public static func buildBlock(_ components: any SerialView...) -> [any SerialView] {
      return components
    }
    
  }

}

public struct SerialObject: SerialView {
  
  public typealias Body = Never
  
  public var members: [SerialMember]
  
  public init(@MemberBuilder _ members: () -> [SerialMember]) {
    self.members = members()
  }
  
  public func encode(to encoder: Encoder) throws {
    try members.forEach {
      try $0.encode(to: encoder)
    }
  }
  
  @resultBuilder
  public enum MemberBuilder {
    
    public static func buildBlock() -> [SerialMember] {
      []
    }
    
    public static func buildBlock(_ component: SerialMember...) -> [SerialMember] {
      component
    }
    
  }
  
}

public struct SerialMember: SerialView {
  
  public typealias Body = Never
  
  struct CustomStringKey: CodingKey {
    var stringValue: String
    
    init?(stringValue: String) {
      self.stringValue = stringValue
    }
    
    var intValue: Int?
    
    init?(intValue: Int) {
      return nil
    }
    
  }
  
  public let name: String
  public let value: any SerialView
  
  public init(_ name: String, @ValueBuilder value: () -> any SerialView) {
    self.name = name
    self.value = value()
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CustomStringKey.self)
    try container.encode(value, forKey: .init(stringValue: name)!)
  }
}

@resultBuilder
public enum ValueBuilder {
  
  public static func buildExpression(_ expression: NSNull) -> SerialNull {
    .init()
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == NSNull {
    .init(elements: expression.map { _ in SerialNull() })
  }
  
  public static func buildExpression(_ expression: String) -> SerialString {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == String {
    .init(elements: expression.map { SerialString($0) })
  }
  
  public static func buildExpression(_ expression: Bool) -> SerialBoolean {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == Bool {
    .init(elements: expression.map { SerialBoolean($0) })
  }
  
  public static func buildExpression(_ expression: Int) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == Int {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: Int8) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == Int8 {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: Int16) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == Int16 {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: Int32) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == Int32 {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: Int64) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == Int64 {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: UInt) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == UInt {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: UInt8) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == UInt8 {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: UInt16) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == UInt16 {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: UInt32) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == UInt32 {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: UInt64) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == UInt64 {
    .init(elements: expression.map { SerialNumber($0) })
  }

  public static func buildExpression(_ expression: Float) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == Float {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression(_ expression: Double) -> SerialNumber {
    .init(expression)
  }
  
  public static func buildExpression<S: Sequence>(_ expression: S) -> SerialArray where S.Element == Double {
    .init(elements: expression.map { SerialNumber($0) })
  }
  
  public static func buildExpression<J: SerialView>(_ component: J) -> J {
    component
  }
  
  public static func buildExpression<J: SerialView>(_ component: [J]) -> SerialArray {
    .init(elements: component)
  }
  
  
  public static func buildBlock() -> SerialEmtpy {
    .init()
  }
  
  public static func buildBlock<J: SerialView>(_ component: J) -> J {
    component
  }
  
 
}