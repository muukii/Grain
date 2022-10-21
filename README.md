# Grain

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

## Showcases

### OpenAPI Specification

```swift
public struct Endpoint: SerialView {

  public var methods: [Method]

  public var body: some SerialView {
    Object {
      for method in methods {
        Member(method.method.rawValue) {
          method
        }
      }
    }
  }
}

public struct Method: SerialView {

  public enum HTTPMethod: String {
    case get
    case post
    case put
    case delete
  }

  public var method: HTTPMethod
  public var summary: String
  public var description: String
  public var operationID: String
  public var tags: [String]

  public var body: some SerialView {
    Object {
      Member("operationId") { operationID }
      Member("description") { description }
      Member("summary") { summary }
      Member("tags") { tags }
    }
  }
}
```
```swift

let endpoint = Endpoint(methods: [
  .init(
    method: .get,
    summary: "Hello",
    description: "Hello Get Method",
    operationID: "id",
    tags: ["Awesome API"]
  )
])

let json = endpoint.renderJSON()
```

```json
{
  "get" : {
    "description" : "Hello Get Method",
    "operationId" : "id",
    "summary" : "Hello",
    "tags" : [
      "Awesome API"
    ]
  }
}
```
