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
  frappe_dart: ^0.0.8
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

Using type-safe Filter objects:

```dart
final result = await frappeClient.getResourceList(
  'User',
  options: QueryOptions(
    filters: [
      Filter.equal('enabled', 1),
      Filter.greaterThan('creation', '2025-01-01'),
    ],
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

Or using JSON string filters:

```dart
final result = await frappeClient.getResourceList(
  'User',
  options: QueryOptions(
    filtersJson: '[["enabled", "=", 1]]',
    fields: ['name', 'full_name', 'email'],
    orderBy: 'creation desc',
    limitPageLength: 20,
  ),
);
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

## Type-Safe Filters

Use the `Filter` class for type-safe, readable filter building:

```dart
// Using Filter objects (recommended)
final options = QueryOptions(
  filters: [
    Filter.equal('status', 'Open'),
    Filter.greaterThan('amount', 1000),
    Filter.like('customer_name', '%Corp%'),
    Filter.isIn('type', ['Sales', 'Purchase']),
  ],
  fields: ['name', 'customer', 'status'],
  orderBy: 'creation desc',
  limitPageLength: 20,
  limitStart: 0,
);
```

### Filter Constructors

- `Filter.equal(field, value)` - Equal to (=)
- `Filter.notEqual(field, value)` - Not equal to (!=)
- `Filter.greaterThan(field, value)` - Greater than (>)
- `Filter.greaterThanOrEqual(field, value)` - Greater than or equal (>=)
- `Filter.lessThan(field, value)` - Less than (<)
- `Filter.lessThanOrEqual(field, value)` - Less than or equal (<=)
- `Filter.like(field, value)` - Pattern matching
- `Filter.notLike(field, value)` - Negative pattern matching
- `Filter.isIn(field, value)` - In list
- `Filter.notIn(field, value)` - Not in list
- `Filter.isNull(field)` - Is null
- `Filter.isNotNull(field)` - Is not null

### JSON String Filters (alternative)

You can also use JSON string filters if needed:

```dart
final options = QueryOptions(
  // Filter conditions as JSON array string
  filtersJson: '[["status", "=", "Open"], ["creation", ">=", "2025-01-01"]]',
  
  // Specific fields to return
  fields: ['name', 'customer', 'status'],
  
  // Sort order
  orderBy: 'creation desc',
  
  // Pagination
  limitPageLength: 20,
  limitStart: 0,
);
```

## Type-Safe Document Models

Extend `FrappeDoc` to create type-safe document models:

```dart
class User extends FrappeDoc {
  const User({
    required super.name,
    required super.owner,
    required super.creation,
    required super.modified,
    required super.modifiedBy,
    required this.email,
    required this.fullName,
    required this.enabled,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'] as String,
      owner: json['owner'] as String,
      creation: DateTime.parse(json['creation'] as String),
      modified: DateTime.parse(json['modified'] as String),
      modifiedBy: json['modified_by'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String,
      enabled: json['enabled'] == 1,
    );
  }

  final String email;
  final String fullName;
  final bool enabled;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner': owner,
      'email': email,
      'full_name': fullName,
      'enabled': enabled ? 1 : 0,
    };
  }
}
```

## Error Handling with ApiResult

The new Resource API methods return `ApiResult<T>` for clean error handling:

```dart
final result = await frappeClient.getResource('User', 'user@example.com');

if (result.isSuccess) {
  // Access data
  final data = result.data!;
  print(data);
} else {
  // Handle error - specific exception types
  final error = result.error!;
  
  if (error is FrappeNotFoundException) {
    print('User not found');
  } else if (error is FrappeUnauthorizedException) {
    print('Please log in');
  } else if (error is FrappeForbiddenException) {
    print('Access denied');
  } else if (error is FrappeServerException) {
    print('Server error occurred');
  } else {
    print('Error: ${error.message}');
  }
  
  print('Status Code: ${error.statusCode}');
  print('Additional Data: ${error.data}');
}
```

### Specific Exception Types

- `FrappeNotFoundException` - Resource not found (404)
- `FrappeUnauthorizedException` - Authentication required (401)
- `FrappeForbiddenException` - Access forbidden (403)
- `FrappeServerException` - Server errors (500+)
- `FrappeHttpException` - Other HTTP errors

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
