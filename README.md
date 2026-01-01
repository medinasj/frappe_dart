# Frappe Dart

A comprehensive Dart wrapper for interacting with the Frappe API, providing easy access to its features and enabling seamless communication with Frappe-based systems.

🚧 **Note:** This project is currently under construction and is not production-ready. Expect significant changes as the project evolves.

## Example App

Looking for a working example? Check out the official example app here:  
👉 [https://github.com/kinetsystems/frappify](https://github.com/kinetsystems/frappify)

This separate repository demonstrates how to integrate and use `frappe_dart` in a real-world Flutter application.

## Installation

To get started with the `frappe_dart` package, add it to your project's `pubspec.yaml` dependencies:

```yaml
dependencies:
  frappe_dart: ^0.0.7
```

## Usage

Once installed, you can use the wrapper to interact with the Frappe API. Here's an example of how to perform a basic request:

```dart
import 'package:frappe_dart/frappe_dart.dart';

void main() async {
  final frappeClient = FrappeV15(
    baseUrl: 'https://your-frappe-url.com',
  );

  try {
    final authResponse = await frappeClient.login(
      LoginRequest(
        usr: 'your-username',
        pwd: 'your-password',
      ),
    );

    frappeClient.cookie = authResponse.cookie;

    final sidebarItems = await frappeClient.getDeskSideBarItems();

    final page = sidebarItems.message!.pages!
        .firstWhere((element) => element.name == 'Users');

    final deskPage = await frappeClient.getDesktopPage(
      DesktopPageRequest(
        name: page.name,
      ),
    );

    print(deskPage.toJson());
  } catch (error) {
    print('Error: $error');
  }
}
```

## Resource API

The package now includes improved Resource API methods with better error handling using `ApiResult<T>`:

### Get a List of Resources

```dart
final result = await frappeClient.getResourceList(
  'User',
  options: QueryOptions(
    filters: '[["enabled", "=", 1]]',
    fields: ['name', 'full_name', 'email'],
    orderBy: 'creation desc',
    limitPageLength: 20,
    limitStart: 0,
  ),
);

if (result.isSuccess) {
  final users = result.data!['data'] as List;
  print('Found ${users.length} users');
} else {
  print('Error: ${result.error!.message}');
}
```

### Get a Single Resource

```dart
final result = await frappeClient.getResource('User', 'user@example.com');

if (result.isSuccess) {
  final user = result.data!['data'];
  print('Full name: ${user['full_name']}');
}
```

### Create a Resource

```dart
final result = await frappeClient.createResource('ToDo', {
  'description': 'Complete the task',
  'status': 'Open',
});

if (result.isSuccess) {
  final newTodo = result.data!['data'];
  print('Created: ${newTodo['name']}');
}
```

### Update a Resource

```dart
final result = await frappeClient.updateResource(
  'ToDo',
  'TODO-00001',
  {'status': 'Closed'},
);

if (result.isSuccess) {
  print('Updated successfully');
}
```

### Delete a Resource

```dart
final result = await frappeClient.deleteResource('ToDo', 'TODO-00001');

if (result.isSuccess) {
  print('Deleted successfully');
}
```

## Query Options

Use `QueryOptions` to filter and sort resource queries:

```dart
final options = QueryOptions(
  // Filter conditions as JSON array string
  filters: '[["status", "=", "Open"], ["creation", ">=", "2025-01-01"]]',
  
  // Specific fields to return
  fields: ['name', 'customer', 'status'],
  
  // Sort order
  orderBy: 'creation desc',
  
  // Pagination
  limitPageLength: 20,
  limitStart: 0,
);
```

### Available Filter Operators

- `=`, `!=` - Equality
- `>`, `<`, `>=`, `<=` - Comparison
- `like`, `not like` - Pattern matching
- `in`, `not in` - List membership
- `is`, `is not` - Null checks

## Error Handling with ApiResult

The new Resource API methods return `ApiResult<T>` for clean error handling:

```dart
final result = await frappeClient.getResource('User', 'user@example.com');

if (result.isSuccess) {
  // Access data
  final data = result.data!;
  print(data);
} else {
  // Handle error
  final error = result.error!;
  print('Error: ${error.message}');
  print('Status Code: ${error.statusCode}');
  print('Additional Data: ${error.data}');
}
```

### Result Mapping

Transform API responses easily:

```dart
final result = await frappeClient.getResource('User', 'user@example.com');

final mappedResult = result.map((data) {
  final userData = data['data'] as Map<String, dynamic>;
  return User.fromJson(userData);
});

if (mappedResult.isSuccess) {
  final user = mappedResult.data!;
  print(user.fullName);
}
```

## Custom Method Calls

Call custom Frappe server-side methods:

```dart
// POST request
final result = await frappeClient.callFrappeMethod(
  'myapp.api.update_status',
  data: {
    'docname': 'TODO-00001',
    'status': 'Completed',
  },
);

// GET request
final result = await frappeClient.callFrappeMethodGet(
  'myapp.api.get_statistics',
  queryParams: {'date': '2025-12-14'},
);
```

## Setting Field Values

Set individual field values on documents:

```dart
final result = await frappeClient.setFieldValue(
  'User',
  'user@example.com',
  'bio',
  'Software developer',
);

if (result.isSuccess) {
  print('Field updated successfully');
}
```

## How to extend

You can extend the functionality of frappe_dart to support additional custom API endpoints using Dart's extension methods.

```dart
import 'package:http/http.dart' as http;

extension FrappeV15Extensions on FrappeV15 {
  Future<Map<String, dynamic>> newApiEndPoint() async {
    final url = '$baseUrl/api/method/new_api_endpoint';

    final response = await dio.get<Map<String, dynamic>>(
      url,
      headers: {
        if (cookie != null) 'Cookie': cookie,
      },
    );

    return response.data!;
  }
}
```

## Contributing

We welcome contributions to improve and extend the functionality of frappe_dart. If you’d like to contribute, please follow these steps:

1. Fork the repository.
2. Create a new branch for your feature or bug fix.
3. Write tests to ensure the changes work as expected.
4. Submit a pull request with a detailed explanation of your changes.

For bug reports, feature requests, or any issues, please open an issue on the GitHub repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
