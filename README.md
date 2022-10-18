# SerialDSL

A DSL for representing serialized data structure (like JSON).

## Overview

```swift
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
```

```swift
let results = Results(records: [
  .init(name: "A", age: 1),
  .init(name: "B", age: 2),
])

let json: String = results.renderJSON()
```

```json
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
```
