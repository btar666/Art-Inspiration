/// إحصائيات الكتalog من Dan ERP
class CatalogStats {
  const CatalogStats({
    this.totalProducts = 0,
    this.brandCount = 0,
    this.categoryCount = 0,
    this.productsWithImages = 0,
    this.productsWithoutBrand = 0,
  });

  final int totalProducts;
  final int brandCount;
  final int categoryCount;
  final int productsWithImages;
  final int productsWithoutBrand;

  bool get hasCategories => categoryCount > 0;
  bool get hasProductImages => productsWithImages > 0;
}
