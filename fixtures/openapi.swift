import GrainDescriptor

serialize {
  Endpoint(methods: [
    .init(
      method: .get,
      summary: "Hello",
      description: "Hello Get Method",
      operationID: "id",
      tags: ["Awesome API"]
    )
  ])
}

// MARK: - Components

public struct Endpoint: GrainView {
  
  public var methods: [Method]
  
  public var body: some GrainView {
    GrainObject {
      for method in methods {
        GrainMember(method.method.rawValue) {
          method
        }
      }
    }
  }
}

public struct Method: GrainView {
  
  public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
  }
  
  public var method: HTTPMethod
  public var summary: String
  public var description: String
  public var operationID: String
  public var tags: [String]
  
  public var body: some GrainView {
    GrainObject {
      GrainMember("operationId") { operationID }
      GrainMember("description") { description }
      GrainMember("summary") { summary }
      GrainMember("tags") { tags }
    }
  }
}
