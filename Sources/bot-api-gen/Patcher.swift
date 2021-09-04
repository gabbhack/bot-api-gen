// Skip hardcoded types
var skipped_objects = SKIPPED_OBJECTS
// Hardcoded arguments
let CHAT_ID_ARGUMENTS = ["chat_id", "from_chat_id"]
// Hardcoded until_date
let UNTIL_DATE_STUFF = [
  "ChatMemberRestricted", "ChatMemberBanned", "banChatMember", "restrictChatMember",
]

func is_skipped(_ object: Object) -> Bool {
  // Skip all enum objects since we write them by hand
  if case let .anyOf(anyOf) = object.data {
    for case let .reference(this) in anyOf.any_of { skipped_objects.append(this.reference) }
    return true
  }
  // Skip other hardcoded types
  return skipped_objects.contains(object.name)
}

enum PatchError: Error {
  case invalidCase(String)
  case invalidProperty(String)
}

// Patch schema types

func patch(_ argument: Argument, _ method: Method) -> Argument? {
  var argument = argument
  switch argument.kind {
  // Hardcoded type for `InputFile or String`
  case .anyOf(
    AnyOfKind(any_of: [.reference(ReferenceKind(reference: "InputFile")), .string(StringKind())])):
    argument.kind = .reference(ReferenceKind(reference: "InputFile"))
  // Hardcoded type for `Integer or String`
  case .anyOf(AnyOfKind(any_of: [.integer(IntegerKind()), .string(StringKind())]))
  where CHAT_ID_ARGUMENTS.contains(argument.name):
    argument.kind = .reference(ReferenceKind(reference: "ChatId"))
  // Hardcoded type for reply_markup
  case .anyOf(
    AnyOfKind(any_of: [
      .reference(ReferenceKind(reference: "InlineKeyboardMarkup")),
      .reference(ReferenceKind(reference: "ReplyKeyboardMarkup")),
      .reference(ReferenceKind(reference: "ReplyKeyboardRemove")),
      .reference(ReferenceKind(reference: "ForceReply")),
    ])):
    argument.kind = .reference(ReferenceKind(reference: "ReplyMarkup"))
  // Hardcoded type for `sendMediaGroup`
  case .array(
    ArrayKind(
      array: .anyOf(
        AnyOfKind(any_of: [
          .reference(ReferenceKind(reference: "InputMediaAudio")),
          .reference(ReferenceKind(reference: "InputMediaDocument")),
          .reference(ReferenceKind(reference: "InputMediaPhoto")),
          .reference(ReferenceKind(reference: "InputMediaVideo")),
        ])))) where method.name == "sendMediaGroup":
    argument.kind = .reference(ReferenceKind(reference: "MediaGroup"))
  // Hardcoded type for `emoji` argument in `sendDice`
  case .string where argument.name == "emoji" && method.name == "sendDice":
    argument.kind = .reference(ReferenceKind(reference: "DiceEmoji"))
  // Hardcoded type for `until_date`
  case .integer where argument.name == "until_date" && UNTIL_DATE_STUFF.contains(method.name):
    argument.kind = .reference(ReferenceKind(reference: "UntilDate"))
  // Hardcoded type for timestamp
  case .integer where argument.description.contains("unix time") || argument.description.contains("Unix time"):
    argument.kind = .reference(ReferenceKind(reference: "Date"))
  default: break
  }
  return argument
}

func patch(_ method: Method) -> Method? {
  var method = method
  method.arguments = method.arguments?.compactMap { argument in patch(argument, method) }
  switch method.return_type {
  // Hardcoded type for methods that always return True
  case .bool(let boolKind) where boolKind.default_value == true:
    method.return_type = .reference(ReferenceKind(reference: "True"))
  // Hardcoded type for `... Message is returned, otherwise True is returned`
  case .anyOf(
    AnyOfKind(any_of: [
      .reference(ReferenceKind(reference: "Message")), .bool(BoolKind(default_value: true)),
    ])):
    method.return_type = .reference(ReferenceKind(reference: "MessageOrTrue"))
  default: break
  }
  return method
}

func patch(_ property: Property, _ object: Object) -> Property? {
  var property = property
  switch property.kind {
  // Hardcoded type for `InputFile or String`
  case .anyOf(
    AnyOfKind(any_of: [.reference(ReferenceKind(reference: "InputFile")), .string(StringKind())])):
    property.kind = .reference(ReferenceKind(reference: "InputFile"))
  // Hardcoded type for `Integer or String`
  case .anyOf(AnyOfKind(any_of: [.integer(IntegerKind()), .string(StringKind())]))
  where CHAT_ID_ARGUMENTS.contains(property.name):
    property.kind = .reference(ReferenceKind(reference: "ChatId"))
  // Hardcoded type for `emoji` property in `Dice`
  case .string where property.name == "emoji" && object.name == "Dice":
    property.kind = .reference(ReferenceKind(reference: "DiceEmoji"))
  // Hardcoded type for `until_date`
  case .integer where property.name == "until_date" && UNTIL_DATE_STUFF.contains(object.name):
    property.kind = .reference(ReferenceKind(reference: "UntilDate"))
  // Hardcoded type for timestamp
  case .integer where property.description.contains("unix time") || property.description.contains("Unix time"):
    property.kind = .reference(ReferenceKind(reference: "Date"))
  default: break
  }
  return property
}

func patch(_ object: Object) -> Object? {
  if is_skipped(object) {
    print("Skipped: \(object.name)")
    return nil
  } else {
    var object = object
    if case .properties(let propertiesKind) = object.data {
      let patched = propertiesKind.properties.compactMap { property in patch(property, object) }
      object.data = .properties(PropertiesKind(properties: patched))
    }
    return object
  }
}

// Patch render types
func patch(_ argument: ArgumentRender, _ method: inout MethodRender) -> ArgumentRender? {
  return argument
}

func patch(_ method: MethodRender) -> MethodRender? {
  return method
}

func patch(_ property: PropertyRender, _ type: inout TypeRender) -> PropertyRender? {
  return property
}

func patch(_ type: TypeRender) -> TypeRender? {
  return type
}
