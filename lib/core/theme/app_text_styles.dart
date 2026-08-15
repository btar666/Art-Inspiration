import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_fonts.dart';

/// أنماط النصوص الموحدة
abstract final class AppTextStyles {
  static TextStyle get _base => AppFonts.base();

  // ── Splash ──────────────────────────────────────────────
  static TextStyle splashTitle({Color? color}) => _base.copyWith(
        fontSize: 22.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: color ?? AppColors.primary,
      );

  static TextStyle splashTagline({Color? color}) => _base.copyWith(
        fontSize: 9.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.8,
        color: color ?? AppColors.primary,
      );

  // ── Onboarding ──────────────────────────────────────────
  static TextStyle onboardingTitle({Color? color}) => _base.copyWith(
        fontSize: 26.sp,
        fontWeight: FontWeight.w800,
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle onboardingBody({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: color ?? AppColors.textSecondary,
      );

  // ── Buttons ─────────────────────────────────────────────
  static TextStyle buttonPrimary({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textOnPrimary,
      );

  static TextStyle buttonSecondary({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
      );

  // ── Bottom nav ────────────────────────────────────────────
  static TextStyle bottomNavLabel({Color? color}) => GoogleFonts.almarai(
        fontSize: 13.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
      );

  // ── Auth ──────────────────────────────────────────────────
  static TextStyle authTitle({Color? color}) => _base.copyWith(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle authSubtitle({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle authField({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle authLink({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
        decoration: TextDecoration.underline,
        decorationColor: color ?? AppColors.primary,
      );

  // ── Success ───────────────────────────────────────────────
  static TextStyle successTitle({Color? color}) => _base.copyWith(
        fontSize: 24.sp,
        fontWeight: FontWeight.w800,
        height: 1.4,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle successBody({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        height: 1.7,
        color: color ?? AppColors.textSecondary,
      );

  // ── Home ──────────────────────────────────────────────────
  static TextStyle homeLogoTitle({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
        color: color ?? AppColors.primary,
      );

  static TextStyle homeLogoSubtitle({Color? color}) => _base.copyWith(
        fontSize: 7.5.sp,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.3,
        color: color ?? AppColors.primary,
      );

  static TextStyle homeSectionTitle({Color? color}) => _base.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.homeSectionTitle,
      );

  static TextStyle homeProductName({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  /// اسم المنتج في كارت الصفحة الرئيسية
  static TextStyle homeProductCardName({Color? color}) => _base.copyWith(
        fontSize: 15.92.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle homeProductRating({Color? color}) => _base.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle homeProductCardCategory({Color? color}) => _base.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: color ?? const Color(0xFF0000FF).withValues(alpha: 0.5),
      );

  static TextStyle homeProductCardDescription({Color? color}) => _base.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle homeProductCardDiscount({Color? color}) => _base.copyWith(
        fontSize: 11.94.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? AppColors.textOnPrimary,
      );

  static TextStyle homeProductCardOutOfStock({Color? color, double? fontSize}) =>
      _base.copyWith(
        fontSize: fontSize ?? 11.94.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        color: color ?? AppColors.homeDiscount,
      );

  static TextStyle homeProductCardPrice({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: color ?? const Color(0xFF0000FF).withValues(alpha: 0.5),
      );

  static TextStyle homeProductCategory({Color? color}) => _base.copyWith(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.primarySoft,
      );

  static TextStyle homeProductDescription({Color? color}) => _base.copyWith(
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle homeProductPrice({Color? color}) => _base.copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
      );

  static TextStyle homeNavLabel({Color? color, FontWeight? weight}) =>
      _base.copyWith(
        fontSize: 10.sp,
        fontWeight: weight ?? FontWeight.w500,
        color: color ?? AppColors.homeNavInactive,
      );

  // ── Product Details ───────────────────────────────────────
  static TextStyle _productDetailsContent({Color? color}) => _base.copyWith(
        fontSize: 15.96.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        color: color ?? const Color(0xFF000000),
      );

  static TextStyle productDetailsAppBarTitle({Color? color}) => _base.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.homeSectionTitle,
      );

  static TextStyle productDetailsName({Color? color}) =>
      _productDetailsContent(color: color);

  static TextStyle productDetailsSectionTitle({Color? color}) =>
      _productDetailsContent(color: color);

  static TextStyle productDetailsBody({Color? color}) => _base.copyWith(
        fontSize: 13.96.sp,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0,
        color: color ?? const Color(0xFF000000).withValues(alpha: 0.58),
      );

  static TextStyle productDetailsMeta({Color? color}) =>
      _productDetailsContent(color: color);

  static TextStyle productDetailsMetaValue({Color? color}) =>
      productDetailsBody(color: color);

  static TextStyle productDetailsPrice({Color? color}) => _base.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
      );

  static TextStyle productDetailsQuantity({Color? color}) => _base.copyWith(
        fontSize: 19.sp,
        fontWeight: FontWeight.w800,
        height: 1.1,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle productDetailsAddToCart({Color? color}) => _base.copyWith(
        fontSize: 15.96.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? AppColors.primary,
      );

  static TextStyle productDetailsRating({Color? color}) => _base.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  // ── Orders ────────────────────────────────────────────────
  static TextStyle ordersPageTitle({Color? color}) => _base.copyWith(
        fontSize: 22.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle ordersCardTitle({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle ordersCardSubtitle({Color? color}) => _base.copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.orderLabel,
      );

  static TextStyle ordersCardPrice({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle ordersStatusBadge({Color? color}) => _base.copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle ordersDetailLabel({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.orderLabel,
      );

  static TextStyle ordersDetailValue({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle ordersSectionTitle({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle ordersItemPrice({Color? color}) => _base.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.primary,
      );

  // ── Explore ───────────────────────────────────────────────
  static TextStyle exploreTabLabel({Color? color, FontWeight? weight}) =>
      _base.copyWith(
        fontSize: 16.sp,
        fontWeight: weight ?? AppFonts.bold,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? const Color(0xFF000000),
      );

  static TextStyle exploreBrandLogo({Color? color}) => _base.copyWith(
        fontSize: 22.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle exploreBrandLabel({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle exploreSectionLabel({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: color ?? AppColors.homeSectionTitle,
      );

  // ── Notifications ─────────────────────────────────────────
  static TextStyle notificationGroupTitle({Color? color}) => GoogleFonts.almarai(
        fontSize: 15.96.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? const Color(0xFF022B2F).withValues(alpha: 0.6),
      );

  static TextStyle notificationTitle({Color? color}) => _base.copyWith(
        fontSize: 13.96.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? const Color(0xFF040814),
      );

  static TextStyle notificationBody({Color? color}) => _base.copyWith(
        fontSize: 11.97.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? const Color(0xFF040814),
      );

  static TextStyle notificationTime({Color? color}) => GoogleFonts.almarai(
        fontSize: 11.97.sp,
        fontWeight: FontWeight.w700,
        height: 1.5,
        letterSpacing: 0,
        color: color ?? const Color(0xFF040814),
      );

  // ── Search ──────────────────────────────────────────────
  static TextStyle searchCancel({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.homeSectionTitle,
      );

  static TextStyle searchSectionTitle({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.homeSectionTitle,
      );

  static TextStyle searchHistoryItem({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle searchEmptyState({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle searchFilterLabel({Color? color}) => _base.copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle searchFilterChip({Color? color}) => _base.copyWith(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.primary,
      );

  static TextStyle searchFilterValue({Color? color}) => _base.copyWith(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  // ── Settings ──────────────────────────────────────────────
  static TextStyle settingsProfileName({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle settingsSectionTitle({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle settingsMenuItem({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  // ── Cart ──────────────────────────────────────────────────
  static TextStyle cartSectionTitle({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.homeSectionTitle,
      );

  static TextStyle cartItemName({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle cartItemPrice({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle cartQuantity({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle cartPriceLabel({Color? color, FontWeight? weight}) =>
      _base.copyWith(
        fontSize: 14.sp,
        fontWeight: weight ?? FontWeight.w600,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle cartPriceValue({Color? color, FontWeight? weight}) =>
      _base.copyWith(
        fontSize: 14.sp,
        fontWeight: weight ?? FontWeight.w700,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle cartCheckoutButton({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.primary,
      );

  static TextStyle cartBadgeCount({Color? color}) => _base.copyWith(
        fontSize: 9.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textOnPrimary,
        height: 1,
      );

  static TextStyle cartEmptyMessage({Color? color}) => _base.copyWith(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.textSecondary,
      );

  // ── Checkout ──────────────────────────────────────────────
  static TextStyle checkoutSectionTitle({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle checkoutLink({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.primary,
      );

  static TextStyle checkoutSuccessTitle({Color? color}) => _base.copyWith(
        fontSize: 20.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.textPrimary,
      );

  static TextStyle cartDialogTitle({Color? color}) => _base.copyWith(
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        color: color ?? AppColors.homeDiscount,
      );

  static TextStyle cartDialogBody({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );

  static TextStyle cartDialogConfirm({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.background,
      );

  static TextStyle cartDialogCancel({Color? color}) => _base.copyWith(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.homeDiscount,
      );
}
