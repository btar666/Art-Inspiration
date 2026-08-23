import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';

/// تلميح بحث: «بحث عن» ثابت + اسم قسم يُكتب حرفاً حرفاً من اليمين لليسار
class SearchHintTypewriter extends StatefulWidget {
  const SearchHintTypewriter({
    super.key,
    required this.term,
    required this.style,
    this.prefix = 'بحث عن',
  });

  final String term;
  final TextStyle style;
  final String prefix;

  @override
  State<SearchHintTypewriter> createState() => _SearchHintTypewriterState();
}

class _SearchHintTypewriterState extends State<SearchHintTypewriter>
    with SingleTickerProviderStateMixin {
  static const _typeInterval = Duration(milliseconds: 55);

  Timer? _typeTimer;
  late final AnimationController _caret;
  var _visibleChars = 0;

  Characters get _termChars => widget.term.characters;

  String get _visibleTerm => _termChars.take(_visibleChars).toString();

  @override
  void initState() {
    super.initState();
    _caret = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat(reverse: true);
    _startTyping();
  }

  @override
  void didUpdateWidget(covariant SearchHintTypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.term != widget.term) {
      _startTyping();
    }
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _caret.dispose();
    super.dispose();
  }

  void _startTyping() {
    _typeTimer?.cancel();
    _visibleChars = 0;
    if (mounted) setState(() {});

    final total = _termChars.length;
    if (total == 0) return;

    _typeTimer = Timer.periodic(_typeInterval, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_visibleChars >= total) {
        timer.cancel();
        return;
      }
      setState(() => _visibleChars += 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final typing = _visibleChars < _termChars.length;
    final lineStyle = widget.style.copyWith(height: 1);

    return Text.rich(
      TextSpan(
        style: lineStyle,
        children: [
          TextSpan(text: '${widget.prefix} '),
          TextSpan(text: _visibleTerm),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: FadeTransition(
              opacity: typing ? const AlwaysStoppedAnimation(1) : _caret,
              child: Container(
                width: 1.6.w,
                height: (lineStyle.fontSize ?? 16.sp) * 0.85,
                margin: EdgeInsetsDirectional.only(start: 3.w),
                decoration: BoxDecoration(
                  color: lineStyle.color ?? AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            ),
          ),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
    );
  }
}
