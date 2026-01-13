class ServerException implements Exception {
  final String message;
  final int statusCode;

  const ServerException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  final int statusCode;

  const CacheException({
    required this.message,
    required this.statusCode,
  });

  @override
  String toString() => 'CacheException: $message (Status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({
    required this.message,
  });

  @override
  String toString() => 'NetworkException: $message';
}
