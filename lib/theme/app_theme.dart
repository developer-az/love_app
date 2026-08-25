import 'package:flutter/material.dart';

class AppTheme {
  // Premium color palette - Modern and sophisticated
  static const Color primaryColor = Color(0xFF6366F1); // Indigo
  static const Color primaryDark = Color(0xFF4338CA); // Dark indigo
  static const Color secondaryColor = Color(0xFFEC4899); // Pink
  static const Color accentColor = Color(0xFF8B5CF6); // Purple
  static const Color backgroundColor = Color(0xFFFAFAFA); // Very light gray
  static const Color surfaceColor = Colors.white;
  static const Color textColor = Color(0xFF1F2937); // Dark gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color cardColor = Colors.white;
  static const Color shadowColor = Color(0x10000000);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: textColor,
    letterSpacing: -0.5,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
    letterSpacing: -0.3,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
    height: 1.5,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 14,
    color: textSecondary,
    height: 1.4,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: textColor,
    letterSpacing: -0.4,
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      );

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      );

  static BoxDecoration get gradientButtonDecoration => BoxDecoration(
        gradient: primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static InputDecoration get textFieldDecoration => InputDecoration(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      );

  static AppBarTheme get appBarTheme => const AppBarTheme(
        backgroundColor: Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textColor,
        titleTextStyle: titleStyle,
        centerTitle: true,
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
          primary: primaryColor,
          secondary: secondaryColor,
          surface: surfaceColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: appBarTheme,
        textTheme: const TextTheme(
          headlineLarge: headingStyle,
          headlineMedium: subheadingStyle,
          bodyLarge: bodyStyle,
          bodyMedium: captionStyle,
          titleMedium: titleStyle,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintStyle: captionStyle,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          color: surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(8),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      );
}
