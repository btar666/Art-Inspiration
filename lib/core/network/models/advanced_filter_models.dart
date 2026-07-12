/// جداول Dan ERP المستخدمة في advancedFilter
abstract final class ErpTables {
  static const products = 'inventory_products';
  static const settings = 'setting';
  static const salesInvoices = 'sales_invoices';
  static const users = 'users';
  static const userStatement = 'user_statement';
  static const purchaseInvoices = 'purchase_invoices';
}

/// طلب advancedFilter
class AdvancedFilterRequest {
  const AdvancedFilterRequest({
    required this.tableName,
    this.filters = const [],
    this.sorts = const [],
    this.perPage = 20,
    this.relations = const [],
    this.page = 1,
  });

  final String tableName;
  final List<AdvancedFilterClause> filters;
  final List<AdvancedFilterSort> sorts;
  final int perPage;
  final List<String> relations;
  final int page;

  Map<String, dynamic> toJson() => {
        'tableName': tableName,
        'filters': filters.map((f) => f.toJson()).toList(),
        'sorts': sorts.map((s) => s.toJson()).toList(),
        'per_page': perPage,
        'relations': relations,
      };
}

class AdvancedFilterClause {
  const AdvancedFilterClause({
    required this.field,
    required this.operator,
    required this.value,
    this.type = 'basic',
    this.andOr = 'and',
    this.jsonPath,
  });

  final String field;
  final String operator;
  final String value;
  final String type;
  final String andOr;
  final String? jsonPath;

  Map<String, dynamic> toJson() => {
        'field': field,
        'operator': operator,
        'value': value,
        'type': type,
        'andOr': andOr,
        if (jsonPath != null) 'json_path': jsonPath,
      };
}

class AdvancedFilterSort {
  const AdvancedFilterSort({
    required this.field,
    this.direction = 'desc',
    this.type = 'basic',
    this.jsonPath,
  });

  final String field;
  final String direction;
  final String type;
  final String? jsonPath;

  Map<String, dynamic> toJson() => {
        'field': field,
        'direction': direction,
        'type': type,
        if (jsonPath != null) 'json_path': jsonPath,
      };
}

/// نتيجة paginated
class PaginatedResult<T> {
  const PaginatedResult({
    required this.items,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  final List<T> items;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}
