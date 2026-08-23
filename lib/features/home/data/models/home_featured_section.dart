import 'product_model.dart';

/// نوع القسم المميز في الرئيسية
enum HomeFeaturedSectionKind {
  category,
  brand,
}

/// قسم أو براند مميز مع منتجاته — للعرض الأفقي في الرئيسية
class HomeFeaturedSection {
  const HomeFeaturedSection({
    required this.erpId,
    required this.name,
    required this.kind,
    required this.products,
  });

  final int erpId;
  final String name;
  final HomeFeaturedSectionKind kind;
  final List<ProductModel> products;
}
