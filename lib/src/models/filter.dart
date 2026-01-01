/// Represents a filter for querying documents.
///
/// Provides type-safe filter building with named constructors for common
/// operations. Filters can be combined in lists for complex queries.
///
/// Example:
/// ```dart
/// final filters = [
///   Filter.equal('status', 'Open'),
///   Filter.greaterThan('amount', 1000),
///   Filter.like('customer_name', '%Corp%'),
/// ];
/// ```
class Filter {
  /// Creates a new filter.
  const Filter({
    required this.field,
    required this.operator,
    required this.value,
  });

  /// Creates a filter with the equal operator (=).
  const Filter.equal(this.field, this.value) : operator = '=';

  /// Creates a filter with the not equal operator (!=).
  const Filter.notEqual(this.field, this.value) : operator = '!=';

  /// Creates a filter with the less than operator (<).
  const Filter.lessThan(this.field, this.value) : operator = '<';

  /// Creates a filter with the less than or equal operator (<=).
  const Filter.lessThanOrEqual(this.field, this.value) : operator = '<=';

  /// Creates a filter with the greater than operator (>).
  const Filter.greaterThan(this.field, this.value) : operator = '>';

  /// Creates a filter with the greater than or equal operator (>=).
  const Filter.greaterThanOrEqual(this.field, this.value) : operator = '>=';

  /// Creates a filter with the like operator.
  const Filter.like(this.field, this.value) : operator = 'like';

  /// Creates a filter with the not like operator.
  const Filter.notLike(this.field, this.value) : operator = 'not like';

  /// Creates a filter with the in operator.
  const Filter.isIn(this.field, this.value) : operator = 'in';

  /// Creates a filter with the not in operator.
  const Filter.notIn(this.field, this.value) : operator = 'not in';

  /// Creates a filter with the is operator.
  const Filter.isNull(this.field) : operator = 'is', value = null;

  /// Creates a filter with the is not operator.
  const Filter.isNotNull(this.field) : operator = 'is not', value = null;

  /// The field to filter by.
  final String field;

  /// The operator to use.
  final String operator;

  /// The value to filter by.
  final dynamic value;

  /// Converts the filter to a JSON array format expected by Frappe.
  ///
  /// Returns: `[field, operator, value]`
  List<dynamic> toJson() {
    return [field, operator, value];
  }

  @override
  String toString() => 'Filter($field $operator $value)';
}
