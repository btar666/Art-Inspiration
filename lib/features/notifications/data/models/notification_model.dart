import 'package:flutter/material.dart';

/// مجموعة الإشعارات حسب التاريخ
enum NotificationGroup {
  today('اليوم'),
  yesterday('أمس');

  const NotificationGroup(this.label);

  final String label;
}

/// نموذج إشعار
class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.group,
    required this.title,
    required this.description,
    required this.timeLabel,
    required this.icon,
    this.isHighlighted = false,
  });

  final String id;
  final NotificationGroup group;
  final String title;
  final String description;
  final String timeLabel;
  final IconData icon;
  final bool isHighlighted;
}
