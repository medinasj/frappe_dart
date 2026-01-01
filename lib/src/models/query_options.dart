/// Options for filtering and sorting resource queries.
///
/// This provides a clean way to build query parameters for resource list
/// endpoints. Supports filtering, field selection, sorting, and pagination.
///
/// Example:
/// ```dart
/// final options = QueryOptions(
///   filters: '[["status", "=", "Open"]]',
///   fields: ['name', 'customer', 'status'],
///   orderBy: 'creation desc',
///   limitPageLength: 20,
///   limitStart: 0,
/// );
/// ```
class QueryOptions {
  /// Filter conditions as a JSON array string.
  ///
  /// Each filter is an array: `[fieldname, operator, value]`
  ///
  /// Examples:
  /// - Single filter: `'[["status", "=", "Open"]]'`
  /// - Multiple filters: `'[["status", "=", "Open"], ["date", ">=", "2025-01-01"]]'`
  ///
  /// Available operators: `=`, `!=`, `>`, `<`, `>=`, `<=`, `like`, `not like`,
  /// `in`, `not in`, `is`, `is not`
  final String? filters;

  /// Fields to include in the response.
  ///
  /// If not specified, all fields are returned.
  /// Example: `['name', 'customer', 'status']`
  final List<String>? fields;

  /// Field to sort by.
  ///
  /// Examples:
  /// - Ascending: `'creation asc'`
  /// - Descending: `'creation desc'`
  /// - Multiple fields: `'status asc, creation desc'`
  final String? orderBy;

  /// Number of records to fetch.
  ///
  /// Used for pagination. Default is usually 20.
  final int? limitPageLength;

  /// Starting index for pagination.
  ///
  /// Use 0 for first page, 20 for second page (if limitPageLength is 20), etc.
  final int? limitStart;

  /// Creates a new [QueryOptions] instance.
  const QueryOptions({
    this.filters,
    this.fields,
    this.orderBy,
    this.limitPageLength,
    this.limitStart,
  });

  /// Converts options to query parameters.
  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    if (filters != null) {
      params['filters'] = filters!;
    }
    if (fields != null && fields!.isNotEmpty) {
      params['fields'] = '["${fields!.join('","')}"]';
    }
    if (orderBy != null) {
      params['order_by'] = orderBy!;
    }
    if (limitPageLength != null) {
      params['limit_page_length'] = limitPageLength.toString();
    }
    if (limitStart != null) {
      params['limit_start'] = limitStart.toString();
    }

    return params;
  }
}
