@Timeout(Duration(minutes: 5))
import 'dart:io';

import 'package:io/io.dart';
import 'package:svg_to_font/svg_to_font.dart';
import 'package:test/test.dart';

const String testDirPath = './example/camus_test';
const String testFontDirPath = '$testDirPath/assets/font';
const String testClassDirPath = '$testDirPath/class';

void main() {
  group('Camus Icon font generate', () {
    final Directory testDir = Directory(testDirPath);
    final bool isExists = testDir.existsSync();
    tearDownAll(() async {
      if (isExists) {
        testDir.deleteSync(recursive: true);
      }
    });
    test('Generate icons', () async {
      final int exitCode = await SvgToFontCommandRunner().run(
        <String>[
          'generate',
          '--input',
          './example/assets',
          '--font-output',
          testFontDirPath,
          '--class-output',
          testClassDirPath,
        ],
      );
      expect(exitCode, ExitCode.success.code);
      expect(isExists, true);
    });
  });

  test('Do not pass input parameter', () async {
    final int exitCode = await SvgToFontCommandRunner().run(
      <String>[
        'generate',
        '--font-output',
        testFontDirPath,
        '--class-output',
        testClassDirPath,
      ],
    );
    expect(exitCode, ExitCode.usage.code);
  });
}
