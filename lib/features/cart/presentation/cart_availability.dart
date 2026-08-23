import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/models/erp_price_policy.dart';
import '../../home/data/models/product_model.dart';
import '../../home/data/products_repository.dart';
import '../../home/presentation/providers/user_price_policy_provider.dart';
import '../../orders/data/models/order_model.dart';
import '../data/models/cart_item_model.dart';

/// مشكلة توفر منتج قبل إتمام الشراء
class CartAvailabilityIssue {
  const CartAvailabilityIssue({
    required this.productName,
    required this.message,
  });

  final String productName;
  final String message;
}

/// مراجعة المخزون والكميات قبل تأكيد الطلب — من بيانات المنتج في السلة (مثل الرئيسية)
Future<List<CartAvailabilityIssue>> findCheckoutAvailabilityIssues(
  Iterable<CartItemModel> items,
) async {
  final issues = <CartAvailabilityIssue>[];

  for (final item in items) {
    final productId = int.tryParse(item.product.id.trim());
    if (productId == null) {
      issues.add(
        CartAvailabilityIssue(
          productName: item.product.name,
          message: 'معرّف المنتج غير صالح',
        ),
      );
      continue;
    }

    final product = item.product;
    if (!product.isInStock) {
      issues.add(
        CartAvailabilityIssue(
          productName: item.product.name,
          message: 'المنتج نافذ من المخزون',
        ),
      );
      continue;
    }

    final max = product.maxOrderQuantity;
    if (max != null && item.quantity > max) {
      issues.add(
        CartAvailabilityIssue(
          productName: item.product.name,
          message: 'الكمية المتوفرة $max فقط',
        ),
      );
    }
  }

  return issues;
}

String formatCheckoutAvailabilityMessage(List<CartAvailabilityIssue> issues) {
  if (issues.isEmpty) return '';

  final first = issues.first;
  if (issues.length == 1) {
    return '${first.productName}: ${first.message}';
  }

  return '${first.productName}: ${first.message} (و${issues.length - 1} منتجات أخرى)';
}

/// هل تحتوي السلة على منتجات نافذة؟
bool cartContainsOutOfStock(Iterable<CartItemModel> items) {
  return items.any((item) => !item.product.isInStock);
}

/// ضبط كمية إعادة الطلب حسب المخزون المتاح
int clampReorderQuantity(ProductModel product, int requested) {
  final safeRequested = requested.clamp(1, 999999);
  if (!product.isInStock) return safeRequested;

  final max = product.maxOrderQuantity;
  if (max == null || max < 1) return safeRequested;
  return safeRequested.clamp(1, max);
}

/// تحويل بنود الطلب إلى عناصر سلة — مخزون من كتالوج الكاش مثل الصفحة الرئيسية
Future<List<CartItemModel>> resolveReorderCartItems(
  WidgetRef ref,
  OrderDetailModel order,
) async {
  final repo = ref.read(productsRepositoryProvider);
  final policy = ref.read(userPricePolicyProvider);
  final items = <CartItemModel>[];

  for (final line in order.items) {
    final product = await _resolveReorderProduct(repo, line, policy);
    final quantity = clampReorderQuantity(product, line.quantity);
    items.add(CartItemModel(product: product, quantity: quantity));
  }

  return items;
}

Future<ProductModel> _resolveReorderProduct(
  ProductsRepository repo,
  OrderLineItem line,
  ErpPricePolicy policy,
) async {
  final id = line.productId?.trim();
  if (id != null && id.isNotEmpty) {
    try {
      final fetched = await repo.fetchProductById(id);
      if (fetched != null) {
        var product = fetched.withPriceFor(policy);
        final imageUrl = product.imageUrl?.trim() ?? '';
        final lineImage = line.imageUrl?.trim() ?? '';
        if (imageUrl.isEmpty && lineImage.isNotEmpty) {
          product = ProductModel(
            id: product.id,
            name: product.name,
            categoryName: product.categoryName,
            description: product.description,
            price: product.price,
            priceRetail: product.priceRetail,
            priceHalfWholesale: product.priceHalfWholesale,
            priceWholesale: product.priceWholesale,
            rating: product.rating,
            discountPercent: product.discountPercent,
            imageUrl: lineImage,
            imageBgColor: line.imageBgColor,
            brandName: product.brandName,
            expiryDate: product.expiryDate,
            origin: product.origin,
            galleryImageUrls: product.galleryImageUrls,
            categoryIds: product.categoryIds,
            stockQuantity: product.stockQuantity,
            trackStock: product.trackStock,
            sku: product.sku,
            barcode: product.barcode,
            isActive: product.isActive,
          );
        }
        return product;
      }
    } catch (_) {
      // نستخدم بيانات الطلب عند فشل الجلب
    }
  }

  return orderLineItemToProduct(line);
}

/// تحويل عنصر طلب إلى منتج للسلة (بدون مخزون محدث — مثل الرئيسية عند غياب الكاش)
ProductModel orderLineItemToProduct(OrderLineItem item) {
  return ProductModel(
    id: item.productId ?? 'reorder-${item.productName.hashCode}',
    name: item.productName,
    categoryName: '',
    description: '',
    price: item.price,
    rating: 0,
    imageUrl: item.imageUrl,
    imageBgColor: item.imageBgColor,
  );
}
