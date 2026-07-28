import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/auth_api_service.dart';
import '../../data/auth_storage.dart';
import '../../../home/data/products_repository.dart';
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
    return AuthState(
      isLoggedIn: storage.isLoggedIn,
      user: storage.user,
    );
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

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
      state = AuthState(
        isLoggedIn: true,
        user: session.user ?? _repo.currentUser,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر الاتصال بالخادم',
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
        errorMessage: 'تعذر الاتصال بالخادم',
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
      final user = await ref.read(authApiServiceProvider).updateProfile(
            name: name,
            phone: phone,
            password: password,
            city: city,
            cosmeticName: cosmeticName,
          );
      await ref.read(authStorageProvider).saveUser(user);
      state = AuthState(isLoggedIn: true, user: user);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر حفظ التعديلات',
      );
      return false;
    }
  }

  Future<bool> refreshProfile() async {
    try {
      final user = await ref.read(authApiServiceProvider).fetchProfile();
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
        errorMessage: 'تعذر حذف الحساب',
      );
      return false;
    }
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
