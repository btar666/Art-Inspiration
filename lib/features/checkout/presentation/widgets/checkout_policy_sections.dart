import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/whatsapp_link.dart';
import '../../../app_api/models/return_policy_item.dart';
import '../../../app_api/presentation/providers/app_api_providers.dart';
import '../../../orders/presentation/pages/order_details_page.dart';

/// سياسة الاسترجاع وضمان المنتجات — من api/return_policy مع احتياطي محلي
class CheckoutPolicySections extends ConsumerStatefulWidget {
  const CheckoutPolicySections({
    super.key,
    required this.acceptedFlags,
    required this.onAcceptedChanged,
  });

  final List<bool> acceptedFlags;
  final void Function(int index, bool value) onAcceptedChanged;

  @override
  ConsumerState<CheckoutPolicySections> createState() =>
      CheckoutPolicySectionsState();
}

class CheckoutPolicySectionsState extends ConsumerState<CheckoutPolicySections> {
  final Set<int> _expandedIndexes = {};

  /// يفتح الكروت غير الموافَق عليها لقراءة المحتوى
  void openPendingPolicies() {
    setState(() {
      for (var i = 0; i < widget.acceptedFlags.length; i++) {
        if (!widget.acceptedFlags[i]) {
          _expandedIndexes.add(i);
        }
      }
    });
  }

  Future<void> _openWhatsApp() async {
    try {
      final info = await ref.read(appInfoProvider.future);
      if (!mounted) return;

      final uri = WhatsAppLink.buildUri(
        info.whatsapp,
        fallbackPhone: info.phone,
      );
      if (uri == null) {
        _showSnack('تعذر فتح واتساب');
        return;
      }

      var launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched && mounted) {
        _showSnack('تعذر فتح واتساب');
      }
    } catch (_) {
      if (mounted) _showSnack('تعذر فتح واتساب');
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  List<_PolicySectionData> _resolveSections(List<ReturnPolicyItem>? apiItems) {
    if (apiItems != null && apiItems.isNotEmpty) {
      return [
        for (final item in apiItems)
          _PolicySectionData(
            title: item.title.isEmpty
                ? 'سياسة الاستبدال والاسترجاع'
                : item.title,
            acceptLabel: 'أقر بأنني قرأت «${item.title.isEmpty ? 'السياسة' : item.title}» وأوافق عليها',
            body: _ApiPolicyBody(details: item.details),
            showGuaranteeBadge: _looksLikeGuarantee(item.title),
          ),
      ];
    }

    return [
      _PolicySectionData(
        title: 'سياسة الاستبدال والاسترجاع',
        acceptLabel: 'أقر بأنني قرأت سياسة الاستبدال والاسترجاع وأوافق عليها',
        body: _ReturnPolicyBody(onWhatsAppTap: _openWhatsApp),
      ),
      const _PolicySectionData(
        title: 'ضمان المنتجات',
        acceptLabel: 'أقر بأنني قرأت ضمان المنتجات وأوافق عليه',
        body: _GuaranteePolicyBody(),
        showGuaranteeBadge: true,
      ),
    ];
  }

  bool _looksLikeGuarantee(String title) {
    final t = title.trim();
    return t.contains('ضمان') || t.toLowerCase().contains('guarantee');
  }

  @override
  Widget build(BuildContext context) {
    final policiesAsync = ref.watch(returnPoliciesProvider);

    return policiesAsync.when(
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => _buildSections(_resolveSections(null)),
      data: (items) => _buildSections(_resolveSections(items)),
    );
  }

  Widget _buildSections(List<_PolicySectionData> sections) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) SizedBox(height: 10.h),
          _PolicyTile(
            title: sections[i].title,
            expanded: _expandedIndexes.contains(i),
            accepted: i < widget.acceptedFlags.length
                ? widget.acceptedFlags[i]
                : false,
            onAcceptedChanged: (value) => widget.onAcceptedChanged(i, value),
            acceptLabel: sections[i].acceptLabel,
            onTap: () => setState(() {
              if (_expandedIndexes.contains(i)) {
                _expandedIndexes.remove(i);
              } else {
                _expandedIndexes.add(i);
              }
            }),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (sections[i].showGuaranteeBadge) ...[
                  Center(
                    child: Image.asset(
                      AppAssets.productGuaranteeBadge,
                      width: 88.w,
                      height: 88.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                sections[i].body,
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PolicySectionData {
  const _PolicySectionData({
    required this.title,
    required this.acceptLabel,
    required this.body,
    this.showGuaranteeBadge = false,
  });

  final String title;
  final String acceptLabel;
  final Widget body;
  final bool showGuaranteeBadge;
}

class _PolicyTile extends StatelessWidget {
  const _PolicyTile({
    required this.title,
    required this.expanded,
    required this.accepted,
    required this.onAcceptedChanged,
    required this.acceptLabel,
    required this.onTap,
    required this.child,
  });

  final String title;
  final bool expanded;
  final bool accepted;
  final ValueChanged<bool> onAcceptedChanged;
  final String acceptLabel;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: OrderDetailsPageMetrics.cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.ordersSectionTitle().copyWith(
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  child,
                  SizedBox(height: 14.h),
                  _PolicyAcceptRow(
                    value: accepted,
                    onChanged: onAcceptedChanged,
                    label: acceptLabel,
                  ),
                ],
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    );
  }
}

class _PolicyAcceptRow extends StatelessWidget {
  const _PolicyAcceptRow({
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppTextStyles.ordersDetailLabel().copyWith(
      fontSize: 12.sp,
      height: 1.5,
      color: const Color(0xFF3D3E46).withValues(alpha: 0.9),
      fontWeight: FontWeight.w600,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.homeDiscount.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.homeDiscount.withValues(alpha: 0.28),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              textDirection: TextDirection.rtl,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PolicyAcceptCheckbox(
                  value: value,
                  onChanged: onChanged,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    label,
                    style: labelStyle,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicyAcceptCheckbox extends StatelessWidget {
  const _PolicyAcceptCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.w,
      height: 40.w,
      child: Checkbox(
        value: value,
        onChanged: (checked) => onChanged(checked ?? false),
        activeColor: AppColors.primary,
        side: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.55),
          width: 1.4,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.r),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ApiPolicyBody extends StatelessWidget {
  const _ApiPolicyBody({required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
    final text = details.trim().isEmpty ? 'لا يوجد محتوى حالياً' : details;
    return Text(
      text,
      style: AppTextStyles.ordersDetailLabel().copyWith(
        fontSize: 12.5.sp,
        height: 1.65,
        color: const Color(0xFF3D3E46).withValues(alpha: 0.85),
      ),
      textAlign: TextAlign.right,
    );
  }
}

class _ReturnPolicyBody extends StatelessWidget {
  const _ReturnPolicyBody({required this.onWhatsAppTap});

  final VoidCallback onWhatsAppTap;

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppTextStyles.ordersDetailLabel().copyWith(
      fontSize: 12.5.sp,
      height: 1.65,
      color: const Color(0xFF3D3E46).withValues(alpha: 0.85),
    );
    final titleStyle = bodyStyle.copyWith(fontWeight: FontWeight.w700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'متى يمكنني استرجاع أو استبدال الطلب؟',
          style: titleStyle,
          textAlign: TextAlign.right,
        ),
        SizedBox(height: 10.h),
        _NumberedPoint(
          index: 1,
          text:
              'في حال استلام منتج غير مطابق للطلب، يجب إبلاغ فريق خدمة الزبائن خلال ٢٤ ساعة من وقت الاستلام.',
          style: bodyStyle,
        ),
        SizedBox(height: 8.h),
        _NumberedPoint(
          index: 2,
          text:
              'في حال وجود منتجات تالفة: يجب فحص الطلب أمام مندوب التوصيل وفي حال وجود منتجات تالفة يتم رفض الطلب والتواصل مع خدمة العملاء لإعادة إرسال الطلب من جديد. في حال استلام الطلب بدون فحص يسقط حق الزبون في المطالبة بتعويض.',
          style: bodyStyle,
        ),
        SizedBox(height: 8.h),
        _NumberedPoint(
          index: 3,
          text:
              'الرغبة في الاستبدال أو الاسترجاع بسبب خطأ في اختيار المنتجات من قبل الزبون، يتم تقديم طلب إلى خدمة العملاء خلال ٢٤ ساعة مع توضيح السبب ويتحمل العميل تكاليف الشحن المترتبة على عملية الإرجاع أو الاستبدال.',
          style: bodyStyle,
        ),
        SizedBox(height: 10.h),
        Text.rich(
          TextSpan(
            style: bodyStyle,
            children: [
              const TextSpan(
                text:
                    'ملاحظة: في حال وجود استفسارات أخرى يرجى التواصل مع فريق الدعم عبر الرابط المخصص للتواصل معنا (',
              ),
              TextSpan(
                text: 'اضغط هنا',
                style: bodyStyle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
                recognizer: TapGestureRecognizer()..onTap = onWhatsAppTap,
              ),
              const TextSpan(text: ')'),
            ],
          ),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}

class _GuaranteePolicyBody extends StatelessWidget {
  const _GuaranteePolicyBody();

  @override
  Widget build(BuildContext context) {
    return Text(
      'جميع المنتجات أصلية ومن مصادر موثوقة وشركة إلهام الفن تتحمل كامل المسؤولية '
      'في حال تبين وجود خلل في أي منتج من قبل فريق الدعم ويتم معالجة الخلل مباشرة '
      'وتعويض الزبون بمنتج أصلي وإرجاع كامل المبلغ المدفوع.',
      style: AppTextStyles.ordersDetailLabel().copyWith(
        fontSize: 12.5.sp,
        height: 1.65,
        color: const Color(0xFF3D3E46).withValues(alpha: 0.85),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _NumberedPoint extends StatelessWidget {
  const _NumberedPoint({
    required this.index,
    required this.text,
    required this.style,
  });

  final int index;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: style,
            textAlign: TextAlign.right,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          '$index.',
          style: style.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
