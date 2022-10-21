import GrainDescriptor

serialize {
  
  GrainObject {
    GrainMember("value") {
      1
    }
    
    for i in 0..<10 {
      GrainMember("key_\(i)") {
        i
      }
    }
  }
  
}
