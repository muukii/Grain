import XCTest

@testable import JSONDSL

final class JSONDSLTests: XCTestCase {
  func testExample() throws {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct
    // results.
    
    ///
    
    struct MyComponent: JSONView {
      
      var body: some JSONView {
        JSONObject {
          JSONMember("a") {
            JSONArray {
              JSONMember("b") {
                JSONArray {
                  1
                }
              }
            }
          }
        }
        
      }
      
    }
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    
    let o = JSONObject {
      
      JSONMember("a") {
        JSONArray {
          JSONMember("b") {
            JSONArray {
              1
              false
              JSONMember("b") {
                JSONArray {
                  1
                }
              }
            }
          }
        }
      }
      
      JSONMember("b") {
        JSONArray {
          JSONMember("b") {
            JSONArray {
              1
              false
              JSONMember("b") {
                JSONArray {
                  1
                }
              }
            }
          }
        }
      }
      
    }
    
    let c = MyComponent()
    
    let data = try! encoder.encode(o)
    print(String(data: data, encoding: .utf8)!)
    

    
  }
}
