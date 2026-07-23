/// مسارات أمان ERP API v1
abstract final class ApiEndpoints {
  static const me = '/me';
  static const products = '/products';
  static const categories = '/categories';
  static const brands = '/brands';
  static const stock = '/stock';
  static const customers = '/customers';
  static const salesInvoices = '/sales_invoices';

  static String product(Object id) => '$products/$id';
  static String category(Object id) => '$categories/$id';
  static String brand(Object id) => '$brands/$id';
  static String salesInvoice(Object id) => '$salesInvoices/$id';
  static String customer(Object id) => '$customers/$id';
}
