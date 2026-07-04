import '../../../home/data/models/product_model.dart';

/// عنصر في السلة
class CartItemModel {
  CartItemModel({
    required this.product,
    this.quantity = 1,
  });

  final ProductModel product;
  int quantity;

  int get lineTotal => product.price * quantity;

  CartItemModel copyWith({ProductModel? product, int? quantity}) =>
      CartItemModel(
        product: product ?? this.product,
        quantity: quantity ?? this.quantity,
      );

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
        product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
        quantity: json['quantity'] as int? ?? 1,
      );
}
