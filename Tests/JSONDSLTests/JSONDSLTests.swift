import XCTest

@testable import JSONDSL

final class JSONDSLTests: XCTestCase {
  
  let encoder = JSONEncoder()
  
  func toString(_ j: some JSONView) -> String {
    let data = try! encoder.encode(j)
    return String(data: data, encoding: .utf8)!
  }
  
  func compare(_ j: some JSONView, _ expects: String, file: StaticString = #filePath, line: UInt = #line) {
    XCTAssertEqual(toString(j), expects, file: file, line: line)
  }
  
  override func setUp() {
    encoder.outputFormatting = .prettyPrinted
  }
  
  func type<J: JSONView>(@ValueBuilder _ b: () -> J) -> J {
    b()
  }
    
  func testArray_1() {
    
    compare(
      JSONArray {
        1
      },
      """
      [
        1
      ]
      """
    )
    
  }
  
  func testArray_2() {
    
    compare(
      JSONArray {
        1
        false
        2.5
      },
      """
      [
        1,
        false,
        2.5
      ]
      """
    )
    
  }
    
  func testArray_3() {
              
    compare(
      JSONArray {
        JSONObject {
          JSONMember("a") {
            1
          }
        }
        JSONObject {
          JSONMember("b") {
            1
          }
        }
      },
      """
      [
        {
          "a" : 1
        },
        {
          "b" : 1
        }
      ]
      """
    )
    
  }
  
  func test_component() throws {
    
    struct Record: JSONView {
      
      let name: String
      let age: Int
      
      var body: some JSONView {
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
     
    struct Results: JSONView {
      
      let records: [Record]
      
      var body: some JSONView {
        Object {
          Member("results") {
            records
          }
        }
        
      }
      
    }
        
    let r = Results(records: [
      .init(name: "A", age: 1),
      .init(name: "B", age: 2)
    ])
  
    compare(
      r,
      """
      {
        "results" : [
          {
            "name" : "A",
            "age" : 1
          },
          {
            "name" : "B",
            "age" : 2
          }
        ]
      }
      """
    )
    
  }
}
