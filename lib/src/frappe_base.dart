import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frappe_dart/frappe_dart.dart';
import 'package:frappe_dart/src/frappe_api.dart';
import 'package:frappe_dart/src/models/report_view_request.dart';
import 'package:frappe_dart/src/models/report_view_response.dart';
import 'package:frappe_dart/src/models/error_response.dart';
import 'package:frappe_dart/src/models/savedocs_response/savedocs_response.dart';
import 'package:frappe_dart/src/models/send_email_response.dart';

/// Base class for Frappe API implementations across different versions.
///
/// This class contains shared functionality that is common across
/// Frappe versions (v14, v15, etc.). Version-specific implementations
/// should extend this class and override methods as needed.
abstract class FrappeBase implements FrappeApi {
  /// Creates a new instance of [FrappeBase].
  FrappeBase({
    required String baseUrl,
    Dio? dio,
    String? cookie,
  })  : _baseUrl = baseUrl,
        _cookie = cookie,
        _dio = dio ?? Dio();

  String _baseUrl;
  String? _cookie;
  final Dio _dio;

  /// The base URL of the Frappe instance.
  String get baseUrl => _baseUrl;

  /// The cookie used for authentication.
  String? get cookie => _cookie;

  set baseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
  }

  set cookie(String? newCookie) {
    _cookie = newCookie;
  }

  /// Getter for the Dio instance.
  Dio get dio => _dio;

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    final url = '$_baseUrl/api/method/login';
    try {
      // Sending the POST request
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: loginRequest.toMap(),
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Checking the response status
      if (response.statusCode == HttpStatus.ok) {
        final responseBody = response.data!;

        final Map<String, dynamic> headers = response.headers.map;
        if (headers['set-cookie'] != null &&
            headers['set-cookie']![3] != null) {
          responseBody['user_id'] =
              headers['set-cookie']![3].split(';')[0].split('=')[1];
          responseBody['cookie'] = headers['set-cookie']![0];
        }

        // Returning the parsed response
        return LoginResponse.fromJson(responseBody);
      } else {
        throw Exception(
          '''Failed to login. Response Status: ${response.statusCode}, Body: ${response.data}''',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An unknown error occurred during login: $e');
    }
  }

  @override
  Future<LogoutResponse> logout() async {
    final url = '$_baseUrl/api/method/logout';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {'Cookie': _cookie ?? ''}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return LogoutResponse.fromMap(response.data!);
      } else {
        throw Exception('Failed to logout. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An unknown error occurred during logout: $e');
    }
  }

  @override
  Future<PingResponse> ping() async {
    final url = '$_baseUrl/api/method/ping';
    try {
      final response = await _dio.get<Map<String, dynamic>>(url);

      if (response.statusCode == HttpStatus.ok) {
        return PingResponse.fromMap(response.data!);
      } else {
        throw Exception('Failed to ping. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An unknown error occurred during ping: $e');
    }
  }

  @override
  Future<GetVersionsResponse> getVersions() async {
    final url = '$_baseUrl/api/method/frappe.utils.change_log.get_versions';

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {'Cookie': _cookie ?? ''},
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return GetVersionsResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get versions. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An unknown error occurred getting versions: $e');
    }
  }

  /// Gets a list of resources with optional filtering and pagination.
  ///
  /// This is part of the new Resource API that returns [ApiResult<T>]
  /// instead of throwing exceptions.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.getResourceList(
  ///   'User',
  ///   options: QueryOptions(
  ///     filters: [Filter.equal('enabled', 1)],
  ///     fields: ['name', 'email'],
  ///     limitPageLength: 20,
  ///   ),
  /// );
  /// ```
  Future<ApiResult<Map<String, dynamic>>> getResourceList(
    String docType, {
    QueryOptions? options,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/resource/$docType').replace(
        queryParameters: options?.toQueryParams(),
      );

      final response = await _dio.get<Map<String, dynamic>>(
        uri.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_cookie != null) 'Cookie': _cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return ApiResult.success(response.data!);
      } else {
        final errorMessage = response.data?['message'] as String? ??
            'Failed to get resource list';
        return ApiResult.failure(
          FrappeException.fromStatusCode(
            message: errorMessage,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(
          message: handleDioError(e),
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(message: 'Failed to get resource list: $e'),
      );
    }
  }

  /// Gets a single resource by name using the Resource API.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.getResource('User', 'user@example.com');
  /// if (result.isSuccess) {
  ///   final userData = result.data!['data'];
  ///   print('Full name: ${userData['full_name']}');
  /// }
  /// ```
  Future<ApiResult<Map<String, dynamic>>> getResource(
    String docType,
    String name,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/resource/$docType/$name');

      final response = await _dio.get<Map<String, dynamic>>(
        uri.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_cookie != null) 'Cookie': _cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return ApiResult.success(response.data!);
      } else {
        final errorMessage =
            response.data?['message'] as String? ?? 'Failed to get resource';
        return ApiResult.failure(
          FrappeException.fromStatusCode(
            message: errorMessage,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(
          message: handleDioError(e),
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(message: 'Failed to get resource: $e'),
      );
    }
  }

  /// Creates a new resource using the Resource API.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.createResource('ToDo', {
  ///   'description': 'Complete the task',
  ///   'status': 'Open',
  /// });
  /// ```
  Future<ApiResult<Map<String, dynamic>>> createResource(
    String docType,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/resource/$docType');

      final response = await _dio.post<Map<String, dynamic>>(
        uri.toString(),
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_cookie != null) 'Cookie': _cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.created) {
        return ApiResult.success(response.data!);
      } else {
        final errorMessage = response.data?['message'] as String? ??
            'Failed to create resource';
        return ApiResult.failure(
          FrappeException.fromStatusCode(
            message: errorMessage,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(
          message: handleDioError(e),
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(message: 'Failed to create resource: $e'),
      );
    }
  }

  /// Updates an existing resource using the Resource API.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.updateResource(
  ///   'ToDo',
  ///   'TODO-00001',
  ///   {'status': 'Closed'},
  /// );
  /// ```
  Future<ApiResult<Map<String, dynamic>>> updateResource(
    String docType,
    String name,
    Map<String, dynamic> data,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/resource/$docType/$name');

      final response = await _dio.put<Map<String, dynamic>>(
        uri.toString(),
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_cookie != null) 'Cookie': _cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return ApiResult.success(response.data!);
      } else {
        final errorMessage = response.data?['message'] as String? ??
            'Failed to update resource';
        return ApiResult.failure(
          FrappeException.fromStatusCode(
            message: errorMessage,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(
          message: handleDioError(e),
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(message: 'Failed to update resource: $e'),
      );
    }
  }

  /// Deletes a resource using the Resource API.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.deleteResource('ToDo', 'TODO-00001');
  /// if (result.isSuccess) {
  ///   print('Deleted successfully');
  /// }
  /// ```
  Future<ApiResult<Map<String, dynamic>>> deleteResource(
    String docType,
    String name,
  ) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/resource/$docType/$name');

      final response = await _dio.delete<Map<String, dynamic>>(
        uri.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_cookie != null) 'Cookie': _cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok ||
          response.statusCode == HttpStatus.accepted ||
          response.statusCode == HttpStatus.noContent) {
        return ApiResult.success(response.data ?? {});
      } else {
        final errorMessage = response.data?['message'] as String? ??
            'Failed to delete resource';
        return ApiResult.failure(
          FrappeException.fromStatusCode(
            message: errorMessage,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(
          message: handleDioError(e),
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(message: 'Failed to delete resource: $e'),
      );
    }
  }

  /// Sets a single field value for a document.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.setFieldValue(
  ///   'ToDo',
  ///   'TODO-00001',
  ///   'status',
  ///   'Closed',
  /// );
  /// ```
  Future<ApiResult<Map<String, dynamic>>> setFieldValue(
    String docType,
    String name,
    String fieldName,
    dynamic value,
  ) async {
    try {
      final url = '$_baseUrl/api/method/frappe.client.set_value';

      final data = {
        'doctype': docType,
        'name': name,
        'fieldname': fieldName,
        'value': value,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (_cookie != null) 'Cookie': _cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return ApiResult.success(response.data!);
      } else {
        final errorMessage =
            response.data?['message'] as String? ?? 'Failed to set value';
        return ApiResult.failure(
          FrappeException.fromStatusCode(
            message: errorMessage,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(
          message: handleDioError(e),
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(message: 'Failed to set value: $e'),
      );
    }
  }

  /// Calls a custom Frappe method with POST.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.callFrappeMethod(
  ///   'myapp.api.my_method',
  ///   data: {'param1': 'value1'},
  /// );
  /// ```
  Future<ApiResult<Map<String, dynamic>>> callFrappeMethod(
    String methodPath, {
    Map<String, dynamic>? data,
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/method/$methodPath').replace(
        queryParameters: queryParams,
      );

      final response = await _dio.post<Map<String, dynamic>>(
        uri.toString(),
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_cookie != null) 'Cookie': _cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return ApiResult.success(response.data!);
      } else {
        final errorMessage =
            response.data?['message'] as String? ?? 'Failed to call method';
        return ApiResult.failure(
          FrappeException.fromStatusCode(
            message: errorMessage,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(
          message: handleDioError(e),
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(message: 'Failed to call method: $e'),
      );
    }
  }

  /// Calls a custom Frappe method with GET.
  ///
  /// Example:
  /// ```dart
  /// final result = await client.callFrappeMethodGet(
  ///   'myapp.api.my_method',
  ///   queryParams: {'param1': 'value1'},
  /// );
  /// ```
  Future<ApiResult<Map<String, dynamic>>> callFrappeMethodGet(
    String methodPath, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/method/$methodPath').replace(
        queryParameters: queryParams,
      );

      final response = await _dio.get<Map<String, dynamic>>(
        uri.toString(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            if (_cookie != null) 'Cookie': _cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return ApiResult.success(response.data!);
      } else {
        final errorMessage =
            response.data?['message'] as String? ?? 'Failed to call method';
        return ApiResult.failure(
          FrappeException.fromStatusCode(
            message: errorMessage,
            statusCode: response.statusCode,
            data: response.data,
          ),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(
          message: handleDioError(e),
          statusCode: e.response?.statusCode,
          data: e.response?.data,
        ),
      );
    } catch (e) {
      return ApiResult.failure(
        FrappeException.fromStatusCode(message: 'Failed to call method: $e'),
      );
    }
  }
}
