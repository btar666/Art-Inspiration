import 'package:flutter_riverpod/flutter_riverpod.dart';

/// يخفي زر السلة العائم أثناء اختفاء السبلاش حتى لا يظهر فوقها
final floatingCartSuppressedProvider = StateProvider<bool>((ref) => false);
