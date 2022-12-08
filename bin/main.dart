import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:camus_iconfont/camus_iconfont.dart';

void main(List<String> arguments) {
  try {
    CommandRunner<dynamic>(
        'camus_iconfont', 'generate your font files & Flutter Icons')
      ..addCommand(CamusCommand())
      ..run(arguments);
  } catch (e) {
    print(e);
    exit(1);
  }
}
