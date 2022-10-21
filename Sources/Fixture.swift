import SerialDSL
import Foundation

struct Record: SerialView {
  
  let name: String
  let age: Int
  
  var body: some SerialView {
    Object {
      Member("name") {
        name
      }
      Member("age") {
        age
      }
    }
  }
  
}

struct Results: SerialView {
  
  let records: [Record]
  
  var body: some SerialView {
    Object {
      Member("results") {
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
  
  SerialObject {
    SerialMember("data") {
      results
    }
  }
  
}
