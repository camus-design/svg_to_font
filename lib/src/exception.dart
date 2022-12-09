/// Exception for internal Camus Iconfont usage
class CamusIconfontUsageException implements Exception {
  /// Constructor of usage exception
  const CamusIconfontUsageException([this.message = '']);

  /// Message of the exception
  final String message;

  @override
  String toString() => 'CamusIconfont usage Exception: $message';
}

/// Exception for internal Camus Iconfont
class CamusIconfontException implements Exception {
  /// Constructor of  exception
  const CamusIconfontException([this.message = '']);

  /// Message of the exception
  final String message;

  @override
  String toString() => 'CamusIconfont Exception: $message';
}
