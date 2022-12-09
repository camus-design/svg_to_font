import 'dart:io';

import 'package:camus_iconfont/camus_iconfont.dart';

void main(List<String> arguments) async {
  exit(await CamusCommandRunner().run(arguments));
}
