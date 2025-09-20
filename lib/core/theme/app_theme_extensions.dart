import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom theme extensions for additional styling
class AppThemeExtensions extends ThemeExtension<AppThemeExtensions> {
  final Color successColor;
  final Color warningColor;
  final Color infoColor;
  final Color surfaceVariant;
  final Color onSurfaceVariant;
  final BorderRadius borderRadius;
  final BorderRadius borderRadiusSmall;
  final BorderRadius borderRadiusLarge;
  final EdgeInsets spacing;
  final EdgeInsets spacingSmall;
  final EdgeInsets spacingLarge;
  final double elevation;
  final double elevationHigh;

  const AppThemeExtensions({
    required this.successColor,
    required this.warningColor,
    required this.infoColor,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.borderRadius,
    required this.borderRadiusSmall,
    required this.borderRadiusLarge,
    required this.spacing,
    required this.spacingSmall,
    required this.spacingLarge,
    required this.elevation,
    required this.elevationHigh,
  });

  @override
  AppThemeExtensions copyWith({
    Color? successColor,
    Color? warningColor,
    Color? infoColor,
    Color? surfaceVariant,
    Color? onSurfaceVariant,
    BorderRadius? borderRadius,
    BorderRadius? borderRadiusSmall,
    BorderRadius? borderRadiusLarge,
    EdgeInsets? spacing,
    EdgeInsets? spacingSmall,
    EdgeInsets? spacingLarge,
    double? elevation,
    double? elevationHigh,
  }) {
    return AppThemeExtensions(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      infoColor: infoColor ?? this.infoColor,
      surfaceVariant: surfaceVariant ?? this.surfaceVariant,
      onSurfaceVariant: onSurfaceVariant ?? this.onSurfaceVariant,
      borderRadius: borderRadius ?? this.borderRadius,
      borderRadiusSmall: borderRadiusSmall ?? this.borderRadiusSmall,
      borderRadiusLarge: borderRadiusLarge ?? this.borderRadiusLarge,
      spacing: spacing ?? this.spacing,
      spacingSmall: spacingSmall ?? this.spacingSmall,
      spacingLarge: spacingLarge ?? this.spacingLarge,
      elevation: elevation ?? this.elevation,
      elevationHigh: elevationHigh ?? this.elevationHigh,
    );
  }

  @override
  AppThemeExtensions lerp(ThemeExtension<AppThemeExtensions>? other, double t) {
    if (other is! AppThemeExtensions) {
      return this;
    }
    return AppThemeExtensions(
      successColor: Color.lerp(successColor, other.successColor, t)!,
      warningColor: Color.lerp(warningColor, other.warningColor, t)!,
      infoColor: Color.lerp(infoColor, other.infoColor, t)!,
      surfaceVariant: Color.lerp(surfaceVariant, other.surfaceVariant, t)!,
      onSurfaceVariant: Color.lerp(onSurfaceVariant, other.onSurfaceVariant, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      borderRadiusSmall: BorderRadius.lerp(borderRadiusSmall, other.borderRadiusSmall, t)!,
      borderRadiusLarge: BorderRadius.lerp(borderRadiusLarge, other.borderRadiusLarge, t)!,
      spacing: EdgeInsets.lerp(spacing, other.spacing, t)!,
      spacingSmall: EdgeInsets.lerp(spacingSmall, other.spacingSmall, t)!,
      spacingLarge: EdgeInsets.lerp(spacingLarge, other.spacingLarge, t)!,
      elevation: elevation,
      elevationHigh: elevationHigh,
    );
  }

  static const light = AppThemeExtensions(
    successColor: Color(0xFF10B981),
    warningColor: Color(0xFFF59E0B),
    infoColor: Color(0xFF3B82F6),
    surfaceVariant: Color(0xFFF8FAFC),
    onSurfaceVariant: Color(0xFF6B7280),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderRadiusSmall: BorderRadius.all(Radius.circular(4)),
    borderRadiusLarge: BorderRadius.all(Radius.circular(16)),
    spacing: EdgeInsets.all(16),
    spacingSmall: EdgeInsets.all(8),
    spacingLarge: EdgeInsets.all(24),
    elevation: 2,
    elevationHigh: 8,
  );

  static const dark = AppThemeExtensions(
    successColor: Color(0xFF10B981),
    warningColor: Color(0xFFF59E0B),
    infoColor: Color(0xFF3B82F6),
    surfaceVariant: Color(0xFF374151),
    onSurfaceVariant: Color(0xFF9CA3AF),
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderRadiusSmall: BorderRadius.all(Radius.circular(4)),
    borderRadiusLarge: BorderRadius.all(Radius.circular(16)),
    spacing: EdgeInsets.all(16),
    spacingSmall: EdgeInsets.all(8),
    spacingLarge: EdgeInsets.all(24),
    elevation: 2,
    elevationHigh: 8,
  );
}

/// Extension to easily access theme extensions
extension AppThemeExtension on ThemeData {
  AppThemeExtensions get appTheme => extension<AppThemeExtensions>()!;
}

/// Custom text styles using Poppins font
class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.12,
    letterSpacing: -0.25,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.16,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.22,
  );

  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
  );

  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.50,
    letterSpacing: 0.15,
  );

  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );
}

/// Custom button styles
class AppButtonStyles {
  static ButtonStyle get primary => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF2563EB),
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: const Color(0x1A000000),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle get secondary => OutlinedButton.styleFrom(
    foregroundColor: const Color(0xFF2563EB),
    side: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle get text => TextButton.styleFrom(
    foregroundColor: const Color(0xFF2563EB),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    textStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle get success => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF10B981),
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle get warning => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFF59E0B),
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  static ButtonStyle get error => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFEF4444),
    foregroundColor: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    textStyle: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
}
