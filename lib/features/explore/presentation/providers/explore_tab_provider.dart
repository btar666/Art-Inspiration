import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/explore_models.dart';

/// التبويب الحالي في صفحة الاكسبلور
final exploreTabProvider = StateProvider<ExploreTab>((ref) => ExploreTab.general);
