import Foundation

public protocol JSONView: Encodable {
  
  associatedtype Body: JSONView
  
  @ValueBuilder var body: Body { get }
}

extension JSONView {
  
  public func encode(to encoder: Encoder) throws {
    try body.encode(to: encoder)
  }
  
}

extension JSONView where Body == Never {
  
  @_spi(JSONNever)
  public var body: Body {
    fatalError()
  }
  
}

extension Never: JSONView {
  
  @_spi(JSONNever)
  public var body: JSONEmtpy {
    return JSONEmtpy()
  }
}

public struct JSONEmtpy: JSONView, Decodable {
  
  public typealias Body = Never
  
}

public struct JSONNull: JSONView {
  public typealias Body = Never
  
}

public struct JSONBoolean: JSONView, Encodable {
  
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

public struct JSONNumber: JSONView, Encodable {
  
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

public struct JSONString: JSONView, Encodable {
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

public struct JSONArray: JSONView, Encodable {
  
  public typealias Body = Never
  
  public var elements: [any JSONView]
  
  public init(@ElementsBuilder _ elements: () -> [any JSONView]) {
    self.elements = elements()
  }
      
  init(elements: [any JSONView]) {
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
    
    public static func buildExpression(_ expression: NSNull) -> JSONNull {
      .init()
    }
    
    public static func buildExpression(_ expression: String) -> JSONString {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Bool) -> JSONBoolean {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int8) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int16) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int32) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Int64) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt8) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt16) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt32) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: UInt64) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Float) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression(_ expression: Double) -> JSONNumber {
      .init(expression)
    }
    
    public static func buildExpression<J: JSONView>(_ component: J) -> J {
      component
    }
    
    public static func buildBlock() -> JSONEmtpy {
      .init()
    }
           
    public static func buildBlock(_ components: [any JSONView]) -> [any JSONView] {
      return components
    }
    
    public static func buildBlock(_ components: any JSONView...) -> [any JSONView] {
      return components
    }
    
  }

}

public struct JSONObject: JSONView {
  
  public typealias Body = Never
  
  public var members: [JSONMember]
  
  init(@MemberBuilder _ members: () -> [JSONMember]) {
    self.members = members()
  }
  
  public func encode(to encoder: Encoder) throws {
    try members.forEach {
      try $0.encode(to: encoder)
    }
  }
  
  @resultBuilder
  public enum MemberBuilder {
    
    public static func buildBlock() -> [JSONMember] {
      []
    }
    
    public static func buildBlock(_ component: JSONMember...) -> [JSONMember] {
      component
    }
    
  }
  
}

public struct JSONMember: JSONView {
  
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
  public let value: any JSONView
  
  public init(_ name: String, @ValueBuilder value: () -> any JSONView) {
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
  
  public static func buildExpression(_ expression: NSNull) -> JSONNull {
    .init()
  }
  
  public static func buildExpression(_ expression: String) -> JSONString {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: Bool) -> JSONBoolean {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: Int) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: Int8) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: Int16) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: Int32) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: Int64) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: UInt) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: UInt8) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: UInt16) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: UInt32) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: UInt64) -> JSONNumber {
    .init(expression)
  }

  public static func buildExpression(_ expression: Float) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression(_ expression: Double) -> JSONNumber {
    .init(expression)
  }
  
  public static func buildExpression<J: JSONView>(_ component: J) -> J {
    component
  }
  
  public static func buildExpression<J: JSONView>(_ component: [J]) -> JSONArray {
    .init(elements: component)
  }
  
  
  public static func buildBlock() -> JSONEmtpy {
    .init()
  }
  
  public static func buildBlock<J: JSONView>(_ component: J) -> J {
    component
  }
  
 
}
