import 'dart:io';

import 'package:svg_to_font/svg_to_font.dart';

void main(List<String> arguments) async {
  exit(await SvgToFontCommandRunner().run(arguments));
}
