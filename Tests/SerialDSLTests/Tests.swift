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

  func test_array() {

    compare(
      SerialObject {
        SerialMember("a") {
          ["a", "b"]
        }
      },
      """
      {
        "a" : [
          "a",
          "b"
        ]
      }
      """
    )

  }

  func test_loop() {

    compare(
      SerialObject {
        for name in ["a", "b"] {
          SerialMember(name) {
            ["a", "b"]
          }
        }
      },
      """
      {
        "a" : [
          "a",
          "b"
        ],
        "b" : [
          "a",
          "b"
        ]
      }
      """
    )
  }

  func test_control_flow() {

    let flag = false

    _ = SerialObject {

      if flag {
        SerialMember("1") {
          1
        }
      }

    }

    _ = SerialObject {

      if flag {
        SerialMember("1") {
          1
        }
      }

      SerialMember("1") {
        1
      }

    }

    _ = SerialObject {

      [
        SerialMember("1") {
          1
        },
        SerialMember("1") {
          1
        },
      ]

    }

    _ = SerialObject {

      for name in ["a", "b"] {
        SerialMember(name) {
          ["a", "b"]
        }
      }

    }

    _ = SerialArray {
      1
    }

    _ = SerialArray {
      1
      3
      false
      ""
    }

    _ = SerialArray {
      [1, 2]
    }

    _ = SerialArray {
      [1, 2]
      ["1"]
    }

    _ = SerialArray {

      for name in ["a", "b"] {
        name
      }

    }

    _ = SerialArray {

      if flag {
        1
      }

    }

  }

  func test_branch_1() {

    let flag = false

    compare(
      SerialArray {

        if flag {
          1
        }

        1
      },
      """
      [
        1
      ]
      """
    )
  }

  func test_branch_2() {

    let flag = false

    compare(
      SerialArray {

        if flag {
          1
        }

        if flag {
          1
        } else {
          2
        }
      },
      """
      [
        2
      ]
      """
    )

  }
}
