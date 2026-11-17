import 'package:flutter/material.dart';
import '../utils/constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status) {
      case AppConstants.statusInProgress:
        return AppColors.statusInProgress;
      case AppConstants.statusCompleted:
        return AppColors.statusCompleted;
      case AppConstants.statusTodo:
      default:
        return AppColors.statusTodo;
    }
  }

  Color _getBgColor() {
    switch (status) {
      case AppConstants.statusInProgress:
        return AppColors.statusInProgressBg;
      case AppConstants.statusCompleted:
        return AppColors.statusCompletedBg;
      case AppConstants.statusTodo:
      default:
        return AppColors.statusTodoBg;
    }
  }

  String _getLabel() {
    switch (status) {
      case AppConstants.statusInProgress:
        return 'Đang làm';
      case AppConstants.statusCompleted:
        return 'Hoàn thành';
      case AppConstants.statusTodo:
      default:
        return 'Chưa làm';
    }
  }

  IconData _getIcon() {
    switch (status) {
      case AppConstants.statusInProgress:
        return Icons.timelapse_rounded;
      case AppConstants.statusCompleted:
        return Icons.check_circle_rounded;
      case AppConstants.statusTodo:
      default:
        return Icons.radio_button_unchecked_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final bgColor = _getBgColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getIcon(), size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
