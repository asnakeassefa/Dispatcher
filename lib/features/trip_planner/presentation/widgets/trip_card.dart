import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entity/trip.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback? onTap;

  const TripCard({
    super.key,
    required this.trip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor().withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getStatusColor().withOpacity(0.05),
                _getStatusColor().withOpacity(0.02),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Trip ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trip #${trip.id}',
                            style: AppTheme.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDate(trip.date),
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(context),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Trip Details Grid
                _buildDetailsGrid(context),
                
                const SizedBox(height: 16),
                
                // Progress Bar (for in-progress trips)
                if (trip.status == TripStatus.inProgress) ...[
                  _buildProgressBar(context),
                  const SizedBox(height: 12),
                ],
                
                // Action Indicator
                _buildActionIndicator(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsGrid(BuildContext context) {
    return Row(
      children: [
        // Vehicle Info
        Expanded(
          child: _buildDetailItem(
            icon: Ionicons.car_outline,
            label: 'Vehicle',
            value: trip.assignedVehicle?.plateNumber ?? 'Not assigned',
            color: _getStatusColor(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Orders Info
        Expanded(
          child: _buildDetailItem(
            icon: Ionicons.bag_outline,
            label: 'Orders',
            value: '${trip.totalOrders}',
            color: _getStatusColor(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Weight Info
        Expanded(
          child: _buildDetailItem(
            icon: Ionicons.scale_outline,
            label: 'Weight',
            value: '${trip.totalWeight.toStringAsFixed(1)} kg',
            color: _getStatusColor(),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    // This would need to be calculated based on actual progress
    // For now, we'll show a placeholder
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: AppTheme.labelMedium.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'In Progress',
              style: AppTheme.labelMedium.copyWith(
                color: _getStatusColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: 0.3, // This should be calculated from actual progress
          backgroundColor: _getStatusColor().withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildActionIndicator(BuildContext context) {
    String actionText;
    IconData actionIcon;
    Color actionColor = _getStatusColor();

    switch (trip.status) {
      case TripStatus.planned:
        actionText = 'Tap to start trip';
        actionIcon = Ionicons.play_circle_outline;
        break;
      case TripStatus.inProgress:
        actionText = 'Tap to continue';
        actionIcon = Ionicons.arrow_forward_circle_outline;
        break;
      case TripStatus.completed:
        actionText = 'Tap to view details';
        actionIcon = Ionicons.eye_outline;
        actionColor = AppTheme.textSecondary;
        break;
      case TripStatus.cancelled:
        actionText = 'Trip cancelled';
        actionIcon = Ionicons.close_circle_outline;
        actionColor = AppTheme.textSecondary;
        break;
    }

    return Row(
      children: [
        Icon(
          actionIcon,
          size: 16,
          color: actionColor,
        ),
        const SizedBox(width: 8),
        Text(
          actionText,
          style: AppTheme.bodySmall.copyWith(
            color: actionColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        // COD Amount
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Ionicons.cash_outline,
                size: 14,
                color: AppTheme.successColor,
              ),
              const SizedBox(width: 4),
              Text(
                '\$${trip.totalCodAmount.toStringAsFixed(0)}',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    final statusData = _getStatusData();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusData.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusData.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusData.icon,
            size: 14,
            color: statusData.color,
          ),
          const SizedBox(width: 6),
          Text(
            statusData.text,
            style: AppTheme.labelSmall.copyWith(
              color: statusData.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  StatusData _getStatusData() {
    switch (trip.status) {
      case TripStatus.planned:
        return StatusData(
          color: AppTheme.warningColor,
          text: 'Planned',
          icon: Ionicons.time_outline,
        );
      case TripStatus.inProgress:
        return StatusData(
          color: AppTheme.primaryColor,
          text: 'Active',
          icon: Ionicons.play_circle_outline,
        );
      case TripStatus.completed:
        return StatusData(
          color: AppTheme.successColor,
          text: 'Completed',
          icon: Ionicons.checkmark_circle_outline,
        );
      case TripStatus.cancelled:
        return StatusData(
          color: AppTheme.errorColor,
          text: 'Cancelled',
          icon: Ionicons.close_circle_outline,
        );
    }
  }

  Color _getStatusColor() {
    return _getStatusData().color;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(date.year, date.month, date.day);
    
    if (tripDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (tripDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatTime(date)}';
    } else if (tripDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, ${_formatTime(date)}';
    } else {
      return '${date.day}/${date.month}/${date.year}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class StatusData {
  final Color color;
  final String text;
  final IconData icon;

  StatusData({
    required this.color,
    required this.text,
    required this.icon,
  });
}

class TimezoneHelper {
  // Simple timezone offset mapping for common timezones
  static const Map<String, int> _timezoneOffsets = {
    'Asia/Dubai': 4,        // UTC+4
    'America/New_York': -5, // UTC-5 (EST) 
    'Europe/London': 0,     // UTC+0 (GMT)
    'Asia/Tokyo': 9,        // UTC+9
    'UTC': 0,               // UTC
  };

  // Convert UTC time to depot timezone
  static DateTime toDepotTime(DateTime utcTime, String depotTimezone) {
    final offset = _timezoneOffsets[depotTimezone] ?? 0;
    return utcTime.add(Duration(hours: offset));
  }

  // Convert local time to depot timezone (assuming input is UTC)
  static DateTime localToDepotTime(DateTime dateTime, String depotTimezone) {
    final utcTime = dateTime.toUtc();
    return toDepotTime(utcTime, depotTimezone);
  }

  // Check if date/time is in the past according to depot timezone
  static bool isPastInDepot(DateTime dateTime, String depotTimezone) {
    final now = DateTime.now().toUtc();
    final depotNow = toDepotTime(now, depotTimezone);
    final depotDateTime = toDepotTime(dateTime.toUtc(), depotTimezone);
    
    return depotDateTime.isBefore(depotNow);
  }

  // Format time for display in depot timezone
  static String formatDepotTime(DateTime dateTime, String depotTimezone) {
    final depotTime = toDepotTime(dateTime.toUtc(), depotTimezone);
    final hour = depotTime.hour.toString().padLeft(2, '0');
    final minute = depotTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Format date for display in depot timezone
  static String formatDepotDate(DateTime dateTime, String depotTimezone) {
    final depotTime = toDepotTime(dateTime.toUtc(), depotTimezone);
    final year = depotTime.year;
    final month = depotTime.month.toString().padLeft(2, '0');
    final day = depotTime.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  // Get depot timezone from JSON (cached)
  static String? _cachedDepotTimezone;
  
  static Future<String> getDepotTimezone() async {
    if (_cachedDepotTimezone != null) {
      return _cachedDepotTimezone!;
    }

    try {
      final String jsonString = await rootBundle.loadString('assets/data/dispatcher_data.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final Map<String, dynamic> meta = jsonData['meta'] as Map<String, dynamic>;
      
      _cachedDepotTimezone = meta['depotTimezone'] as String;
      return _cachedDepotTimezone!;
    } catch (e) {
      return 'UTC'; // Default fallback
    }
  }
}
