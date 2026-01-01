import 'dart:convert';

/// Request model for checking document existence via frappe.client.exists
class ExistsRequest {
  ExistsRequest({
    required this.doctype,
    required this.name,
  });

  factory ExistsRequest.fromMap(Map<String, dynamic> data) => ExistsRequest(
        doctype: data['doctype'] as String,
        name: data['name'] as String,
      );

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [ExistsRequest].
  factory ExistsRequest.fromJson(String data) {
    return ExistsRequest.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// The doctype of the document
  String doctype;

  /// The name (id) of the document to check
  String name;

  Map<String, dynamic> toMap() => {
        'doctype': doctype,
        'name': name,
      };

  /// `dart:convert`
  ///
  /// Converts [ExistsRequest] to a JSON string.
  String toJson() => json.encode(toMap());
}
