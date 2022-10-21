import XCTest

@testable import GrainDescriptor

final class JSONDSLTests: XCTestCase {

  let encoder = JSONEncoder()

  func toString(_ j: some GrainView) -> String {
    let data = try! encoder.encode(j)
    return String(data: data, encoding: .utf8)!
  }

  func compare(
    _ j: some GrainView,
    _ expects: String,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    XCTAssertEqual(toString(j), expects, file: file, line: line)
  }

  override func setUp() {
    encoder.outputFormatting = .prettyPrinted
  }

  func type<J: GrainView>(@GrainBuilder _ b: () -> J) -> J {
    b()
  }

  func testArray_1() {

    compare(
      GrainArray {
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
      GrainArray {
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
      GrainArray {
        GrainObject {
          GrainMember("a") {
            1
          }
        }
        GrainObject {
          GrainMember("b") {
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
      GrainObject {
        GrainMember("a") {
          GrainNull()
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
      GrainObject {
        GrainMember("a") {
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
      GrainObject {
        for name in ["a", "b"] {
          GrainMember(name) {
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

    _ = GrainObject {

      if flag {
        GrainMember("1") {
          1
        }
      }

    }

    _ = GrainObject {

      if flag {
        GrainMember("1") {
          1
        }
      }

      GrainMember("1") {
        1
      }

    }

    _ = GrainObject {

      [
        GrainMember("1") {
          1
        },
        GrainMember("1") {
          1
        },
      ]

    }

    _ = GrainObject {

      for name in ["a", "b"] {
        GrainMember(name) {
          ["a", "b"]
        }
      }

    }

    _ = GrainArray {
      1
    }

    _ = GrainArray {
      1
      3
      false
      ""
    }

    _ = GrainArray {
      [1, 2]
    }

    _ = GrainArray {
      [1, 2]
      ["1"]
    }

    _ = GrainArray {

      for name in ["a", "b"] {
        name
      }

    }

    _ = GrainArray {

      if flag {
        1
      }

    }

  }

  func test_branch_1() {

    let flag = false

    compare(
      GrainArray {

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
      GrainArray {

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
