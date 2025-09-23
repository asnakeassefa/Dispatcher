import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../theme/app_theme.dart';
import '../../features/order/presentation/bloc/order_state.dart';
import '../../features/trip_planner/domain/entity/trip.dart';

class FilterChipButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? color;

  const FilterChipButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? chipColor 
              : chipColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected 
                ? chipColor 
                : chipColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: chipColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? Colors.white 
                    : chipColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTheme.labelMedium.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : chipColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Specialized filter chips for different contexts
class OrderFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final OrderFilterType type;

  const OrderFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    Color? color;

    switch (type) {
      case OrderFilterType.all:
        icon = Ionicons.grid_outline;
        color = AppTheme.primaryColor;
        break;
      case OrderFilterType.discounted:
        icon = Ionicons.pricetag_outline;
        color = AppTheme.successColor;
        break;
      case OrderFilterType.notDiscounted:
        icon = Ionicons.receipt_outline;
        color = AppTheme.warningColor;
        break;
    }

    return FilterChipButton(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      icon: icon,
      color: color,
    );
  }
}

class TripFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final TripStatus? status;

  const TripFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    IconData? icon;
    Color? color;

    switch (status) {
      case null: // All
        icon = Ionicons.grid_outline;
        color = AppTheme.primaryColor;
        break;
      case TripStatus.planned:
        icon = Ionicons.time_outline;
        color = AppTheme.warningColor;
        break;
      case TripStatus.inProgress:
        icon = Ionicons.play_circle_outline;
        color = AppTheme.primaryColor;
        break;
      case TripStatus.completed:
        icon = Ionicons.checkmark_circle_outline;
        color = AppTheme.successColor;
        break;
      case TripStatus.cancelled:
        icon = Ionicons.close_circle_outline;
        color = AppTheme.errorColor;
        break;
    }

    return FilterChipButton(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
      icon: icon,
      color: color,
    );
  }
}
