import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_dropdown_field.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/form_error_animator.dart';
import '../../../auth/data/iraqi_governorates.dart';
import '../../data/models/delivery_address_model.dart';

/// ورقة سفلية لإضافة أو تعديل عنوان توصيل
class AddressFormBottomSheet extends StatefulWidget {
  const AddressFormBottomSheet._({
    required this.title,
    this.initialGovernorate,
    this.initialArea = '',
    this.initialLandmark = '',
    this.isDialog = false,
  });

  final String title;
  final String? initialGovernorate;
  final String initialArea;
  final String initialLandmark;
  final bool isDialog;

  static Future<AddressFormResult?> showAdd(BuildContext context) {
    return showModalBottomSheet<AddressFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddressFormBottomSheet._(title: 'أضافة عنوان'),
    );
  }

  static Future<AddressFormResult?> showAddDialog(BuildContext context) {
    return showDialog<AddressFormResult>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      useRootNavigator: true,
      builder: (_) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: const AddressFormBottomSheet._(
          title: 'أضافة عنوان جديد',
          isDialog: true,
        ),
      ),
    );
  }

  static Future<AddressFormResult?> showEdit(
    BuildContext context, {
    required String governorate,
    required String area,
    required String landmark,
    double lat = 0,
    double lng = 0,
  }) {
    return showModalBottomSheet<AddressFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddressFormBottomSheet._(
        title: 'تعديل العنوان',
        initialGovernorate: governorate,
        initialArea: area,
        initialLandmark: landmark,
      ),
    );
  }

  static Future<AddressFormResult?> showEditDialog(
    BuildContext context, {
    required String governorate,
    required String area,
    required String landmark,
    double lat = 0,
    double lng = 0,
  }) {
    return showDialog<AddressFormResult>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      useRootNavigator: true,
      builder: (_) => Dialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: AddressFormBottomSheet._(
          title: 'تعديل العنوان',
          initialGovernorate: governorate,
          initialArea: area,
          initialLandmark: landmark,
          isDialog: true,
        ),
      ),
    );
  }

  @override
  State<AddressFormBottomSheet> createState() => _AddressFormBottomSheetState();
}

class _AddressFormBottomSheetState extends State<AddressFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _areaController;
  late final TextEditingController _landmarkController;
  String? _selectedGovernorate;
  int _governorateShakeTick = 0;
  int _areaShakeTick = 0;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGovernorate?.trim();
    if (initial != null &&
        initial.isNotEmpty &&
        IraqiGovernorates.all.contains(initial)) {
      _selectedGovernorate = initial;
    }
    _areaController = TextEditingController(text: widget.initialArea);
    _landmarkController = TextEditingController(text: widget.initialLandmark);
  }

  @override
  void dispose() {
    _areaController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  bool _isGovernorateInvalid() => _selectedGovernorate == null;

  bool _isAreaInvalid() => _areaController.text.trim().isEmpty;

  void _submit() {
    _formKey.currentState!.validate();

    final governorateInvalid = _isGovernorateInvalid();
    final areaInvalid = _isAreaInvalid();
    if (governorateInvalid || areaInvalid) {
      setState(() {
        if (governorateInvalid) _governorateShakeTick++;
        if (areaInvalid) _areaShakeTick++;
      });
      return;
    }

    Navigator.of(context).pop(
      AddressFormResult(
        governorate: _selectedGovernorate!,
        area: _areaController.text.trim(),
        landmark: _landmarkController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = widget.isDialog ? 0.0 : MediaQuery.viewInsetsOf(context).bottom;

    final form = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.isDialog) ...[
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
          ] else
            SizedBox(height: 24.h),
          Text(
            widget.title,
            style: AppTextStyles.settingsSectionTitle(),
            textAlign: TextAlign.right,
          ),
          SizedBox(height: 20.h),
          FormErrorAnimator(
            tick: _governorateShakeTick,
            child: AppDropdownField<String>(
              hint: 'المحافظة',
              icon: Icons.map_outlined,
              value: _selectedGovernorate,
              items: IraqiGovernorates.all,
              onChanged: (value) =>
                  setState(() => _selectedGovernorate = value),
              validator: (value) =>
                  _isGovernorateInvalid() ? 'اختر المحافظة' : null,
            ),
          ),
          SizedBox(height: 12.h),
          FormErrorAnimator(
            tick: _areaShakeTick,
            child: AppTextField(
              hint: 'المنطقة',
              controller: _areaController,
              icon: Icons.location_city_outlined,
              validator: (value) => _isAreaInvalid() ? 'أدخل المنطقة' : null,
            ),
          ),
          SizedBox(height: 12.h),
          AppTextField(
            hint: 'أقرب نقطة دالة (اختياري)',
            controller: _landmarkController,
            icon: Icons.place_outlined,
          ),
          SizedBox(height: 24.h),
          AppButton(
            label: 'حفظ العنوان',
            expanded: true,
            onPressed: _submit,
          ),
          if (widget.isDialog) SizedBox(height: 24.h),
        ],
      ),
    );

    if (widget.isDialog) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
        child: form,
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
        child: form,
      ),
    );
  }
}
