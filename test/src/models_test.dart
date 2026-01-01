import 'package:frappe_dart/frappe_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ApiResult', () {
    test('success creates a successful result', () {
      final result = ApiResult<String>.success('test data');

      expect(result.isSuccess, isTrue);
      expect(result.isError, isFalse);
      expect(result.data, equals('test data'));
      expect(result.error, isNull);
    });

    test('failure creates an error result', () {
      const exception = FrappeException(message: 'Test error');
      final result = ApiResult<String>.failure(exception);

      expect(result.isSuccess, isFalse);
      expect(result.isError, isTrue);
      expect(result.data, isNull);
      expect(result.error, equals(exception));
    });

    test('map transforms successful result', () {
      final result = ApiResult<int>.success(42);
      final mapped = result.map((value) => 'Number: $value');

      expect(mapped.isSuccess, isTrue);
      expect(mapped.data, equals('Number: 42'));
    });

    test('map preserves error result', () {
      const exception = FrappeException(message: 'Test error');
      final result = ApiResult<int>.failure(exception);
      final mapped = result.map((value) => 'Number: $value');

      expect(mapped.isError, isTrue);
      expect(mapped.error, equals(exception));
    });

    test('map catches exceptions during transformation', () {
      final result = ApiResult<int>.success(42);
      final mapped = result.map<String>(
        (_) => throw Exception('Map error'),
      );

      expect(mapped.isError, isTrue);
      expect(mapped.error?.message, contains('Mapping error'));
    });
  });

  group('FrappeException', () {
    test('creates exception with message only', () {
      const exception = FrappeException(message: 'Test error');

      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, isNull);
      expect(exception.data, isNull);
    });

    test('creates exception with all fields', () {
      const exception = FrappeException(
        message: 'Test error',
        statusCode: 404,
        data: {'error': 'Not found'},
      );

      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals(404));
      expect(exception.data, equals({'error': 'Not found'}));
    });

    test('toString includes all available information', () {
      const exception = FrappeException(
        message: 'Test error',
        statusCode: 500,
        data: {'detail': 'Server error'},
      );

      final string = exception.toString();
      expect(string, contains('FrappeException: Test error'));
      expect(string, contains('Status: 500'));
      expect(string, contains('detail'));
    });
  });

  group('QueryOptions', () {
    test('creates empty query params when no options provided', () {
      const options = QueryOptions();
      final params = options.toQueryParams();

      expect(params, isEmpty);
    });

    test('converts filters to query params', () {
      const options = QueryOptions(
        filters: '[["status", "=", "Open"]]',
      );
      final params = options.toQueryParams();

      expect(params['filters'], equals('[["status", "=", "Open"]]'));
    });

    test('converts fields to query params', () {
      const options = QueryOptions(
        fields: ['name', 'email', 'status'],
      );
      final params = options.toQueryParams();

      expect(params['fields'], equals('["name","email","status"]'));
    });

    test('converts orderBy to query params', () {
      const options = QueryOptions(
        orderBy: 'creation desc',
      );
      final params = options.toQueryParams();

      expect(params['order_by'], equals('creation desc'));
    });

    test('converts pagination params', () {
      const options = QueryOptions(
        limitPageLength: 20,
        limitStart: 40,
      );
      final params = options.toQueryParams();

      expect(params['limit_page_length'], equals('20'));
      expect(params['limit_start'], equals('40'));
    });

    test('converts all options together', () {
      const options = QueryOptions(
        filters: '[["enabled", "=", 1]]',
        fields: ['name', 'full_name'],
        orderBy: 'creation asc',
        limitPageLength: 10,
        limitStart: 0,
      );
      final params = options.toQueryParams();

      expect(params['filters'], equals('[["enabled", "=", 1]]'));
      expect(params['fields'], equals('["name","full_name"]'));
      expect(params['order_by'], equals('creation asc'));
      expect(params['limit_page_length'], equals('10'));
      expect(params['limit_start'], equals('0'));
    });

    test('ignores empty fields list', () {
      const options = QueryOptions(fields: []);
      final params = options.toQueryParams();

      expect(params.containsKey('fields'), isFalse);
    });
  });
}
