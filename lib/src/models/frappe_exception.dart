/// Base exception thrown when a Frappe API request fails.
///
/// This provides detailed information about API failures including
/// status code and additional error data from the server.
///
/// Use the factory constructor to automatically create the appropriate
/// exception subtype based on the status code.
abstract class FrappeException implements Exception {
  /// Creates a new [FrappeException].
  const FrappeException({
    required this.message,
    this.statusCode,
    this.data,
  });

  /// Factory constructor that creates the appropriate exception subtype
  /// based on the status code.
  factory FrappeException.fromStatusCode({
    required String message,
    int? statusCode,
    Map<String, dynamic>? data,
  }) {
    if (statusCode == null) {
      return FrappeHttpException(message: message, statusCode: 0, data: data);
    }

    switch (statusCode) {
      case 401:
        return FrappeUnauthorizedException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case 403:
        return FrappeForbiddenException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case 404:
        return FrappeNotFoundException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      case >= 500:
        return FrappeServerException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
      default:
        return FrappeHttpException(
          message: message,
          statusCode: statusCode,
          data: data,
        );
    }
  }

  /// The error message.
  final String message;

  /// The HTTP status code, if available.
  final int? statusCode;

  /// Additional error data from the server.
  final Map<String, dynamic>? data;

  @override
  String toString() {
    final buffer = StringBuffer('FrappeException: $message');
    if (statusCode != null) {
      buffer.write(' (Status: $statusCode)');
    }
    if (data != null) {
      buffer.write('\nData: $data');
    }
    return buffer.toString();
  }
}

/// Exception thrown when a resource is not found (404).
class FrappeNotFoundException extends FrappeException {
  /// Creates a new [FrappeNotFoundException].
  const FrappeNotFoundException({
    required super.message,
    super.statusCode = 404,
    super.data,
  });

  @override
  String toString() => 'FrappeNotFoundException: $message (Status: 404)';
}

/// Exception thrown when request is unauthorized (401).
class FrappeUnauthorizedException extends FrappeException {
  /// Creates a new [FrappeUnauthorizedException].
  const FrappeUnauthorizedException({
    required super.message,
    super.statusCode = 401,
    super.data,
  });

  @override
  String toString() => 'FrappeUnauthorizedException: $message (Status: 401)';
}

/// Exception thrown when access is forbidden (403).
class FrappeForbiddenException extends FrappeException {
  /// Creates a new [FrappeForbiddenException].
  const FrappeForbiddenException({
    required super.message,
    super.statusCode = 403,
    super.data,
  });

  @override
  String toString() => 'FrappeForbiddenException: $message (Status: 403)';
}

/// Exception thrown for server errors (500+).
class FrappeServerException extends FrappeException {
  /// Creates a new [FrappeServerException].
  const FrappeServerException({
    required super.message,
    super.statusCode = 500,
    super.data,
  });

  @override
  String toString() => 
      'FrappeServerException: $message (Status: ${statusCode ?? 500})';
}

/// Generic exception for other HTTP errors.
class FrappeHttpException extends FrappeException {
  /// Creates a new [FrappeHttpException].
  const FrappeHttpException({
    required super.message,
    required super.statusCode,
    super.data,
  });
}
