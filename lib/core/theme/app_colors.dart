import 'package:flutter/material.dart';

/// لوحة ألوان التطبيق — مستوحاة من التصميم
abstract final class AppColors {
  static const Color primary = Color(0xFF0014FF);
  static const Color primaryLight = Color(0xFFE8EBFF);
  static const Color primarySoft = Color(0xFFB8C4FF);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F7FF);

  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color cardPlaceholder = Color(0xFFE8D5C4);
  static const Color dotInactive = Color(0xFFB8C4FF);
  static const Color dotGrid = Color(0xFFD1D9F0);

  static const Color blobTop = Color(0xFFF0F3FF);
  static const Color blobBottom = Color(0xFFF5F7FF);

  static const Color skipButtonBg = Color(0xFFE8EBFF);

  // ── Home ──────────────────────────────────────────────────
  static const Color homeLavender = Color(0xFFE9E4F5);
  static const Color homePriceBar = Color(0xFFE8EBFF);
  static const Color homeDiscount = Color(0xFFE85D4A);
  static const Color homeRating = Color(0xFFFFB800);
  static const Color homeSectionTitle = Color(0xFF1B3D3A);
  static const Color homeChipBorder = Color(0xFFB8C4FF);
  static const Color homeBannerBg = Color(0xFFE8EBFF);
  static const Color homeNavInactive = Color(0xFF9AA8E8);
  static const Color homeHeart = Color(0xFF7B8FE8);
  static const Color notificationDot = Color(0xFFFF3B30);

  // ── Orders ────────────────────────────────────────────────
  static const Color orderLabel = Color(0x800000FF);
  static const Color orderCardBorder = Color(0xFFE8EBFF);
  static const Color orderStatusDeliveringBg = Color(0xFFFFF6D6);
  static const Color orderStatusDeliveringText = Color(0xFF1A1A2E);
  static const Color orderStatusDeliveredBg = Color(0xFFE5F8EC);
  static const Color orderStatusDeliveredText = Color(0xFF1A1A2E);
  static const Color orderStatusCancelledBg = Color(0xFFFFE8E8);
  static const Color orderStatusCancelledText = Color(0xFF1A1A2E);
  static const Color orderTotalPrice = Color(0xFFE85D4A);
  static const Color orderFreeDelivery = Color(0xFF22A45D);
  static const Color orderBackButton = Color(0xFFB8C4FF);
  static const Color orderDetailsFooter = Color(0xFFF0F3FF);
}
