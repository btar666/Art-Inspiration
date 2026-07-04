import '../../home/data/home_mock_data.dart';
import 'models/cart_item_model.dart';

/// بيانات تجريبية للسلة
abstract final class CartMockData {
  static List<CartItemModel> initialItems() => [
        CartItemModel(product: HomeMockData.products[0], quantity: 2),
        CartItemModel(product: HomeMockData.products[1], quantity: 2),
        CartItemModel(product: HomeMockData.products[2], quantity: 2),
      ];

  static const deliveryPrice = 0;
}
