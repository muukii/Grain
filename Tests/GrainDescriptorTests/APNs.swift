
import XCTest
import GrainDescriptor

// MARK: - Variables

let param_a = GrainMember("param_a") {
  "111"
}

let simulatorTarget = GrainMember("Simulator Target Bundle") {
  "app.muukii.myapp"
}

final class APNsTests: XCTestCase {
  
  func test_aggregation() {
    
    compare(
      GrainObject {
        GrainMember("a") {
          ["a", "b"]
        }
        GrainMember("a") {
          ["a", "b", "c"]
        }
      },
      """
      {
        "a" : [
          "a",
          "b",
          "c"
        ]
      }
      """
    )
     
  }
  
  func test_spread() {
    
    let object1 = GrainObject {
      GrainMember("a") { 1 }
    }
    
    let object2 = GrainObject {
      GrainMember("a") { 1 }
      GrainMember("b") { 1 }
    }
    
    compare(
      GrainObject {
        object1.spread
        object2.spread
      },
      """
      {
        "a" : 1,
        "b" : 1
      }
      """
    )
    
  }
  
}
//
//struct APNS<Content: GrainView>: GrainView {
//
//  let content: Content
//
//  init(@GrainBuilder _ content: () -> Content) {
//    self.content = content()
//  }
//
//  var body: some GrainView {
//    GrainObject {
//      content
//    }
//  }
//
//}

struct APS: GrainView {
  
  let alert: String
  
  var body: some GrainView {
    
    GrainObject {
//      GrainMember("alert") {
//        alert
//      }
    }
    
  }
}


