# SvgToFont

![GitHub stars](https://img.shields.io/github/stars/camus-design/svg_to_font?style=social)
[![Pub Version](https://img.shields.io/pub/v/svg_to_font?label=version&style=flat-square)](https://pub.dev/packages/svg_to_font/changelog)
![Pub Likes](https://img.shields.io/pub/likes/svg_to_font?label=Pub%20Likes&style=flat-squar)
![Pub Points](https://img.shields.io/pub/points/svg_to_font?label=Pub%20Points&style=flat-squar)
[![MIT Licence](https://img.shields.io/github/license/camus-design/svg_to_font?style=flat-square&longCache=true)](https://opensource.org/licenses/mit-license.php)

A tool for converting SVG files to font files.

## Table of Contents

- [SvgToFont](#svgtofont)
  - [Table of Contents](#table-of-contents)
  - [Background](#background)
  - [Requirements](#requirements)
  - [Get Started](#get-started)
    - [Install](#install)
    - [An Example](#an-example)
  - [Params](#params)
  - [License](#license)

## Background

To facilitate developers to quickly generate icon font (.ttf) and Flutter icon class, We developed the svg_to_font library.

Then you can use icons like the font.

## Requirements

Node.JS V10+ . [Install Node](https://nodejs.org/en/download/)

## Get Started

### Install

```shell
dart pub global activate svg_to_font
```

### An Example

1. Put all of your icon SVG into some folder(example/assets);
2. Generated `camus_icons.dart` in `example/lib` and `camus_icons.ttf` in `example/assets`

    ```shell
    svg_to_font generate  --input=./example/assets --font-output=./example/assets/fonts --class-output=./example/lib
    ```

3. Add some code to `pubspec.yaml`

  ```yaml
    fonts:
      - family: CamusIcons
        fonts:
          - asset: assets/fonts/camus_icons.ttf
  ```

## Params

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
