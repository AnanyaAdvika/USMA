import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Tribal Affairs & National Palette inspired
  static const Color primary = Color(0xFF0F766E); // Deep Teal / Forest
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF115E59);

  static const Color secondary = Color(0xFFEA580C); // Warm Saffron / Terracotta
  static const Color secondaryLight = Color(0xFFFB923C);
  static const Color secondaryDark = Color(0xFFC2410C);

  static const Color accent = Color(0xFF3B82F6); // Trust Blue
  static const Color gold = Color(0xFFD97706); // Amber Gold for scholarships

  // Semantic Status Colors
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFDCFCE7);

  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFEF3C7);

  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEE2E2);

  static const Color info = Color(0xFF0284C7);
  static const Color infoBg = Color(0xFFE0F2FE);

  // Neutral Colors (Light Theme)
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFCBD5E1);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Dark Theme Neutrals
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF64748B);
}

class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;
}

class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double full = 999.0;
}

class AppShadows {
  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> elevated = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
