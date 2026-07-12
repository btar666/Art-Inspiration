/// يمنع عدة طلبات refreshToken متزامنة
class TokenRefreshCoordinator {
  Future<dynamic>? _pending;

  Future<T> run<T>(Future<T> Function() action) async {
    if (_pending != null) {
      return await _pending! as T;
    }

    final future = action();
    _pending = future;
    try {
      return await future;
    } finally {
      _pending = null;
    }
  }
}
