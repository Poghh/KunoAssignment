import 'package:flutter/material.dart';

import '../constants/app_ui_constants.dart';

class AppIconContainer extends StatelessWidget {
  const AppIconContainer({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.size = AppContainerSize.iconLg,
    this.iconSize,
    this.radius = AppRadius.md,
    super.key,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final double size;
  final double? iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: iconColor, size: iconSize),
    );
  }
}
