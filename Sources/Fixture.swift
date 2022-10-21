import GrainDescriptor
import Foundation
import Alamofire

let response = try await AF.request("https://httpbin.org/get").serializingString().value

serialize {
  
  GrainObject {
    GrainMember("data") {
      Results(records: [
        .init(name: "A", age: 1),
        .init(name: "B", age: 2),
      ])
    }
    GrainMember("result") {
      response
    }
  }
  
}

struct Record: GrainView {
  
  let name: String
  let age: Int
  
  var body: some GrainView {
    GrainObject {
      GrainMember("name") {
        name
      }
      GrainMember("age") {
        age
      }
    }
  }
  
}

struct Results: GrainView {
  
  let records: [Record]
  
  var body: some GrainView {
    GrainObject {
      GrainMember("results") {
        records
      }
    }
  }
  
}
