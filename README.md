# Camus Iconfont

## Table of Contents

- [Camus Iconfont](#camus-iconfont)
  - [Table of Contents](#table-of-contents)
  - [Background](#background)
  - [Requirements](#requirements)
  - [Get Started](#get-started)
    - [Install](#install)
    - [An Example](#an-example)
    - [Params](#params)
  - [License](#license)

## Background

To facilitate developers to quickly generate icon font (.ttf) and Flutter icon class, We developed the camus_iconfont library. Then you can use icons like the font.

## Requirements

Node.JS V10+ . [Install Node](https://nodejs.org/en/download/)

## Get Started

### Install

```shell
dart pub global activate camus_iconfont
```

### An Example

1. Put all of your icon SVG into some folder(example/assets);
2.

```shell
camus_iconfont generate  --input=./example/assets --font-output=./example/assets/fonts --class-output=./example/lib
```

Generated `camus_icons.dart` in `example/lib` and `camus_icons.ttf` in `example/assets`

3. Add some code to `pubspec.yaml`

```yaml
  fonts:
    - family: CamusIcons
      fonts:
        - asset: assets/fonts/camus_icons.ttf
```

### Params

|  parameter   | description | default |
|  :----:  | :----:  | :----:  |
 --help   | Print this usage information  | -- |
 --input  | Input your svg file path | -- |
 --font-output   | Output your fonts dir path | -- |
 --class-output    | Flutter icons Class output dir | -- |
 --name    | Flutter icons class Name | CamusIcons |
 --delete-input  | Is delete your input svg, if false, can preview svg | false  |

## License

[MIT](LICENSE) © Camus Design
