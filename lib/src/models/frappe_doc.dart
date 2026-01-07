/// Base class for Frappe documents.
///
/// All Frappe documents have common fields that are managed by the framework.
/// Extend this class to create type-safe document models.
///
/// Example:
/// ```dart
/// class User extends FrappeDoc {
///   const User({
///     required super.name,
///     required super.owner,
///     required super.creation,
///     required super.modified,
///     required super.modifiedBy,
///     required this.email,
///     required this.fullName,
///   });
///
///   factory User.fromJson(Map<String, dynamic> json) {
///     return User(
///       name: json['name'] as String,
///       owner: json['owner'] as String,
///       creation: DateTime.parse(json['creation'] as String),
///       modified: DateTime.parse(json['modified'] as String),
///       modifiedBy: json['modified_by'] as String,
///       email: json['email'] as String,
///       fullName: json['full_name'] as String,
///     );
///   }
///
///   final String email;
///   final String fullName;
/// }
/// ```
abstract class FrappeDoc {
  /// Creates a new Frappe document.
  const FrappeDoc({
    required this.name,
    required this.owner,
    required this.creation,
    required this.modified,
    required this.modifiedBy,
  });

  /// The name (unique identifier) of the document.
  final String name;

  /// The owner (creator) of the document.
  final String owner;

  /// The creation timestamp of the document.
  final DateTime creation;

  /// The last modified timestamp of the document.
  final DateTime modified;

  /// The user who last modified the document.
  final String modifiedBy;
}
