import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Light sky blue in the same family as the app's logo (#0A66C2), rather
  // than a saturated corporate blue — reads as fresh/"celeste" and gives
  // Material 3's tonal palette (buttons, selected nav pill, switches, etc.)
  // a soft, airy feel instead of the previous green.
  static const _seed = Color(0xFF29B6F6);

  // Slightly larger than Material 3 defaults and comfortable touch
  // targets everywhere — the primary user has low literacy and needs
  // every screen to read easily and be easy to tap without precision.
  static const _textTheme = TextTheme(
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    titleLarge: TextStyle(fontSize: 24),
    titleMedium: TextStyle(fontSize: 19),
  );

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        appBarTheme: const AppBarTheme(centerTitle: true),
        textTheme: _textTheme,
        visualDensity: VisualDensity.comfortable,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 52)),
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
        textTheme: _textTheme,
        visualDensity: VisualDensity.comfortable,
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size(64, 52)),
        ),
      );
}
