import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connectivity_error_handler.dart';
import '../../features/home/data/models/product_model.dart';
import '../../features/home/data/products_repository.dart';
import 'product_details_widget.dart';
import 'skeleton/product_details_skeleton.dart';

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
  late Future<ProductModel?> _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future =
          ref.read(productsRepositoryProvider).fetchProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProductModel?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ProductDetailsSkeleton();
        }

        if (snapshot.hasError) {
          return ConnectivityErrorGate(
            error: snapshot.error,
            onRetry: () async => _reload(),
            child: const ProductDetailsSkeleton(),
          );
        }

        final product = snapshot.data;
        if (product == null) {
          return ConnectivityErrorGate(
            error: Exception('product_not_found'),
            onRetry: () async => _reload(),
            child: const ProductDetailsSkeleton(),
          );
        }

        return ProductDetailsWidget(product: product);
      },
    );
  }
}
