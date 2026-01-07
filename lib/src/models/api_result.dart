import 'package:frappe_dart/src/models/frappe_exception.dart';

/// Result wrapper for API operations.
///
/// This provides a clean way to handle API responses with either data or error.
/// Use [isSuccess] to check if the operation was successful and [isError]
/// to check if it failed.
///
/// Example:
/// ```dart
/// final result = await client.getResource('DocType', 'name');
/// if (result.isSuccess) {
///   print(result.data);
/// } else {
///   print(result.error!.message);
/// }
/// ```
class ApiResult<T> {
  const ApiResult._({
    this.data,
    this.error,
  });

  /// Creates a successful result.
  factory ApiResult.success(T data) {
    return ApiResult._(data: data);
  }

  /// Creates an error result.
  factory ApiResult.failure(FrappeException error) {
    return ApiResult._(error: error);
  }

  /// The data returned from the API, if successful.
  final T? data;

  /// The error that occurred, if any.
  final FrappeException? error;

  /// Whether the operation was successful.
  bool get isSuccess => error == null;

  /// Whether the operation failed.
  bool get isError => error != null;

  /// Maps the data to a new type.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.getResource('User', 'user@example.com');
  /// final mappedResult = result.map((data) {
  ///   return User.fromJson(data['data']);
  /// });
  /// ```
  ApiResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      try {
        return ApiResult.success(mapper(data!));
      } catch (e) {
        return ApiResult.failure(
          FrappeException.fromStatusCode(message: 'Mapping error: $e'),
        );
      }
    }
    return ApiResult.failure(error!);
  }
}
