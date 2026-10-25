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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
