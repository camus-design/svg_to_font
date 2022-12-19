import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import '../constants.dart';
import '../exception.dart';
import '../templates/package_json_template.dart';

/// Generate icon font (.ttf) and Flutter icon class
class SvgToFontCommand extends Command<int> {
  /// constructor
  SvgToFontCommand() {
    argParser.addOption(
      svgInputDir,
      help: 'Input your svg file path',
    );
    argParser.addOption(
      fontOutputDir,
      help: 'Output your fonts dir path',
    );
    argParser.addOption(
      iconsOutputDir,
      help: 'Flutter icons output dir',
    );
    argParser.addOption(
      iconsClassName,
      defaultsTo: defaultIconsClassName,
      help: 'Flutter icons class Name',
    );
    argParser.addFlag(
      deleteInput,
      defaultsTo: false,
      help: 'Is delete your input svg, if false, can preview svg',
    );
  }

  @override
  String get description => 'generate your font files & Flutter Icons';

  @override
  String get name => 'generate';

  void _handleArguments() {
    if (argResults![svgInputDir] == null) {
      throw const SvgToFontUsageException(
        'Svg files path not found',
      );
    }

    if (argResults![fontOutputDir] == null) {
      throw const SvgToFontUsageException(
        'Output your fonts dir not found',
      );
    }

    if (argResults![iconsOutputDir] == null) {
      throw const SvgToFontUsageException(
        'Flutter icons output dir not found',
      );
    }
  }

  Future<void> _judgeNodeEnvironment() async {
    final ProcessResult result = await Process.run(
      'node',
      <String>['--version'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      throw const SvgToFontException(
        'Please install NodeJS. Recommended to install V10+, you can click https://nodejs.org/en/ intall it!',
      );
    }
  }

  /// root director
  Directory get rootDirector =>
      Directory.fromUri(Platform.script.resolve('..'));

  /// generate node package.json && execute npm install
  Future<void> _generatePackageJson() async {
    final String nodeDirPath = path.join(rootDirector.path, tempNodeDir);
    final Directory dir = Directory(nodeDirPath);
    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }
    final File packageJsonFile = File(path.join(nodeDirPath, 'package.json'));
    if (!packageJsonFile.existsSync()) {
      await packageJsonFile.writeAsString(packageJsonTemplate);
    }

    stdout.writeln('\x1b[32m Installing npm dependencies ...');

    final Process npmInstallResult = await Process.start(
      'npm',
      <String>['install'],
      workingDirectory: dir.path,
      runInShell: true,
    );
    await stdout.addStream(npmInstallResult.stdout);
  }

  Future<void> _generateIconfont() async {
    final Directory outputDir =
        Directory(path.join(rootDirector.path, tempOutputDir));

    if (outputDir.existsSync()) {
      await outputDir.delete(recursive: true);
    }
    await outputDir.create(recursive: true);

    try {
      final Process result = await Process.start(
        path.join(
          rootDirector.path,
          tempNodeDir,
          'node_modules/.bin/fantasticon',
        ),
        <String>[
          path.join(path.current, argResults![svgInputDir]),
          '--name',
          argResults![iconsClassName] ?? defaultIconsClassName,
          '--output',
          path.join(rootDirector.path, tempOutputDir),
          '--asset-types',
          'json',
          '--font-types',
          'ttf',
        ],
        runInShell: true,
      );

      final int code = await result.exitCode;
      if (code != 0) {
        await stdout.addStream(
          result.stdout.map((List<int> bytes) {
            final String message = utf8.decode(bytes);
            return utf8.encode(message);
          }),
        );

        throw const SvgToFontException(
          'generate iconfont is Failed!',
        );
      }
    } catch (e) {
      throw const SvgToFontException(
        'generate iconfont is Failed!',
      );
    }
  }

  Future<void> _generateFlutterFile() async {
    final String className =
        argResults![iconsClassName] ?? defaultIconsClassName;
    final File iconfontsFile = File.fromUri(
      rootDirector.uri.resolve(
        path.join(
          rootDirector.path,
          tempOutputDir,
          '$className.json',
        ),
      ),
    );
    final Map<String, dynamic> icons = jsonDecode(
      await iconfontsFile.readAsString(),
    );
    final Class bbIcons = Class(
      (ClassBuilder builder) {
        final ClassBuilder classBuilder = builder;
        classBuilder.name = className;
        classBuilder.methods.add(
          Method(
            (MethodBuilder constructorBuilder) =>
                constructorBuilder..name = '$className._',
          ),
        );
        for (final String key in icons.keys) {
          final String codePoint = '0x${icons[key].toRadixString(16)}';
          classBuilder.fields.add(
            Field(
              (FieldBuilder fieldBuild) {
                if (!argResults![deleteInput]) {
                  final String itemSvgPath =
                      path.join(argResults![svgInputDir], '$key.svg');
                  fieldBuild.docs.add(
                    '/// File path: ${itemSvgPath.replaceAll(r'\', r'/')}',
                  );
                }
                fieldBuild.name = key;
                fieldBuild.type = refer('IconData');
                fieldBuild.modifier = FieldModifier.final$;
                fieldBuild.assignment =
                    Code('IconData($codePoint, fontFamily: fontFamily)');
                fieldBuild.static = true;
                fieldBuild.modifier = FieldModifier.constant;
              },
            ),
          );
        }
      },
    );

    const String ignore = '''
// ignore_for_file: sort_constructors_first, public_member_api_docs
''';

    final DartEmitter emitter = DartEmitter();
    const String header = '''/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  SvgToFont
/// *****************************************************

''';

    final String import = """
import 'package:flutter/material.dart';

const String fontFamily = '$className';

    """;
    final String emitterResult =
        DartFormatter().format('${bbIcons.accept(emitter)}');
    final DartFormatter formatter = DartFormatter();
    final String result =
        formatter.format(ignore + header + import + emitterResult);

    final String filePath = path.join(
      rootDirector.path,
      tempOutputDir,
      '${className.snakeCase}.dart',
    );

    final File flutterIconFile = File(filePath);
    flutterIconFile.writeAsStringSync(result);
  }

  /// copy file & delete svg or delete node dir
  Future<void> _copyFile() async {
    final String className =
        argResults![iconsClassName] ?? defaultIconsClassName;

    /// Create if the iconsClassName folder does not exist
    final Directory classFileDir = Directory(
      path.join(
        path.current,
        argResults![iconsOutputDir],
      ),
    );
    if (!classFileDir.existsSync()) {
      await classFileDir.create(recursive: true);
    }

    final String iconClassFilePath = path.join(
      path.current,
      argResults![iconsOutputDir],
      '${className.snakeCase}.dart',
    );

    final String tempFlutterClassPath = path.join(
      rootDirector.path,
      tempOutputDir,
      '${className.snakeCase}.dart',
    );

    /// Create if the fontOutputDir folder does not exist
    final Directory fontFileDir = Directory(
      path.join(
        path.current,
        argResults![fontOutputDir],
      ),
    );
    if (!fontFileDir.existsSync()) {
      await fontFileDir.create(recursive: true);
    }

    final String fontFile = path.join(
      path.current,
      argResults![fontOutputDir],
      '${className.snakeCase}.ttf',
    );
    final String tempIconFontPath = path.join(
      rootDirector.path,
      tempOutputDir,
      '$className.ttf',
    );

    await File(path.join(tempFlutterClassPath)).copy(iconClassFilePath);
    await File(path.join(tempIconFontPath)).copy(fontFile);

    final Directory dir = Directory(path.join(rootDirector.path, tempDir));
    dir.delete(recursive: true);
    // if deleteInput is false, delete input svg
    if (argResults![deleteInput]) {
      final Directory soureFileDir =
          Directory(path.join(rootDirector.path, argResults![svgInputDir]));
      if (soureFileDir.existsSync()) {
        await soureFileDir.delete();
      }
    }

    stdout.writeln('\x1b[34m ✅ 🎉🎉🎉 Wow！It is amazing！🎉🎉🎉');
  }

  @override
  Future<int> run() async {
    _handleArguments();
    await _judgeNodeEnvironment();
    await _generatePackageJson();
    await _generateIconfont();
    await _generateFlutterFile();
    await _copyFile();
    return ExitCode.success.code;
  }
}
