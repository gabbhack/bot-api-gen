import Commands
import Foundation
import PathKit
import Stencil

struct Renderer {
  let schema: Schema
  let config: Config
  let env: Environment

  init(source: Schema, settings: Config) {
    schema = source
    config = settings
    env = Environment(
      loader: FileSystemLoader(paths: [Path("\(config.templatesPath)/")]), trimBehavior: .smart)
    let fm = FileManager()
    print("Creating \(config.typeSaveTo) directory")
    try! fm.createDirectory(atPath: "\(config.typeSaveTo)/", withIntermediateDirectories: true)
    print("Creating \(config.methodSaveTo) directory")
    try! fm.createDirectory(atPath: "\(config.methodSaveTo)/", withIntermediateDirectories: true)
  }

  func render(_ type: TypeRender) {
    let fileUrl = URL(fileURLWithPath: "\(config.typeSaveTo)/\(type.name).swift")
    //print("Rendering \(type.name) type...")
    let rendered = try! env.renderTemplate(
      name: config.typeTemplate, context: ["type": type, "schema": schema])
    //print("Saving \(type.name) to \(fileUrl)")
    try! rendered.data(using: .utf8)?.write(to: fileUrl)
  }

  func render(_ method: MethodRender) {
    let fileUrl = URL(fileURLWithPath: "\(config.methodSaveTo)/\(method.name).swift")
    //print("Rendering \(method.name) type...")
    let rendered = try! env.renderTemplate(
      name: config.methodTemplate, context: ["method": method, "schema": schema])
    //print("Saving \(method.name) to \(fileUrl)")
    try! rendered.data(using: .utf8)?.write(to: fileUrl)
  }

  func format() {
    print("Formatting types...")
    let _ = Commands.Bash.run(
      "swift-format -m format -r -i --configuration .swift-format \(config.typeSaveTo)")
    print("Formatting methods...")
    let _ = Commands.Bash.run(
      "swift-format -m format -r -i --configuration .swift-format \(config.methodSaveTo)")
  }
}

struct VariantRender {
  var name: String
  var type: String
}

struct PropertyRender {
  var name: String
  var type: String
  var description: [String]
}

struct TypeRender {
  var name: String
  var description: [String]
  var isEnum: Bool
  var properties: [PropertyRender]
  var variants: [VariantRender]
  var documentation_link: String
}

struct ArgumentRender {
  var name: String
  var description: [String]
  var type: String
  var func_type: String
}

struct MethodRender {
  var name: String
  var func_name: String
  var description: [String]
  var arguments: [ArgumentRender]
  var return_type: String
  var documentation_link: String
}
