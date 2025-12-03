import 'package:flutter/material.dart';

/// DEVS: DEFINE STYLES HERE! DO NOT DEFINE INLINE!!!!! @EVERYONE
class AppColors {
  AppColors._(); // constructor to prevent instantiation

  static const Color primaryBlack = Color(0xFF0A0A0A);
  static const Color secondaryBlack = Color(0xFF1A1A1A);
  static const Color accentGray = Color(0xFF2A2A2A);
  static const Color lightGray = Color(0xFFA0A0A0);
  static const Color ultraLight = Color(0xFFF5F5F5);

  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentBlue = Color(0xFF0066FF);

  static const Color successGreen = Color(0xFF10B981);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);

  static const Color gradientStart = Color(0xFF0A0A0A);
  static const Color gradientEnd = Color(0xFF1A1A1A);

  static Color get subtleBorder => Colors.white.withValues(alpha: 0.05);

  static Color get accentGoldLight => accentGold.withValues(alpha: 0.15);
  static Color get successGreenLight => successGreen.withValues(alpha: 0.15);
  static Color get dangerRedLight => dangerRed.withValues(alpha: 0.15);
}

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Inter';

  static const TextStyle logo = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.accentGold,
    letterSpacing: 4,
  );

  static const TextStyle logoSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.accentGold,
    letterSpacing: 4,
  );

  static const TextStyle tagline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: AppColors.lightGray,
    letterSpacing: 2,
  );

  static const TextStyle taglineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: AppColors.lightGray,
    letterSpacing: 2,
  );

  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.ultraLight,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.ultraLight,
  );

  // Body text
  static const TextStyle bodyPrimary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    color: AppColors.ultraLight,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    color: AppColors.lightGray,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    color: AppColors.lightGray,
  );

  // Product card styles
  static const TextStyle productName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.ultraLight,
  );

  static const TextStyle productBrand = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.lightGray,
    letterSpacing: 0.5,
  );

  static const TextStyle productPrice = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.accentGold,
  );

  // AppBar title
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 4,
    color: AppColors.accentGold,
  );
}

/// THEME CONFIG
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,

    // Dark color scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accentGold,
      secondary: AppColors.accentBlue,
      surface: AppColors.secondaryBlack,
      error: AppColors.dangerRed,
      onPrimary: AppColors.primaryBlack,
      onSecondary: Colors.white,
      onSurface: AppColors.ultraLight,
      onError: Colors.white,
    ),

    // Scaffold background
    scaffoldBackgroundColor: AppColors.primaryBlack,

    // App bar theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 2,
      backgroundColor: AppColors.secondaryBlack.withValues(alpha: 0.9),
      foregroundColor: AppColors.ultraLight,
      titleTextStyle: AppTextStyles.appBarTitle,
    ),

    // Card theme
    cardTheme: CardThemeData(
      elevation: 2,
      color: AppColors.secondaryBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.subtleBorder),
      ),
    ),

    // Elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.primaryBlack,
        backgroundColor: AppColors.accentGold,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    ),

    // Text button theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accentGold),
    ),

    // Input decoration theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.accentGray,
      hintStyle: const TextStyle(color: AppColors.lightGray),
      labelStyle: const TextStyle(color: AppColors.lightGray),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.subtleBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.subtleBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentGold, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIconColor: AppColors.lightGray,
      suffixIconColor: AppColors.lightGray,
    ),

    // Chip theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.accentGray,
      labelStyle: const TextStyle(color: AppColors.ultraLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),

    // Snackbar theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.secondaryBlack,
      contentTextStyle: const TextStyle(color: AppColors.ultraLight),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),

    // Dialog theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.secondaryBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: AppTextStyles.headingMedium,
      contentTextStyle: AppTextStyles.bodySecondary,
    ),

    // Icon theme
    iconTheme: const IconThemeData(color: AppColors.lightGray),

    // Text theme
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
        color: AppColors.ultraLight,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Inter',
        fontWeight: FontWeight.w600,
        color: AppColors.ultraLight,
      ),
      bodyLarge: TextStyle(fontFamily: 'Inter', color: AppColors.ultraLight),
      bodyMedium: TextStyle(fontFamily: 'Inter', color: AppColors.lightGray),
    ),

    // Divider theme
    dividerTheme: DividerThemeData(color: AppColors.subtleBorder),
  );
}

/// Reusable widget builders for consistent UI
class AppWidgets {
  AppWidgets._();

  /// Builds the text-only Becathlon logo
  static Widget logo({bool small = false}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'BECATHLON',
          textAlign: TextAlign.center,
          style: small ? AppTextStyles.logoSmall : AppTextStyles.logo,
        ),
        const SizedBox(height: 8),
        Text(
          'Performance Elevated',
          textAlign: TextAlign.center,
          style: small ? AppTextStyles.taglineSmall : AppTextStyles.tagline,
        ),
      ],
    );
  }

  /// Builds a success snackbar
  static SnackBar successSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: AppColors.successGreen,
    );
  }

  /// Builds an error snackbar
  static SnackBar errorSnackBar(String message) {
    return SnackBar(
      content: Text(message),
      backgroundColor: AppColors.dangerRed,
    );
  }

  /// Builds a styled card with dark theme
  static Widget card({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(24),
  }) {
    return Card(
      elevation: 4,
      color: AppColors.secondaryBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.subtleBorder),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  /// Builds a placeholder image container
  static Widget imagePlaceholder({double iconSize = 48}) {
    return Container(
      color: AppColors.accentGray,
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: iconSize,
          color: AppColors.lightGray,
        ),
      ),
    );
  }

  /// Builds a loading indicator
  static Widget loadingIndicator({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.accentGold),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message, style: AppTextStyles.bodySecondary),
          ],
        ],
      ),
    );
  }

  /// Builds an error state widget
  static Widget errorState({required String message, VoidCallback? onRetry}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.dangerRed,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds an empty state widget
  static Widget emptyState({
    required String title,
    String? subtitle,
    IconData icon = Icons.inventory_2_outlined,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: AppColors.lightGray),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.ultraLight,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    );
  }

  /// Builds a stock status badge
  static Widget stockBadge({required bool inStock}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: inStock ? AppColors.successGreenLight : AppColors.dangerRedLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        inStock ? 'In Stock' : 'Out of Stock',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: inStock ? AppColors.successGreen : AppColors.dangerRed,
        ),
      ),
    );
  }

  /// Builds a rating row with gold stars
  static Widget ratingRow({required double rating, String? ratingText}) {
    return Row(
      children: [
        ...List.generate(5, (index) {
          if (index < rating.floor()) {
            return const Icon(
              Icons.star,
              size: 14,
              color: AppColors.accentGold,
            );
          } else if (index < rating && rating - index >= 0.5) {
            return const Icon(
              Icons.star_half,
              size: 14,
              color: AppColors.accentGold,
            );
          } else {
            return const Icon(
              Icons.star_border,
              size: 14,
              color: AppColors.lightGray,
            );
          }
        }),
        if (ratingText != null) ...[
          const SizedBox(width: 4),
          Text(ratingText, style: AppTextStyles.bodySmall),
        ],
      ],
    );
  }
}
