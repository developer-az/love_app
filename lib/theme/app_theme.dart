import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brand tokens. Body copy uses the platform typeface — custom webfonts
/// previously caused Safari text to paint twice.
class AppTheme {
  AppTheme._();

  static const Color brandIndigo = Color(0xFF6366F1);
  static const Color brandPink = Color(0xFFEC4899);
  static const Color brandViolet = Color(0xFF8B5CF6);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [brandIndigo, brandPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Color primaryColor = brandIndigo;
  static const Color secondaryColor = brandPink;
  static const Color accentColor = brandViolet;
  static const LinearGradient primaryGradient = brandGradient;

  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.6,
    height: 1.2,
  );
  static const TextStyle titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    height: 1.5,
  );
  static const TextStyle captionStyle = TextStyle(
    fontSize: 13,
    height: 1.4,
  );

  static BoxDecoration get gradientButtonDecoration => BoxDecoration(
        gradient: brandGradient,
        borderRadius: BorderRadius.circular(16),
      );

  static BoxDecoration cardDecorationOf(BuildContext context) {
    final theme = Theme.of(context);
    return BoxDecoration(
      color: theme.cardTheme.color ?? theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
      ),
    );
  }

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      );

  static InputDecoration get textFieldDecoration => InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: brandIndigo, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandIndigo,
      brightness: Brightness.light,
      primary: brandIndigo,
      secondary: brandPink,
      tertiary: brandViolet,
      surface: const Color(0xFFF8F5FF),
    );
    return _build(colorScheme, Brightness.light);
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandIndigo,
      brightness: Brightness.dark,
      primary: const Color(0xFF818CF8),
      secondary: const Color(0xFFF472B6),
      tertiary: const Color(0xFFA78BFA),
      surface: const Color(0xFF12101A),
    );
    return _build(colorScheme, Brightness.dark);
  }

  static ThemeData _build(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final onSurface = colorScheme.onSurface;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      visualDensity: VisualDensity.standard,
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: onSurface,
        surfaceTintColor: colorScheme.primary.withValues(alpha: 0.08),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF1C1826) : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: colorScheme.outlineVariant
                .withValues(alpha: isDark ? 0.4 : 0.7),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.92),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.8),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),
      textTheme: _textTheme(onSurface, isDark),
    );
  }

  static TextTheme _textTheme(Color onSurface, bool isDark) {
    final muted = onSurface.withValues(alpha: isDark ? 0.72 : 0.62);
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.15,
        color: onSurface,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.25,
        color: onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: onSurface,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: onSurface,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.55,
        color: onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.5,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: onSurface,
      ),
    );
  }
}
