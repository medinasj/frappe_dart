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
      const exception = FrappeHttpException(
        message: 'Test error',
        statusCode: 500,
      );
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
      const exception = FrappeHttpException(
        message: 'Test error',
        statusCode: 500,
      );
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
    test('FrappeNotFoundException has correct status code', () {
      const exception = FrappeNotFoundException(message: 'Not found');

      expect(exception.message, equals('Not found'));
      expect(exception.statusCode, equals(404));
      expect(exception.toString(), contains('FrappeNotFoundException'));
      expect(exception.toString(), contains('404'));
    });

    test('FrappeUnauthorizedException has correct status code', () {
      const exception = FrappeUnauthorizedException(message: 'Unauthorized');

      expect(exception.message, equals('Unauthorized'));
      expect(exception.statusCode, equals(401));
      expect(exception.toString(), contains('FrappeUnauthorizedException'));
    });

    test('FrappeForbiddenException has correct status code', () {
      const exception = FrappeForbiddenException(message: 'Forbidden');

      expect(exception.message, equals('Forbidden'));
      expect(exception.statusCode, equals(403));
      expect(exception.toString(), contains('FrappeForbiddenException'));
    });

    test('FrappeServerException has correct status code', () {
      const exception = FrappeServerException(message: 'Server error');

      expect(exception.message, equals('Server error'));
      expect(exception.statusCode, equals(500));
      expect(exception.toString(), contains('FrappeServerException'));
    });

    test('FrappeHttpException with custom status code', () {
      const exception = FrappeHttpException(
        message: 'Bad request',
        statusCode: 400,
      );

      expect(exception.message, equals('Bad request'));
      expect(exception.statusCode, equals(400));
    });

    test('exception with additional data', () {
      const exception = FrappeHttpException(
        message: 'Test error',
        statusCode: 500,
        data: {'detail': 'Server error'},
      );

      expect(exception.data, equals({'detail': 'Server error'}));
      final string = exception.toString();
      expect(string, contains('Test error'));
      expect(string, contains('detail'));
    });
  });

  group('Filter', () {
    test('equal filter creates correct JSON', () {
      const filter = Filter.equal('status', 'Open');

      expect(filter.field, equals('status'));
      expect(filter.operator, equals('='));
      expect(filter.value, equals('Open'));
      expect(filter.toJson(), equals(['status', '=', 'Open']));
    });

    test('notEqual filter creates correct JSON', () {
      const filter = Filter.notEqual('status', 'Closed');

      expect(filter.operator, equals('!='));
      expect(filter.toJson(), equals(['status', '!=', 'Closed']));
    });

    test('greaterThan filter creates correct JSON', () {
      const filter = Filter.greaterThan('amount', 1000);

      expect(filter.operator, equals('>'));
      expect(filter.toJson(), equals(['amount', '>', 1000]));
    });

    test('greaterThanOrEqual filter creates correct JSON', () {
      const filter = Filter.greaterThanOrEqual('amount', 1000);

      expect(filter.operator, equals('>='));
      expect(filter.toJson(), equals(['amount', '>=', 1000]));
    });

    test('lessThan filter creates correct JSON', () {
      const filter = Filter.lessThan('amount', 100);

      expect(filter.operator, equals('<'));
      expect(filter.toJson(), equals(['amount', '<', 100]));
    });

    test('lessThanOrEqual filter creates correct JSON', () {
      const filter = Filter.lessThanOrEqual('amount', 100);

      expect(filter.operator, equals('<='));
      expect(filter.toJson(), equals(['amount', '<=', 100]));
    });

    test('like filter creates correct JSON', () {
      const filter = Filter.like('customer', '%Corp%');

      expect(filter.operator, equals('like'));
      expect(filter.toJson(), equals(['customer', 'like', '%Corp%']));
    });

    test('notLike filter creates correct JSON', () {
      const filter = Filter.notLike('customer', '%Test%');

      expect(filter.operator, equals('not like'));
      expect(filter.toJson(), equals(['customer', 'not like', '%Test%']));
    });

    test('isIn filter creates correct JSON', () {
      const filter = Filter.isIn('type', ['Sales', 'Purchase']);

      expect(filter.operator, equals('in'));
      expect(
        filter.toJson(),
        equals([
          'type',
          'in',
          ['Sales', 'Purchase'],
        ]),
      );
    });

    test('notIn filter creates correct JSON', () {
      const filter = Filter.notIn('status', ['Cancelled', 'Closed']);

      expect(filter.operator, equals('not in'));
      expect(
        filter.toJson(),
        equals([
          'status',
          'not in',
          ['Cancelled', 'Closed'],
        ]),
      );
    });

    test('isNull filter creates correct JSON', () {
      const filter = Filter.isNull('parent');

      expect(filter.operator, equals('is'));
      expect(filter.value, isNull);
      expect(filter.toJson(), equals(['parent', 'is', null]));
    });

    test('isNotNull filter creates correct JSON', () {
      const filter = Filter.isNotNull('parent');

      expect(filter.operator, equals('is not'));
      expect(filter.value, isNull);
      expect(filter.toJson(), equals(['parent', 'is not', null]));
    });

    test('toString returns readable format', () {
      const filter = Filter.equal('status', 'Open');

      expect(filter.toString(), equals('Filter(status = Open)'));
    });
  });

  group('QueryOptions', () {
    test('creates empty query params when no options provided', () {
      const options = QueryOptions();
      final params = options.toQueryParams();

      expect(params, isEmpty);
    });

    test('converts Filter list to query params', () {
      const options = QueryOptions(
        filters: [
          Filter.equal('status', 'Open'),
          Filter.greaterThan('amount', 1000),
        ],
      );
      final params = options.toQueryParams();

      expect(params['filters'], isNotNull);
      expect(
        params['filters'],
        equals('[["status","=","Open"],["amount",">",1000]]'),
      );
    });

    test('converts filtersJson to query params', () {
      const options = QueryOptions(
        filtersJson: '[["status", "=", "Open"]]',
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

    test('converts all options together with Filter list', () {
      const options = QueryOptions(
        filters: [
          Filter.equal('enabled', 1),
          Filter.like('name', '%test%'),
        ],
        fields: ['name', 'full_name'],
        orderBy: 'creation asc',
        limitPageLength: 10,
        limitStart: 0,
      );
      final params = options.toQueryParams();

      expect(params['filters'], isNotNull);
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

    test('ignores empty filters list', () {
      const options = QueryOptions(filters: []);
      final params = options.toQueryParams();

      expect(params.containsKey('filters'), isFalse);
    });
  });
}
