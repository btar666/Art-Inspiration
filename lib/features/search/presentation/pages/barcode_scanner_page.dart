import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_back_button.dart';
import '../../../../shared/widgets/product_details_widget.dart';
import '../../../home/data/products_repository.dart';
import '../widgets/product_not_found_dialog.dart';

/// صفحة مسح باركود المنتج بالكاميرا
class BarcodeScannerPage extends ConsumerStatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  ConsumerState<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends ConsumerState<BarcodeScannerPage> {
  late final MobileScannerController _controller;

  bool _isProcessing = false;
  bool _torchOn = false;
  String? _scannerError;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _safeStopController();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _safeStopController() async {
    try {
      await _controller.stop();
    } on MissingPluginException {
      // يحدث إذا لم يُعاد بناء التطبيق بعد إضافة mobile_scanner
    } on PlatformException {
      // تجاهل أخطاء الإيقاف عند إغلاق الصفحة
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing || _scannerError != null) return;

    final value = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim())
        .whereType<String>()
        .firstWhere(
          (code) => code.isNotEmpty,
          orElse: () => '',
        );

    if (value.isEmpty) return;

    setState(() => _isProcessing = true);

    try {
      final product = await ref
          .read(productsRepositoryProvider)
          .findProductByBarcode(value);

      if (!mounted) return;

      if (product != null) {
        await _safeStopController();
        if (!mounted) return;
        if (context.canPop()) context.pop();
        ProductDetailsWidget.open(context, product);
        return;
      }

      if (!mounted) return;
      await ProductNotFoundDialog.show(context);
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      if (!mounted) return;
      setState(() => _torchOn = !_torchOn);
    } on MissingPluginException {
      if (!mounted) return;
      setState(() => _scannerError = _pluginRebuildMessage);
    }
  }

  static const _pluginRebuildMessage =
      'يرجى إيقاف التطبيق ثم تشغيله من جديد (وليس Hot Restart) '
      'بعد إضافة ميزة الكاميرا.';

  Widget _buildScannerError(String message) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_scanner_rounded,
                color: AppColors.background,
                size: 56.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'تعذّر تشغيل الكاميرا',
                style: AppTextStyles.ordersPageTitle(
                  color: AppColors.background,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                style: AppTextStyles.settingsMenuItem(
                  color: AppColors.background.withValues(alpha: 0.85),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final scannerError = _scannerError;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (scannerError != null)
            _buildScannerError(scannerError)
          else
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error) {
                final message = error.errorCode ==
                        MobileScannerErrorCode.permissionDenied
                    ? 'يرجى السماح للتطبيق باستخدام الكاميرا من الإعدادات'
                    : error.errorDetails?.message ?? 'تعذّر تشغيل الكاميرا';
                return _buildScannerError(message);
              },
            ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      AppBackButton(onTap: () => context.pop()),
                      Expanded(
                        child: Text(
                          'مسح الباركود',
                          style: AppTextStyles.ordersPageTitle(
                            color: AppColors.background,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(width: AppBackButtonMetrics.width()),
                    ],
                  ),
                ),
                if (scannerError == null) ...[
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'وجّه الكاميرا نحو باركود المنتج',
                      style: AppTextStyles.settingsMenuItem(
                        color: AppColors.background,
                      ).copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  const _ScanFrame(),
                  SizedBox(height: 32.h + topInset),
                ],
              ],
            ),
          ),
          if (_isProcessing)
            const ColoredBox(
              color: Color(0x66000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (scannerError == null)
            Positioned(
              left: 24.w,
              bottom: 24.h + MediaQuery.paddingOf(context).bottom,
              child: IconButton.filled(
                onPressed: _toggleTorch,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.45),
                  foregroundColor: AppColors.background,
                ),
                icon: Icon(
                  _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: AppColors.background.withValues(alpha: 0.9),
            width: 2,
          ),
        ),
      ),
    );
  }
}
