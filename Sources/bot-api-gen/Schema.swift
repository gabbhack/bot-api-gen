import AsyncHTTPClient
import Foundation

struct Schema: Decodable, Equatable {
  let version: Version
  let recent_changes: Date
  let methods: [Method]
  let objects: [Object]
}

struct Version: Decodable, Equatable {
  let major: UInt64
  let minor: UInt64
  let patch: UInt64
}

struct Date: Decodable, Equatable {
  let year: UInt32
  let month: UInt32
  let day: UInt32
}

enum Kind: Decodable, Equatable {
  case integer(IntegerKind)
  case string(StringKind)
  case bool(BoolKind)
  case float
  case anyOf(AnyOfKind)
  case reference(ReferenceKind)
  indirect case array(ArrayKind)

  enum CodingKeys: String, CodingKey { case type }

  enum KindCodingError: Error { case decode(String) }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decode(String.self, forKey: .type)
    switch type {
    case "integer": self = .integer(try IntegerKind(from: decoder))
    case "string": self = .string(try StringKind(from: decoder))
    case "bool": self = .bool(try BoolKind(from: decoder))
    case "float": self = .float
    case "any_of": self = .anyOf(try AnyOfKind(from: decoder))
    case "reference": self = .reference(try ReferenceKind(from: decoder))
    case "array": self = .array(try ArrayKind(from: decoder))
    default:
      throw KindCodingError.decode(
        "data did not match any variant of enum `Kind`: \(dump(container))")
    }

  }
}

struct IntegerKind: Decodable, Equatable {
  let default_value: Int64?
  let min: Int64?
  let max: Int64?

  enum CodingKeys: String, CodingKey {
    case default_value = "default"
    case min
    case max
  }

  init() {
    default_value = nil
    min = nil
    max = nil
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    default_value = try container.decodeIfPresent(Int64.self, forKey: .default_value)
    min = try container.decodeIfPresent(Int64.self, forKey: .min)
    max = try container.decodeIfPresent(Int64.self, forKey: .max)
  }
}

struct StringKind: Decodable, Equatable {
  let default_value: String?
  let min_len: UInt64?
  let max_len: UInt64?
  let enumeration: [String]?

  enum CodingKeys: String, CodingKey {
    case default_value = "default"
    case min_len
    case max_len
    case enumeration
  }

  init() {
    default_value = nil
    min_len = nil
    max_len = nil
    enumeration = nil
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    default_value = try container.decodeIfPresent(String.self, forKey: .default_value)
    min_len = try container.decodeIfPresent(UInt64.self, forKey: .min_len)
    max_len = try container.decodeIfPresent(UInt64.self, forKey: .max_len)
    enumeration = try container.decodeIfPresent([String].self, forKey: .enumeration)
  }
}

struct BoolKind: Decodable, Equatable {
  let default_value: Bool?

  enum CodingKeys: String, CodingKey { case default_value = "default" }

  init(default_value: Bool) { self.default_value = default_value }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    default_value = try container.decodeIfPresent(Bool.self, forKey: .default_value)
  }
}

struct AnyOfKind: Decodable, Equatable { let any_of: [Kind] }

struct ReferenceKind: Decodable, Equatable { let reference: String }

struct ArrayKind: Decodable, Equatable { let array: Kind }

struct Method: Decodable, Equatable {
  let name: String
  let description: String
  var arguments: [Argument]?
  let multipart_only: Bool
  var return_type: Kind
  let documentation_link: String
}

struct Argument: Decodable, Equatable {
  let name: String
  let description: String
  let required: Bool
  var kind: Kind

  enum CodingKeys: String, CodingKey {
    case name
    case description
    case required
    case kind
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    description = try container.decode(String.self, forKey: .description)
    required = try container.decode(Bool.self, forKey: .required)
    kind = try Kind(from: decoder)
  }
}

struct Object: Decodable, Equatable {
  let name: String
  let description: String
  var data: ObjectData
  let documentation_link: String

  enum CodingKeys: String, CodingKey {
    case name
    case description
    case data
    case documentation_link
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    description = try container.decode(String.self, forKey: .description)
    data = try ObjectData(from: decoder)
    documentation_link = try container.decode(String.self, forKey: .documentation_link)
  }
}

enum ObjectData: Decodable, Equatable {
  case properties(PropertiesKind)
  case anyOf(AnyOfKind)
  case unknown

  enum CodingKeys: String, CodingKey { case type }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let type = try container.decodeIfPresent(String.self, forKey: .type)
    switch type {
    case "properties": self = .properties(try PropertiesKind(from: decoder))
    case "any_of": self = .anyOf(try AnyOfKind(from: decoder))
    default: self = .unknown
    }
  }
}

struct PropertiesKind: Decodable, Equatable { let properties: [Property] }

struct Property: Decodable, Equatable {
  let name: String
  let description: String
  let required: Bool
  var kind: Kind

  enum CodingKeys: String, CodingKey {
    case name
    case description
    case required
    case kind
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    name = try container.decode(String.self, forKey: .name)
    description = try container.decode(String.self, forKey: .description)
    required = try container.decode(Bool.self, forKey: .required)
    kind = try Kind(from: decoder)
  }
}

func getSchema(source: String) throws -> Schema {
  let httpClient = HTTPClient(eventLoopGroupProvider: .createNew)
  defer { try? httpClient.syncShutdown() }
  print("Getting the schema...")
  let response = try httpClient.get(url: source).wait()
  let body = response.body!
  let string = String(buffer: body)
  return try JSONDecoder().decode(Schema.self, from: string.data(using: .utf8)!)
}
