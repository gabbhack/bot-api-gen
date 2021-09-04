# bot-api-gen

Types and methods generator for `tbot`.

## Getting started

### Requirements

- Swift 5.4.0
- swift-format

### Installation

1. Clone the repo
`git clone https://github.com/tgswift/bot-api-gen`
1. Go to the directory
`cd bot-api-gen`
1. Run generator
`swift run`
1. Get types and methods from `generated` directory

### Configuration

#### Rendering
By default generator use this settings:
```swift
let CONFIG = Config(
    source: "https://ark0f.github.io/tg-bot-api/custom.min.json",
    templatesPath: "templates",
    typeTemplate: "Type.swift",
    typeSaveTo: "generated/types",
    methodTemplate: "Method.swift",
    methodSaveTo: "generated/methods"
)
```
You can change them in the `Config.swift` file.

#### Formatting
After generation, the generator automatically formats the generated files using [swift-format](https://github.com/apple/swift-format). Its settings are located in the `.swift-format` file

#### Skip objects
The generator is quite simple, so it skips complex sum-types (e.g. [BotCommandScope](https://core.telegram.org/bots/api#botcommandscope)). 

In addition, it skips the other types and methods specified in `Config.swift`. These are usually types or methods that are already written manually in `tbot`.

Generator prints the skipped types and methods.

## Contributing
1. Fork
1. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
1. Code
1. Format `swift-format -m format -r -i --configuration .swift-format Sources`
1. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
1. Push to the Branch (`git push origin feature/AmazingFeature`)
1. Open a Pull Request

## License
Distributed under the MIT License. See LICENSE for more information.

## Acknowledgements
- [tg-bot-api](https://github.com/ark0f/tg-bot-api)
- [Stencil](https://github.com/stencilproject/Stencil)
- [swift-commands](https://github.com/qiuzhifei/swift-commands)
