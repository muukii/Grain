import Foundation

public protocol JSONView: Encodable {
  
  associatedtype Body: JSONView
  
  @JSONBuilder var body: Body { get }
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
  
  public typealias Body = Never
  
  public var value: Int
  
  public init(_ value: Int) {
    self.value = value
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
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
  
  public init(@JSONBuilder _ elements: () -> [any JSONView]) {
    self.elements = elements()
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.unkeyedContainer()
    try elements.forEach {
      try container.encode($0)
    }
  }
    
//  @resultBuilder
//  public enum Builder {
//
//    public static func buildExpression(_ expression: Bool) -> any JSONView {
//      JSONBoolean(expression)
//    }
//
//    public static func buildExpression(_ expression: Int) -> any JSONView {
//      JSONNumber(expression)
//    }
//
//    public static func buildExpression(_ expression: String) -> any JSONView {
//      JSONString(expression)
//    }
//
//    public static func buildExpression(_ expression: any JSONView) -> any JSONView {
//      expression
//    }
//
//    public static func buildExpression(_ expression: any JSONView) -> any JSONView {
//      expression
//    }
//
//    public static func buildBlock() -> [any JSONView] {
//      []
//    }
//
//    public static func buildBlock(_ component: any JSONView) -> [any JSONView] {
//      [component]
//    }
//
//    public static func buildBlock(_ components: [any JSONView]) -> [any JSONView] {
//      components
//    }
//
////    public static func buildBlock(_ components: any JSONView...) -> [any JSONView] {
////      components
////    }
//
//  }
  

}

public struct JSONObject: JSONView {
  
  public typealias Body = Never
  
  public var members: [JSONMember]
  
  init(@Builder _ members: () -> [JSONMember]) {
    self.members = members()
  }
  
  public func encode(to encoder: Encoder) throws {
    try members.forEach {
      try $0.encode(to: encoder)
    }
  }
  
  @resultBuilder
  public enum Builder {
    
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
  
  public init(_ name: String, @JSONBuilder value: () -> any JSONView) {
    self.name = name
    self.value = value()
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CustomStringKey.self)
    try container.encode(value, forKey: .init(stringValue: name)!)
  }
}

@resultBuilder
public enum JSONBuilder {
  
  public static func buildBlock(_ expression: Bool) -> JSONBoolean {
    JSONBoolean(expression)
  }
  
  public static func buildBlock(_ expression: Int) -> JSONNumber {
    .init(expression)
  }
  
//  public static func buildExpression<J: JSONView>(_ component: J) -> J {
//    component
//  }

  public static func buildBlock(_ components: [any JSONView]) -> JSONArray {
    JSONArray.init({ return components })
  }
  
  public static func buildBlock(_ components: any JSONView...) -> JSONArray {
    JSONArray.init({ return components })
  }
  
  public static func buildBlock() -> JSONEmtpy {
    .init()
  }
  
  public static func buildBlock<J: JSONView>(_ component: J) -> J {
    component
  }
  
}
