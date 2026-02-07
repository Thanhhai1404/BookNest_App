import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// **Cozy Lo-Fi Library Theme**
///
/// Phong cách thiết kế ấm áp, dịu mắt với bảng màu kem/nâu đất,
/// lấy cảm hứng từ thư viện cổ điển và các ứng dụng ghi chú cute.
class AppTheme {
  // ==================== COLOR PALETTE ====================

  /// Background màu Kem Sữa - Giống màu giấy sách cũ
  static const Color creamBackground = Color(0xFFF7F3E8);

  /// Surface màu Trắng Kem
  static const Color creamWhite = Color(0xFFFFFCF5);

  /// Primary: Nâu Cam Đất (Terracotta)
  static const Color earthBrown = Color(0xFFD4A373);

  /// Primary Dark: Nâu Cà Phê Đậm
  static const Color coffeeBrown = Color(0xFF4A3B32);

  /// Secondary: Xanh Rêu Nhạt
  static const Color softSage = Color(0xFFCCD5AE);

  /// Secondary variant: Hồng Đất Nhạt
  static const Color paleEarth = Color(0xFFE9EDC9);

  /// Text Primary: Nâu Cà Phê Đậm
  static const Color textPrimary = Color(0xFF4A3B32);

  /// Text Secondary: Nâu Xám
  static const Color textSecondary = Color(0xFF6F5E53);

  /// Input Fill Color: Nâu Nhạt
  static const Color inputFill = Color(0xFFEFE6DD);

  /// Error Color: Đỏ Gạch
  static const Color brickRed = Color(0xFFBC4749);

  /// Success Color: Xanh Rêu
  static const Color successGreen = Color(0xFF9BB068);

  /// Warning Color: Cam Đất
  static const Color warningOrange = Color(0xFFE8B863);

  // ==================== LIGHT THEME ====================

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      // Backgrounds
      surface: creamWhite,
      onSurface: textPrimary,

      // Primary colors
      primary: earthBrown,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFE8D4BF), // Lighter earth brown
      onPrimaryContainer: coffeeBrown,

      // Secondary colors
      secondary: softSage,
      onSecondary: coffeeBrown,
      secondaryContainer: paleEarth,
      onSecondaryContainer: textPrimary,

      // Tertiary (for accents)
      tertiary: const Color(0xFFA97C73), // Dusty Rose
      onTertiary: Colors.white,

      // Error colors
      error: brickRed,
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),

      // Outline & dividers
      outline: const Color(0xFFD4C4B5),
      outlineVariant: const Color(0xFFE8DDD2),

      // Shadows
      shadow: textPrimary.withValues(alpha: 0.15),

      // Surface variants
      surfaceContainerHighest: const Color(0xFFF0EBE0),
      surfaceContainerHigh: const Color(0xFFF5F0E6),
      surfaceContainer: creamWhite,
      surfaceContainerLow: Colors.white,

      // Inverse colors (for dark elements on light background)
      inverseSurface: coffeeBrown,
      onInverseSurface: creamWhite,
      inversePrimary: const Color(0xFFE8C4A0),
    );

    // Typography - Nunito font (cute, rounded, friendly)
    final textTheme = GoogleFonts.nunitoTextTheme().copyWith(
      // Display styles (Large titles)
      displayLarge: GoogleFonts.nunito(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.nunito(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.nunito(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.2,
      ),

      // Headline styles (Headings)
      headlineLarge: GoogleFonts.nunito(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
      ),
      headlineMedium: GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.nunito(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.3,
      ),

      // Title styles
      titleLarge: GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),

      // Body styles
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.5,
      ),

      // Label styles (for buttons, chips)
      labelLarge: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: creamBackground,

      // ========== COMPONENT THEMES ==========

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: earthBrown,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actionsIconTheme: const IconThemeData(color: Colors.white),
      ),
      // Card Theme (Flat design with soft shadows)
      cardTheme: CardThemeData(
        color: creamWhite,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: earthBrown, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: brickRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: brickRed, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.nunito(
          color: textSecondary.withValues(alpha: 0.6),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelStyle: GoogleFonts.nunito(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: GoogleFonts.nunito(
          color: earthBrown,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: earthBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Filled Button Theme
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: earthBrown,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: earthBrown,
          side: BorderSide(color: earthBrown, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: earthBrown,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: coffeeBrown,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        extendedTextStyle: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: paleEarth,
        selectedColor: softSage,
        disabledColor: colorScheme.outlineVariant,
        labelStyle: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        side: BorderSide.none,
      ),
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: creamWhite,
        elevation: 4,
        shadowColor: coffeeBrown.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          height: 1.5,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: creamWhite,
        modalBackgroundColor: creamWhite,
        elevation: 8,
        shadowColor: coffeeBrown.withValues(alpha: 0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: earthBrown,
        circularTrackColor: inputFill,
        linearTrackColor: inputFill,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: coffeeBrown,
        contentTextStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 3,
      ),
      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: earthBrown,
        unselectedLabelColor: textSecondary.withValues(alpha: 0.6),
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: earthBrown, width: 3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        tileColor: creamWhite,
        selectedTileColor: paleEarth,
        iconColor: textPrimary,
        textColor: textPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return earthBrown;
          }
          return colorScheme.outlineVariant;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return earthBrown;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return earthBrown;
          }
          return textSecondary;
        }),
      ),
    );
  }

  // ==================== DARK THEME (Optional) ====================

  static ThemeData get darkTheme {
    // For future: Dark mode with warm, cozy colors
    // Background: #2C2416 (Dark Coffee)
    // Surface: #3D3226 (Darker Earth)
    // Primary: #E8C4A0 (Lighter Earth for visibility)
    return lightTheme; // Use light theme for now
  }
}
