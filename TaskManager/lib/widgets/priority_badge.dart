import 'package:flutter/material.dart';
import '../utils/constants.dart';

class PriorityBadge extends StatelessWidget {
  final String priority;

  const PriorityBadge({super.key, required this.priority});

  Color _getColor() {
    switch (priority) {
      case AppConstants.priorityHigh:
        return AppColors.priorityHigh;
      case AppConstants.priorityMedium:
        return AppColors.priorityMedium;
      case AppConstants.priorityLow:
      default:
        return AppColors.priorityLow;
    }
  }

  Color _getBgColor() {
    switch (priority) {
      case AppConstants.priorityHigh:
        return AppColors.priorityHighBg;
      case AppConstants.priorityMedium:
        return AppColors.priorityMediumBg;
      case AppConstants.priorityLow:
      default:
        return AppColors.priorityLowBg;
    }
  }

  String _getLabel() {
    switch (priority) {
      case AppConstants.priorityHigh:
        return 'Ưu tiên Cao';
      case AppConstants.priorityMedium:
        return 'Ưu tiên Vừa';
      case AppConstants.priorityLow:
      default:
        return 'Ưu tiên Thấp';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final bgColor = _getBgColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}
