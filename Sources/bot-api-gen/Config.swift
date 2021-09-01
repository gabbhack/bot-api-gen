struct Config {
  let source: String
  let templatesPath: String
  let typeTemplate: String
  let typeSaveTo: String
  let methodTemplate: String
  let methodSaveTo: String
}

let CONFIG = Config(
  source: "https://ark0f.github.io/tg-bot-api/custom.min.json", templatesPath: "templates",
  typeTemplate: "Type.swift", typeSaveTo: "generated/types", methodTemplate: "Method.swift",
  methodSaveTo: "generated/methods")

let SKIPPED_OBJECTS: [String] = [
  "Update", "Message", "Chat", "ChatMember", "InlineQueryResult", "InputFile",
  "KeyboardButtonPollType",

]

let SKIPPED_METHODS: [String] = [

  ]
