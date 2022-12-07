# camus_iconfont

## Table of Contents

- [camus\_iconfont](#camus_iconfont)
  - [Table of Contents](#table-of-contents)
  - [Background](#background)
  - [Requirements](#requirements)
  - [Get Started](#get-started)
    - [Install](#install)
    - [Usage/Run](#usagerun)
  - [Example](#example)
  - [License](#license)

---

## Background

In order to facilitate developers to quickly generate iconfont fonts((.ttf)) and Flutter iconClass, we have developed the camus_iconfont library.

---

## Requirements

Node.JS V10+

---

## Get Started

### Install

Works in you projects

```shell
dart pub add camus_iconfont --dev
```

Pub Global

```shell
dart pub global activate camus_iconfont
```

### Usage/Run

---

## Example

Run command

```shell
dart pub global run camus_iconfont camus_iconfont   --input=./example/assets --font-output=./example/assets --icons-output=./example/lib
```

Generate camus_icons.dart

```dart
/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  Camus Iconfont
/// *****************************************************

import 'package:flutter/material.dart';

const String fontFamily = 'CamusIcons';

class CamusIcons {
  /// File path: ./example/assets/test.svg
  static const IconData test = IconData(0xf101, fontFamily: fontFamily);

  CamusIcons._();
}
```

You should also add some code to pubspec.yaml

```yaml
  fonts:
    - family: CamusIcons
      fonts:
        - asset: assets/fonts/camus_icons.ttf
```

## License

[MIT](LICENSE) © Camus Design
