import GrainDescriptor

// ./fixtures/context.swift --user-info '{"name" : "muukii"}'

struct Parameter: Decodable {
  var name: String
}

let parameter = try context.userInfo(Parameter.self)

serialize(.json) {
  
  GrainObject {
    GrainMember("context") {
      parameter.name
    }
  }
  
}
