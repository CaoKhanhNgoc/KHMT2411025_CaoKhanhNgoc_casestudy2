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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            _getLabel(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
