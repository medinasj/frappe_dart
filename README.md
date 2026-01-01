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
  frappe_dart: ^0.0.6
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

## Features

The `frappe_dart` package provides comprehensive support for Frappe v15 API endpoints:

### Authentication
- `login()` - Authenticate user and get session cookie
- `logout()` - End user session

### Document Operations
#### frappe.client Methods
- `insert()` - Create new documents
- `save()` - Update existing documents  
- `setValue()` - Update specific field values
- `deleteDoc()` - Delete documents
- `renameDoc()` - Rename documents
- `submitDoc()` - Submit documents (workflow)
- `cancelDoc()` - Cancel submitted documents (workflow)
- `exists()` - Check if document exists

#### REST Resource API
- `getResourceList()` - Get list of documents with filtering and pagination
- `getResource()` - Get single document by name
- `createResource()` - Create new document via REST
- `updateResource()` - Update document via REST (PUT)
- `deleteResource()` - Delete document via REST

#### Form and Desk Operations  
- `getdoc()` - Get document with metadata
- `getDoctype()` - Get doctype metadata
- `getList()` - Get list with advanced filtering
- `get()` - Get document by doctype and name
- `getValue()` - Get specific field value
- `getCount()` - Get count of documents

### Desktop & Workspace
- `getDeskSideBarItems()` - Get sidebar items
- `getDesktopPage()` - Get desktop page details
- `getNumberCard()` - Get number card data
- `getNumberCardPercentageDifference()` - Get percentage difference for number cards

### Search & Links
- `searchLink()` - Search for linked documents
- `validateLink()` - Validate link field
- `searchWidget()` - Search in widgets

### Reports & Charts
- `getReportView()` - Get report view data
- `getReportRun()` - Execute report
- `getDashboardChart()` - Get dashboard chart data

### System Operations
- `getSystemSettings()` - Get system settings
- `getVersions()` - Get installed app versions
- `getApps()` - Get list of installed apps
- `getUserInfo()` - Get current user information
- `getLoggerUser()` - Get logged-in user details
- `ping()` - Check server connectivity
- `switchTheme()` - Change user theme

### Advanced Operations
- `savedocs()` - Save documents with validation
- `mapDocs()` - Map documents between doctypes
- `runDocMethod()` - Execute document methods
- `call()` - Call custom API methods
- `sendEmail()` - Send emails

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
