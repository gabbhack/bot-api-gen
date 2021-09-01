import Foundation

extension String {
  func normalize() -> [String] {
    self.replacingOccurrences(of: "*Optional*. ", with: "").replacingOccurrences(
      of: "True", with: "`true`"
    ).components(separatedBy: CharacterSet.newlines)
  }

  func capitalizingFirstLetter() -> String { return prefix(1).capitalized + dropFirst() }

  mutating func capitalizeFirstLetter() { self = capitalizingFirstLetter() }
}

enum TransformationError: Error { case anyOf(AnyOfKind) }

extension VariantRender {
  init(from kind: Kind) throws {
    switch kind {
    case .integer(_):
      type = "Int64"
      name = "integer"
    case .string(_):
      type = "String"
      name = "string"
    case .bool(_):
      type = "Bool"
      name = "bool"
    case .float:
      type = "Float64"
      name = "float"
    case .reference(let ref):
      type = ref.reference
      // Message -> message
      name = ref.reference.first!.lowercased() + ref.reference.dropFirst()
    case .array(let kind):
      // Recuresive type transformation for `Array of ...` cases
      let variant = try VariantRender(from: kind.array)
      type = "[\(variant.type)]"
      name = "array"
    // In this context, it is not clear what to do with Union types,
    // so we throw the above
    case .anyOf(let anyOfKind): throw TransformationError.anyOf(anyOfKind)
    }
  }
}

extension PropertyRender {
  init(from property: Property) throws {
    type = try VariantRender(from: property.kind).type
    if !property.required { type.append("?") }
    name = property.name
    description = property.description.normalize()
  }
}

extension TypeRender {
  init(from object: Object) throws {
    switch object.data {
    case .properties(let rawProperties):
      name = object.name
      description = object.description.normalize()
      isEnum = false
      properties = try rawProperties.properties.map { property in try PropertyRender(from: property)
      }
      variants = []
    case .anyOf(let rawAnyOf):
      name = object.name
      description = object.description.normalize()
      isEnum = true
      properties = []
      variants = try rawAnyOf.any_of.map { kind in try VariantRender(from: kind) }
    case .unknown:
      name = object.name
      description = object.description.normalize()
      isEnum = false
      properties = []
      variants = []
    }
    documentation_link = object.documentation_link
  }
}

extension ArgumentRender {
  init(from argument: Argument) throws {
    name = argument.name
    description = argument.description.normalize()
    type = try VariantRender(from: argument.kind).type
    func_type = type
    if !argument.required {
      type.append("?")
      func_type.append("? = nil")
    }
  }
}

extension MethodRender {
  init(from method: Method) throws {
    name = method.name.capitalizingFirstLetter()
    func_name = method.name
    description = method.description.normalize()
    arguments = try method.arguments?.map { argument in try ArgumentRender(from: argument) } ?? []
    return_type = try VariantRender(from: method.return_type).type
    documentation_link = method.documentation_link
  }
}
