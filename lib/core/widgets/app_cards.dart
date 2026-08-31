import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    this.onTap,
    this.color,
    this.padding,
    this.borderColor,
    this.borderRadius,
    required this.child,
    super.key,
  });

  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final double? borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cardColor =
        color ?? Theme.of(context).cardTheme.color ?? AppColors.surface;
    final radius = borderRadius ?? 16.0;
    final border = borderColor ?? Theme.of(context).colorScheme.outline;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
