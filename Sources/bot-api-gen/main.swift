let schema = try getSchema(source: CONFIG.source)

let renderer = Renderer(source: schema, settings: CONFIG)

try schema.objects.compactMap { object in patch(object) }.map { object in
  try TypeRender(from: object)
}.forEach { type in renderer.render(type) }

try schema.methods.compactMap { method in patch(method) }.map { method in
  try MethodRender(from: method)
}.forEach { method in renderer.render(method) }

renderer.format()
