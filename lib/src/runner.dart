import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:io/io.dart';

import './commands/svg_to_font_command.dart';
import './exception.dart';

/// Commander Runner for Camus Iconfont
class SvgToFontCommandRunner extends CommandRunner<int> {
  /// constructor
  SvgToFontCommandRunner()
      : super(
          'svg_to_font',
          'generate your font files & Flutter Icons',
        ) {
    addCommand(SvgToFontCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final ArgResults argResults = parse(args);
      final int exitCode =
          await runCommand(argResults) ?? ExitCode.success.code;
      return exitCode;
    } on SvgToFontException catch (e) {
      stderr.writeln('\x1b[31m ❌ $e ❌');
      return ExitCode.usage.code;
    } on SvgToFontUsageException catch (e) {
      stderr.writeln('\x1b[31m ❌ $e ❌');
      return ExitCode.usage.code;
    } on UsageException catch (e) {
      stderr.writeln('\x1b[31m ❌ $e ❌');
      return ExitCode.usage.code;
    } on Exception catch (e) {
      stderr.writeln('\x1b[31m ❌ $e ❌');
      return ExitCode.usage.code;
    }
  }
}
