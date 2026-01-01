// ignore_for_file: prefer_const_constructors
import 'package:dio/dio.dart';
import 'package:frappe_dart/frappe_dart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'frappe_api_test.mocks.dart';

// Generate mock class
@GenerateMocks([Dio])
void main() {
  late FrappeV15 frappeApi;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    frappeApi = FrappeV15(baseUrl: 'https://example.com', dio: mockDio);
  });

  group('frappe.client API methods', () {
    test('insert should return created document when successful', () async {
      final insertRequest = InsertRequest(
        doc: {'doctype': 'Task', 'title': 'New Task'},
      );
      final responseData = {
        'message': {'name': 'TASK-0001', 'title': 'New Task'}
      };

      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.insert(insertRequest);

      expect(response['message'], isNotNull);
      expect(response['message']['name'], 'TASK-0001');
    });

    test('setValue should update field value when successful', () async {
      final setValueRequest = SetValueRequest(
        doctype: 'Task',
        name: 'TASK-0001',
        fieldname: 'status',
        value: 'Completed',
      );
      final responseData = {
        'message': 'ok'
      };

      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.setValue(setValueRequest);

      expect(response['message'], 'ok');
    });

    test('renameDoc should rename document when successful', () async {
      final renameDocRequest = RenameDocRequest(
        doctype: 'Task',
        oldName: 'TASK-0001',
        newName: 'TASK-0002',
      );
      final responseData = {
        'message': 'renamed'
      };

      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.renameDoc(renameDocRequest);

      expect(response['message'], 'renamed');
    });

    test('submitDoc should submit document when successful', () async {
      final submitDocRequest = SubmitDocRequest(
        doc: {'doctype': 'Task', 'name': 'TASK-0001'},
      );
      final responseData = {
        'message': {'docstatus': 1}
      };

      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.submitDoc(submitDocRequest);

      expect(response['message'], isNotNull);
    });

    test('cancelDoc should cancel document when successful', () async {
      final cancelDocRequest = CancelDocRequest(
        doctype: 'Task',
        name: 'TASK-0001',
      );
      final responseData = {
        'message': {'docstatus': 2}
      };

      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.cancelDoc(cancelDocRequest);

      expect(response['message'], isNotNull);
    });

    test('exists should check document existence when successful', () async {
      final existsRequest = ExistsRequest(
        doctype: 'Task',
        name: 'TASK-0001',
      );
      final responseData = {
        'message': 'TASK-0001'
      };

      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.exists(existsRequest);

      expect(response['message'], 'TASK-0001');
    });
  });

  group('REST Resource API methods', () {
    test('getResourceList should return list of documents', () async {
      final responseData = {
        'data': [
          {'name': 'TASK-0001', 'title': 'Task 1'},
          {'name': 'TASK-0002', 'title': 'Task 2'}
        ]
      };

      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          queryParameters: anyNamed('queryParameters'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.getResourceList('Task');

      expect(response['data'], isNotNull);
      expect(response['data'], hasLength(2));
    });

    test('getResource should return single document', () async {
      final responseData = {
        'data': {'name': 'TASK-0001', 'title': 'Task 1'}
      };

      when(
        mockDio.get<Map<String, dynamic>>(
          any,
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.getResource('Task', 'TASK-0001');

      expect(response['data'], isNotNull);
      expect(response['data']['name'], 'TASK-0001');
    });

    test('createResource should create new document', () async {
      final docData = {'title': 'New Task'};
      final responseData = {
        'data': {'name': 'TASK-0001', 'title': 'New Task'}
      };

      when(
        mockDio.post<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.createResource('Task', docData);

      expect(response['data'], isNotNull);
      expect(response['data']['name'], 'TASK-0001');
    });

    test('updateResource should update document', () async {
      final docData = {'title': 'Updated Task'};
      final responseData = {
        'data': {'name': 'TASK-0001', 'title': 'Updated Task'}
      };

      when(
        mockDio.put<Map<String, dynamic>>(
          any,
          data: anyNamed('data'),
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response =
          await frappeApi.updateResource('Task', 'TASK-0001', docData);

      expect(response['data'], isNotNull);
      expect(response['data']['title'], 'Updated Task');
    });

    test('deleteResource should delete document', () async {
      final responseData = {
        'message': 'ok'
      };

      when(
        mockDio.delete<Map<String, dynamic>>(
          any,
          options: anyNamed('options'),
        ),
      ).thenAnswer(
        (_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(),
        ),
      );

      final response = await frappeApi.deleteResource('Task', 'TASK-0001');

      expect(response['message'], 'ok');
    });
  });
}
