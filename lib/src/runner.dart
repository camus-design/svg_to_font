import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:io/io.dart';

import './commands/camus_command.dart';
import './exception.dart';

/// Commander Runner for Camus Iconfont
class CamusCommandRunner extends CommandRunner<int> {
  /// constructor
  CamusCommandRunner()
      : super(
          'camus_iconfont',
          'generate your font files & Flutter Icons',
        ) {
    addCommand(CamusCommand());
  }

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      final ArgResults argResults = parse(args);
      final int exitCode =
          await runCommand(argResults) ?? ExitCode.success.code;
      return exitCode;
    } on CamusIconfontException catch (e) {
      stderr.writeln('\x1b[31m ❌ $e ❌');
      return ExitCode.usage.code;
    } on CamusIconfontUsageException catch (e) {
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
