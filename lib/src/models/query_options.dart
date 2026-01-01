import 'dart:convert';

import 'package:frappe_dart/src/models/filter.dart';

/// Options for filtering and sorting resource queries.
///
/// This provides a clean way to build query parameters for resource list
/// endpoints. Supports filtering, field selection, sorting, and pagination.
///
/// Example with Filter objects:
/// ```dart
/// final options = QueryOptions(
///   filters: [
///     Filter.equal('status', 'Open'),
///     Filter.greaterThan('amount', 1000),
///   ],
///   fields: ['name', 'customer', 'status'],
///   orderBy: 'creation desc',
///   limitPageLength: 20,
///   limitStart: 0,
/// );
/// ```
///
/// Example with JSON string:
/// ```dart
/// final options = QueryOptions(
///   filtersJson: '[["status", "=", "Open"]]',
///   fields: ['name', 'customer', 'status'],
/// );
/// ```
class QueryOptions {
  /// Creates a new [QueryOptions] instance.
  const QueryOptions({
    this.filters,
    this.filtersJson,
    this.fields,
    this.orderBy,
    this.limitPageLength,
    this.limitStart,
  }) : assert(
          filters == null || filtersJson == null,
          'Cannot provide both filters and filtersJson',
        );

  /// Filter conditions as a list of [Filter] objects.
  ///
  /// Examples:
  /// ```dart
  /// filters: [
  ///   Filter.equal('status', 'Open'),
  ///   Filter.greaterThan('amount', 1000),
  ///   Filter.like('customer', '%Corp%'),
  /// ]
  /// ```
  final List<Filter>? filters;

  /// Filter conditions as a JSON array string.
  ///
  /// Each filter is an array: `[fieldname, operator, value]`
  ///
  /// Examples:
  /// - Single filter: `'[["status", "=", "Open"]]'`
  /// - Multiple filters:
  /// `'[["status", "=", "Open"], ["date", ">=", "2025-01-01"]]'`
  ///
  /// Available operators: `=`, `!=`, `>`, `<`, `>=`, `<=`, `like`,
  /// `not like`, `in`, `not in`, `is`, `is not`
  final String? filtersJson;

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
  /// Use 0 for first page, 20 for second page
  /// (if limitPageLength is 20), etc.
  final int? limitStart;

  /// Converts options to query parameters.
  Map<String, String> toQueryParams() {
    final params = <String, String>{};

    // Handle filters
    if (filters != null && filters!.isNotEmpty) {
      final filtersList = filters!.map((f) => f.toJson()).toList();
      params['filters'] = jsonEncode(filtersList);
    } else if (filtersJson != null) {
      params['filters'] = filtersJson!;
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
