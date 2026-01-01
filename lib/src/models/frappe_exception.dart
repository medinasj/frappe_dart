/// Exception thrown when a Frappe API request fails.
///
/// This provides detailed information about API failures including
/// status code and additional error data from the server.
class FrappeException implements Exception {
  /// Creates a new [FrappeException].
  const FrappeException({
    required this.message,
    this.statusCode,
    this.data,
  });

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
