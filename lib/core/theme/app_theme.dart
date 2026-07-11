import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Light sky blue in the same family as the app's logo (#0A66C2), rather
  // than a saturated corporate blue — reads as fresh/"celeste" and gives
  // Material 3's tonal palette (buttons, selected nav pill, switches, etc.)
  // a soft, airy feel instead of the previous green.
  static const _seed = Color(0xFF29B6F6);

  static ThemeData light() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(centerTitle: true),
      );
}
