import 'dart:convert';
import 'package:flutter/services.dart';

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
