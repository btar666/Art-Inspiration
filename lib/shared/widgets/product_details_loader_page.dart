import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../features/home/data/models/product_model.dart';
import '../../features/home/data/products_repository.dart';
import 'product_details_widget.dart';

/// يحمّل المنتج بالمعرف ثم يعرض صفحة التفاصيل — للفتح من الإشعار
class ProductDetailsLoaderPage extends ConsumerStatefulWidget {
  const ProductDetailsLoaderPage({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailsLoaderPage> createState() =>
      _ProductDetailsLoaderPageState();
}

class _ProductDetailsLoaderPageState
    extends ConsumerState<ProductDetailsLoaderPage> {
  late final Future<ProductModel?> _future;

  @override
  void initState() {
    super.initState();
    _future =
        ref.read(productsRepositoryProvider).fetchProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final product = snapshot.data;
        if (product == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('تعذر فتح المنتج'),
              ),
            ),
          );
        }

        return ProductDetailsWidget(product: product);
      },
    );
  }
}
