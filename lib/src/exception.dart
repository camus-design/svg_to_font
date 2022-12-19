/// Exception for internal Camus Iconfont usage
class SvgToFontUsageException implements Exception {
  /// Constructor of usage exception
  const SvgToFontUsageException([this.message = '']);

  /// Message of the exception
  final String message;

  @override
  String toString() => 'SVG to Font usage Exception: $message';
}

/// Exception for internal Camus Iconfont
class SvgToFontException implements Exception {
  /// Constructor of  exception
  const SvgToFontException([this.message = '']);

  /// Message of the exception
  final String message;

  @override
  String toString() => 'SVG to Font Exception: $message';
}
