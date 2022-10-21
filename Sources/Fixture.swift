import GrainDescriptor
import Foundation

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

let results = Results(records: [
  .init(name: "A", age: 1),
  .init(name: "B", age: 2),
])

serialize {
  
  GrainObject {
    GrainMember("data") {
      results
    }
  }
  
}
