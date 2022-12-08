import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;
import 'package:recase/recase.dart';

import './templates/package_json_template.dart';

const String _svgInputDir = 'input';
const String _fontOutputDir = 'font-output';
const String _iconsClassName = 'name';
const String _defaultIconsClassName = 'CamusIcons';
const String _iconsOutputDir = 'class-output';
const String _deleteInput = 'delete-input';

const String _tempDir = 'temp';
const String _tempNodeDir = '$_tempDir/node';
const String _tempOutputDir = '$_tempDir/out';

class CamusCommand extends Command<void> {
  CamusCommand() {
    argParser.addOption(
      _svgInputDir,
      help: 'Input your svg file path',
    );
    argParser.addOption(
      _fontOutputDir,
      help: 'Output your fonts dir path',
    );
    argParser.addOption(
      _iconsOutputDir,
      help: 'Flutter icons output dir',
    );
    argParser.addOption(
      _iconsClassName,
      defaultsTo: _defaultIconsClassName,
      help: 'Flutter icons class Name',
    );
    argParser.addFlag(
      _deleteInput,
      defaultsTo: false,
      help: 'Is delete your input svg, if false, can preview svg ',
    );
  }

  @override
  String get description => 'generate your font files & Flutter Icons';

  @override
  String get name => 'generate';

  void _handleArguments() {
    if (argResults![_svgInputDir] == null) {
      stderr.writeln('\x1b[31m ❌ Error: Svg files path not found ❌');
      exit(1);
    }

    if (argResults![_fontOutputDir] == null) {
      stderr.writeln('\x1b[31m ❌ Error: Output your fonts dir not found ❌');
      exit(1);
    }

    if (argResults![_iconsOutputDir] == null) {
      stderr.writeln('\x1b[31m ❌ Error: Flutter icons output dir not found ❌');
      exit(1);
    }
  }

  Future<void> _judegeNodeEnvironment() async {
    final ProcessResult result = await Process.run(
      'node',
      <String>['--version'],
      runInShell: true,
    );

    if (result.exitCode != 0) {
      stderr.writeln(
        '❌ Error: Please install NodeJS. Recommended to install V10+, you can click https://nodejs.org/en/ intall it! ❌',
      );
      exit(1);
    }
  }

  /// root director
  Directory get rootDirector =>
      Directory.fromUri(Platform.script.resolve('..'));

  /// generate node package.json && excute npm install
  Future<void> _generatePackageJson() async {
    final String nodeDirPath = path.join(rootDirector.path, _tempNodeDir);
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
        Directory(path.join(rootDirector.path, _tempOutputDir));

    if (outputDir.existsSync()) {
      await outputDir.delete(recursive: true);
    }
    await outputDir.create(recursive: true);

    try {
      final Process result = await Process.start(
        path.join(
          rootDirector.path,
          _tempNodeDir,
          'node_modules/.bin/fantasticon',
        ),
        <String>[
          path.join(path.current, argResults![_svgInputDir]),
          '--name',
          argResults![_iconsClassName] ?? _defaultIconsClassName,
          '--output',
          path.join(rootDirector.path, _tempOutputDir),
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
        stderr.writeln(
          '\x1b[31m ❌ Error: generate iconfont is Failed! ❌',
        );
        exit(1);
      }
    } catch (e) {
      stderr.writeln(
        '\x1b[31m ❌ Error: generate iconfont is Failed! ❌',
      );
      exit(1);
    }
  }

  Future<void> _generateFlutterFile() async {
    final String className =
        argResults![_iconsClassName] ?? _defaultIconsClassName;
    final File iconfontsFile = File.fromUri(
      rootDirector.uri.resolve(
        path.join(
          rootDirector.path,
          _tempOutputDir,
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
          Method((MethodBuilder constructorBuilder) =>
              constructorBuilder..name = '$className._'),
        );
        for (final String key in icons.keys) {
          final String codePoint = '0x${icons[key].toRadixString(16)}';
          classBuilder.fields.add(
            Field(
              (FieldBuilder fieldBuild) {
                if (!argResults![_deleteInput]) {
                  final String itemSvgPath =
                      path.join(argResults![_svgInputDir], '$key.svg');
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
///  Camus Iconfont
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
      _tempOutputDir,
      '${className.snakeCase}.dart',
    );

    final File flutterIconFile = File(filePath);
    flutterIconFile.writeAsStringSync(result);
  }

  /// copy file & delete svg or delete node dir
  Future<void> _copyFile() async {
    final String className =
        argResults![_iconsClassName] ?? _defaultIconsClassName;
    final String iconClassFilePath = path.join(
      path.current,
      argResults![_iconsOutputDir],
      '${className.snakeCase}.dart',
    );

    final String tempFlutterClassPath = path.join(
      rootDirector.path,
      _tempOutputDir,
      '${className.snakeCase}.dart',
    );

    final String fontFile = path.join(
      path.current,
      argResults![_fontOutputDir],
      '${className.snakeCase}.ttf',
    );
    final String tempIconFontPath = path.join(
      rootDirector.path,
      _tempOutputDir,
      '$className.ttf',
    );

    await File(path.join(tempFlutterClassPath)).copy(iconClassFilePath);
    await File(path.join(tempIconFontPath)).copy(fontFile);

    final Directory tempDir = Directory(path.join(rootDirector.path, _tempDir));
    tempDir.delete(recursive: true);
    // if _deleteInput is false, delete input svg
    if (argResults![_deleteInput]) {
      final Directory soureFileDir =
          Directory(path.join(rootDirector.path, argResults![_svgInputDir]));
      if (soureFileDir.existsSync()) {
        await soureFileDir.delete();
      }
    }

    stdout.writeln('\x1b[34m ✅ 🎉🎉🎉 Wow！It is amazing！🎉🎉🎉');
  }

  @override
  Future<void> run() async {
    _handleArguments();
    await _judegeNodeEnvironment();
    await _generatePackageJson();
    await _generateIconfont();
    await _generateFlutterFile();
    await _copyFile();
  }
}
