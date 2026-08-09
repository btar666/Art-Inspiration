import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/search_filter_state.dart';

/// فلتر مطبّق من صفحة الفلترة — يتجاوز مشكلة عدم إرجاع `pop` بين navigators
final appliedSearchFilterProvider = StateProvider<SearchFilterState?>(
  (ref) => null,
);

/// نص بحث معلّق من الرئيسية (مثل الباركود) — يُستهلك عند فتح صفحة البحث
final pendingSearchQueryProvider = StateProvider<String?>(
  (ref) => null,
);
