import XCTest

@testable import SerialDSL

final class JSONDSLTests: XCTestCase {

  let encoder = JSONEncoder()

  func toString(_ j: some SerialView) -> String {
    let data = try! encoder.encode(j)
    return String(data: data, encoding: .utf8)!
  }

  func compare(
    _ j: some SerialView,
    _ expects: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertEqual(toString(j), expects, file: file, line: line)
  }

  override func setUp() {
    encoder.outputFormatting = .prettyPrinted
  }

  func type<J: SerialView>(@ValueBuilder _ b: () -> J) -> J {
    b()
  }

  func testArray_1() {

    compare(
      SerialArray {
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
      SerialArray {
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
      SerialArray {
        SerialObject {
          SerialMember("a") {
            1
          }
        }
        SerialObject {
          SerialMember("b") {
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

  func test_null() {

    compare(
      SerialObject {
        SerialMember("a") {
          SerialNull()
        }
      },
      """
      {
        "a" : null
      }
      """
    )

  }

  func test_component() throws {

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

    let r = Results(records: [
      .init(name: "A", age: 1),
      .init(name: "B", age: 2),
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
