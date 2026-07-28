import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/data/iraqi_governorates.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// ورقة سفلية لتعديل الملف الشخصي — api/customers/edit
class EditProfileBottomSheet extends ConsumerStatefulWidget {
  const EditProfileBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const EditProfileBottomSheet(),
    );
  }

  @override
  ConsumerState<EditProfileBottomSheet> createState() =>
      _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState
    extends ConsumerState<EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _shopController;
  late final TextEditingController _passwordController;
  String? _selectedCity;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _shopController = TextEditingController(text: user?.cosmeticName ?? '');
    _passwordController = TextEditingController();
    final city = user?.city?.trim() ?? '';
    if (city.isNotEmpty) {
      _selectedCity = IraqiGovernorates.all.contains(city)
          ? city
          : IraqiGovernorates.all.firstWhere(
              (g) => g.contains(city) || city.contains(g),
              orElse: () => city,
            );
      if (!IraqiGovernorates.all.contains(_selectedCity)) {
        _selectedCity = null;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _shopController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المحافظة')),
      );
      return;
    }

    setState(() => _saving = true);
    final ok = await ref.read(authNotifierProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          city: _selectedCity!,
          cosmeticName: _shopController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ التعديلات')),
      );
      return;
    }

    final error = ref.read(authNotifierProvider).errorMessage;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'تعذر حفظ التعديلات')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final cityItems = [
      ...IraqiGovernorates.all,
      if (_selectedCity != null &&
          !IraqiGovernorates.all.contains(_selectedCity))
        _selectedCity!,
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(
          20.w,
          12.h,
          20.w,
          24.h + safeBottom,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.dotGrid,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'تعديل معلوماتك',
                  style: AppTextStyles.settingsSectionTitle(),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 20.h),
                AppTextField(
                  hint: 'الاسم الكامل',
                  controller: _nameController,
                  icon: Icons.person_outline,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'أدخل الاسم' : null,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  hint: 'رقم الهاتف',
                  controller: _phoneController,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => (v == null || v.trim().length < 10)
                      ? 'أدخل رقم هاتف صحيح'
                      : null,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  hint: 'اسم الكوزمتك / المحل',
                  controller: _shopController,
                  icon: Icons.storefront_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'أدخل اسم المحل'
                      : null,
                ),
                SizedBox(height: 12.h),
                AppDropdownField<String>(
                  hint: 'المحافظة',
                  items: cityItems,
                  value: _selectedCity,
                  icon: Icons.map_outlined,
                  onChanged: (value) => setState(() => _selectedCity = value),
                  validator: (v) => v == null ? 'اختر المحافظة' : null,
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  hint: 'كلمة المرور (للتأكيد)',
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => (v == null || v.length < 5)
                      ? 'أدخل كلمة المرور'
                      : null,
                ),
                SizedBox(height: 24.h),
                AppButton(
                  label: _saving ? 'جاري الحفظ...' : 'حفظ التغييرات',
                  expanded: true,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
