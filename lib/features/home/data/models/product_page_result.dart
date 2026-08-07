import 'product_model.dart';

/// نتيجة صفحة منتجات من أمان ERP
class ProductPageResult {
  const ProductPageResult({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;
}
