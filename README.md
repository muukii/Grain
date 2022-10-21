# Grain

A data serialization template language in Swift

Describing data in Swift using DSL in `.swift` file then the command line application renders it into any format like JSON.

## Naming

serialization -> cereal -> grain

## Installation

From [mint 🌱](https://github.com/yonaskolb/Mint)

```
mint install muukii/Grain
```

## Overview

```sh
$ grain <File>
```

### Example - writing inline

Creates Data.swift describing data
```swift
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

```

Renders Data.swift as JSON in Terminal
```sh
$ grain Data.swift
{
  "key_0" : 0,
  "key_1" : 1,
  "key_2" : 2,
  "key_3" : 3,
  "key_4" : 4,
  "key_5" : 5,
  "key_6" : 6,
  "key_7" : 7,
  "key_8" : 8,
  "key_9" : 9,
  "value" : 1
}
```

### Example - creating component and composing them to describe data efficiently

In Component.swift
```swift
import GrainDescriptor

serialize {
  
  GrainObject {
    GrainMember("data") {
      Results(records: [
        .init(name: "A", age: 1),
        .init(name: "B", age: 2),
      ])
    }
  }
  
}

// MARK: - Components

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
```

```sh
$ grain Component.swift
{
  "data" : {
    "results" : [
      {
        "age" : 1,
        "name" : "A"
      },
      {
        "age" : 2,
        "name" : "B"
      }
    ]
  }
}
```

## Showcases

<details>
    <summary>OpenAPI Specification</summary>
 
```swift
import GrainDescriptor

serialize {
  Endpoint(methods: [
    .init(
      method: .get,
      summary: "Hello",
      description: "Hello Get Method",
      operationID: "id",
      tags: ["Awesome API"]
    )
  ])
}

// MARK: - Components

public struct Endpoint: GrainView {
  
  public var methods: [Method]
  
  public var body: some GrainView {
    GrainObject {
      for method in methods {
        GrainMember(method.method.rawValue) {
          method
        }
      }
    }
  }
}

public struct Method: GrainView {
  
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
  
  public var body: some GrainView {
    GrainObject {
      GrainMember("operationId") { operationID }
      GrainMember("description") { description }
      GrainMember("summary") { summary }
      GrainMember("tags") { tags }
    }
  }
}
```

```sh
$ grain endpoints.swift
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

</details>


