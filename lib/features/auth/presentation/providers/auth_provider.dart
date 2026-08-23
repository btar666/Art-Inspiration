import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../data/auth_api_service.dart';
import '../../data/auth_storage.dart';
import '../../../notifications/data/notifications_storage.dart';
import '../../../home/data/products_repository.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/data/erp_party_resolver.dart';
import '../../data/models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    api: ref.watch(authApiServiceProvider),
    storage: ref.watch(authStorageProvider),
  );
});

/// مستودع المصادقة
class AuthRepository {
  AuthRepository({
    required AuthApiService api,
    required AuthStorage storage,
  })  : _api = api,
        _storage = storage;

  final AuthApiService _api;
  final AuthStorage _storage;

  bool get isLoggedIn => _storage.isLoggedIn;
  AuthUser? get currentUser => _storage.user;

  Future<AuthSession> login({
    required String identifier,
    required String password,
  }) async {
    final trimmed = identifier.trim();
    final isEmail = trimmed.contains('@');

    final session = await _api.login(
      email: isEmail ? trimmed : null,
      phone: isEmail ? null : trimmed,
      password: password,
    );

    await _storage.saveSession(session);
    return session;
  }

  Future<AuthSession> register({
    required String fullName,
    required String phone,
    required String password,
    required String shopName,
    required String governorate,
  }) async {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : firstName;
    final email = '${phone.replaceAll(RegExp(r'\D'), '')}@customer.art-inspiration.app';

    // طلب انضمام — لا نحفظ الجلسة حتى تتم الموافقة وتسجيل الدخول
    return _api.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone.trim(),
      password: password,
      shopName: shopName.trim(),
      governorate: governorate,
    );
  }

  Future<void> logout() => _storage.clear();
}

/// حالة المصادقة
class AuthState {
  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.user,
    this.errorMessage,
  });

  final bool isLoading;
  final bool isLoggedIn;
  final AuthUser? user;
  final String? errorMessage;

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    AuthUser? user,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final storage = ref.read(authStorageProvider);
    final user = storage.user;
    if (storage.isLoggedIn && user != null) {
      final userKey = user.notificationUserKey;
      if (userKey.isNotEmpty) {
        Future.microtask(
          () => ref
              .read(notificationsStorageProvider)
              .onUserSessionStarted(userKey),
        );
      }
      Future.microtask(syncPricePolicyFromErp);
    }
    return AuthState(
      isLoggedIn: storage.isLoggedIn,
      user: user,
    );
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<AuthUser?> _enrichUserFromErp(AuthUser? user) async {
    if (user == null) return null;
    try {
      final policy = await ref.read(erpPartyResolverProvider).fetchPricePolicy(
            phone: user.phone,
            name: user.name,
          );
      return user.copyWith(pricePolicy: policy);
    } catch (_) {
      return user;
    }
  }

  /// مزامنة `price_policy` من أمان ERP — تسجيل الدخول، بدء التطبيق، pull-to-refresh
  Future<void> syncPricePolicyFromErp() async {
    final current = state.user ?? ref.read(authStorageProvider).user;
    if (current == null || !state.isLoggedIn) return;

    try {
      final policy = await ref.read(erpPartyResolverProvider).fetchPricePolicy(
            phone: current.phone,
            name: current.name,
          );
      if (policy == current.pricePolicy) return;

      final updated = current.copyWith(pricePolicy: policy);
      await ref.read(authStorageProvider).saveUser(updated);
      ref.read(cartNotifierProvider.notifier).repriceForPolicy(policy);
      if (state.isLoggedIn) {
        state = state.copyWith(user: updated);
      }
    } catch (_) {}
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _repo.login(
        identifier: identifier,
        password: password,
      );
      var user = session.user ?? _repo.currentUser;
      user = await _enrichUserFromErp(user);
      if (user != null) {
        await ref.read(authStorageProvider).saveUser(user);
        ref
            .read(cartNotifierProvider.notifier)
            .repriceForPolicy(user.pricePolicy);
        final userKey = user.notificationUserKey;
        if (userKey.isNotEmpty) {
          await ref
              .read(notificationsStorageProvider)
              .onUserSessionStarted(userKey);
        }
      }
      state = AuthState(
        isLoggedIn: true,
        user: user,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ConnectivityService.connectionMessage,
      );
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String phone,
    required String password,
    required String shopName,
    required String governorate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repo.register(
        fullName: fullName,
        phone: phone,
        password: password,
        shopName: shopName,
        governorate: governorate,
      );
      state = const AuthState();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ConnectivityService.connectionMessage,
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    await ref.read(productsRepositoryProvider).clearCache();
    state = const AuthState();
  }

  Future<bool> updateProfile({
    required String name,
    required String phone,
    required String password,
    required String city,
    required String cosmeticName,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _enrichUserFromErp(
        await ref.read(authApiServiceProvider).updateProfile(
              name: name,
              phone: phone,
              password: password,
              city: city,
              cosmeticName: cosmeticName,
            ),
      );
      if (user == null) return false;
      await ref.read(authStorageProvider).saveUser(user);
      state = AuthState(isLoggedIn: true, user: user);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ConnectivityService.connectionMessage,
      );
      return false;
    }
  }

  Future<bool> refreshProfile() async {
    try {
      var user = await ref.read(authApiServiceProvider).fetchProfile();
      user = await _enrichUserFromErp(user) ?? user;
      await ref.read(authStorageProvider).saveUser(user);
      state = AuthState(isLoggedIn: true, user: user);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authApiServiceProvider).deleteAccount();
      await _repo.logout();
      await ref.read(productsRepositoryProvider).clearCache();
      state = const AuthState();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: ConnectivityService.connectionMessage,
      );
      return false;
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
