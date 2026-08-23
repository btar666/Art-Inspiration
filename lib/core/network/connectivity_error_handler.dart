import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_exception.dart';
import 'connectivity_service.dart';
import '../../shared/widgets/connectivity_error_dialog.dart';

/// معالجة موحّدة لأخطاء السيرفر/الشبكة
abstract final class ConnectivityErrorHandler {
  static bool shouldShow(Object? error) {
    if (error == null) return false;
    if (error is ApiException) return error.isConnectivityOrServerError;
    return true;
  }

  static bool shouldShowMessage(String? message) {
    if (message == null || message.trim().isEmpty) return false;
    if (message == ConnectivityService.connectionMessage) return true;

    final normalized = message.trim();
    const serverPatterns = [
      'تعذر الاتصال',
      'فشل الاتصال',
      'انتهت مهلة',
      'تحقق من اتصال',
      'تعذر جلب',
      'تعذر تأكيد',
      'تعذر حفظ',
      'تعذر حذف',
      'تعذر المتابعة',
      'SocketException',
      'NetworkException',
    ];

    return serverPatterns.any(normalized.contains);
  }

  /// يعرض الدايلوج ويعيد المحاولة حتى ينجح الاتصال أو يُلغى
  static Future<void> promptRetry({
    required BuildContext context,
    required WidgetRef ref,
    required Future<void> Function() onRetry,
  }) async {
    while (context.mounted) {
      if (await ref.read(connectivityServiceProvider).isAppReachable()) {
        await onRetry();
        return;
      }

      final retry = await ConnectivityErrorDialog.show(
        context,
        barrierDismissible: false,
      );
      if (!retry || !context.mounted) return;
    }
  }

  static Future<void> promptRetryForMessage({
    required BuildContext context,
    required WidgetRef ref,
    required Future<void> Function() onRetry,
    required String? message,
  }) async {
    if (!shouldShowMessage(message)) return;
    await promptRetry(context: context, ref: ref, onRetry: onRetry);
  }
}

/// يعرض دايلوج الاتصال تلقائياً عند خطأ سيرفر/شبكة
class ConnectivityErrorGate extends ConsumerStatefulWidget {
  const ConnectivityErrorGate({
    super.key,
    required this.error,
    required this.onRetry,
    required this.child,
  });

  final Object? error;
  final Future<void> Function() onRetry;
  final Widget child;

  @override
  ConsumerState<ConnectivityErrorGate> createState() =>
      _ConnectivityErrorGateState();
}

class _ConnectivityErrorGateState extends ConsumerState<ConnectivityErrorGate> {
  bool _dialogShowing = false;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDialog());
  }

  @override
  void didUpdateWidget(covariant ConnectivityErrorGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.error != oldWidget.error) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowDialog());
    }
  }

  Future<void> _maybeShowDialog() async {
    final error = widget.error;
    if (_dialogShowing || error == null) return;
    if (!ConnectivityErrorHandler.shouldShow(error)) return;
    if (identical(error, _lastError)) return;

    _dialogShowing = true;
    _lastError = error;

    await ConnectivityErrorHandler.promptRetry(
      context: context,
      ref: ref,
      onRetry: widget.onRetry,
    );

    if (mounted) {
      _dialogShowing = false;
      _lastError = null;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
