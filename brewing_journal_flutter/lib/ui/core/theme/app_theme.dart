import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Parchment and espresso theme for BrewSync.
///
/// Titles use Fraunces, like a cafe menu. Body copy uses Source Sans 3 so
/// recipes stay easy to read.
ThemeData buildAppTheme(Brightness brightness) {
  final scheme = brightness == Brightness.dark
      ? _darkColorScheme
      : _lightColorScheme;
  final textTheme = _textTheme(brightness, scheme);
  final radius = BorderRadius.circular(14);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    appBarTheme: AppBarThemeData(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: scheme.surface,
      titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      iconTheme: IconThemeData(color: scheme.onSurface),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.primaryContainer,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelMedium?.copyWith(
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? scheme.onSurface : scheme.onSurfaceVariant,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: scheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: radius),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: scheme.secondaryContainer,
      labelStyle: textTheme.labelLarge?.copyWith(
        color: scheme.onSecondaryContainer,
      ),
      side: BorderSide.none,
      shape: const StadiumBorder(),
    ),
    inputDecorationTheme: InputDecorationThemeData(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      labelStyle: textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
      hintStyle: textTheme.bodyLarge?.copyWith(color: scheme.outline),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: scheme.primary,
      titleTextStyle: textTheme.titleMedium?.copyWith(color: scheme.onSurface),
      subtitleTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurfaceVariant,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        shape: RoundedRectangleBorder(borderRadius: radius),
        textStyle: textTheme.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: scheme.primary,
      foregroundColor: scheme.onPrimary,
      extendedTextStyle: textTheme.labelLarge?.copyWith(
        color: scheme.onPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurfaceVariant,
        selectedBackgroundColor: scheme.primaryContainer,
        selectedForegroundColor: scheme.onPrimaryContainer,
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
  );
}

TextTheme _textTheme(Brightness brightness, ColorScheme scheme) {
  final base = ThemeData(brightness: brightness, useMaterial3: true).textTheme;
  final body = GoogleFonts.sourceSans3TextTheme(base);
  final display = GoogleFonts.frauncesTextTheme(base);

  return body
      .copyWith(
        displayLarge: display.displayLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        displayMedium: display.displayMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        displaySmall: display.displaySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        headlineLarge: display.headlineLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
        ),
        headlineMedium: display.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        headlineSmall: display.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleLarge: display.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        titleMedium: display.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.15,
        ),
      )
      .apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);
}

/// Daylight: parchment paper, espresso ink, latte foam, and a caramel accent.
const _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF5C3317),
  onPrimary: Color(0xFFFFF8F0),
  primaryContainer: Color(0xFFE8C9A8),
  onPrimaryContainer: Color(0xFF3A1F0C),
  secondary: Color(0xFF8A4B2F),
  onSecondary: Color(0xFFFFF8F0),
  secondaryContainer: Color(0xFFF3D5C4),
  onSecondaryContainer: Color(0xFF4A2416),
  tertiary: Color(0xFF3F5C45),
  onTertiary: Color(0xFFF4F8F4),
  tertiaryContainer: Color(0xFFD5E4D4),
  onTertiaryContainer: Color(0xFF1C3324),
  error: Color(0xFF9C2F2F),
  onError: Color(0xFFFFF8F6),
  errorContainer: Color(0xFFF8D6D2),
  onErrorContainer: Color(0xFF410E0B),
  surface: Color(0xFFF6F0E6),
  onSurface: Color(0xFF2A1B12),
  surfaceDim: Color(0xFFE4D8C8),
  surfaceBright: Color(0xFFFFFBF5),
  surfaceContainerLowest: Color(0xFFFFFBF5),
  surfaceContainerLow: Color(0xFFF3EADF),
  surfaceContainer: Color(0xFFEBE0D2),
  surfaceContainerHigh: Color(0xFFE3D5C4),
  surfaceContainerHighest: Color(0xFFD9C8B4),
  onSurfaceVariant: Color(0xFF5E4636),
  outline: Color(0xFF8A7260),
  outlineVariant: Color(0xFFD4C2B0),
  shadow: Color(0xFF1A100A),
  scrim: Color(0xFF1A100A),
  inverseSurface: Color(0xFF35261C),
  onInverseSurface: Color(0xFFF6EFE6),
  inversePrimary: Color(0xFFE6C4A0),
  surfaceTint: Color(0xFF5C3317),
);

/// Night: dark roast surfaces with cream foam for actions.
const _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFE6C4A0),
  onPrimary: Color(0xFF3A2414),
  primaryContainer: Color(0xFF6B4226),
  onPrimaryContainer: Color(0xFFF8E6D0),
  secondary: Color(0xFFE0A888),
  onSecondary: Color(0xFF3F2416),
  secondaryContainer: Color(0xFF6B3E2A),
  onSecondaryContainer: Color(0xFFF8D9C8),
  tertiary: Color(0xFFA8C9AE),
  onTertiary: Color(0xFF1A3322),
  tertiaryContainer: Color(0xFF2E4A36),
  onTertiaryContainer: Color(0xFFD4E8D6),
  error: Color(0xFFFFB4AB),
  onError: Color(0xFF690005),
  errorContainer: Color(0xFF93000A),
  onErrorContainer: Color(0xFFFFDAD6),
  surface: Color(0xFF1C1410),
  onSurface: Color(0xFFF3E8DC),
  surfaceDim: Color(0xFF140E0B),
  surfaceBright: Color(0xFF3D3128),
  surfaceContainerLowest: Color(0xFF120D0A),
  surfaceContainerLow: Color(0xFF241A15),
  surfaceContainer: Color(0xFF2C211B),
  surfaceContainerHigh: Color(0xFF362920),
  surfaceContainerHighest: Color(0xFF413228),
  onSurfaceVariant: Color(0xFFD4C2B0),
  outline: Color(0xFFA08B78),
  outlineVariant: Color(0xFF4A3A2E),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFF3E8DC),
  onInverseSurface: Color(0xFF35261C),
  inversePrimary: Color(0xFF5C3317),
  surfaceTint: Color(0xFFE6C4A0),
);
