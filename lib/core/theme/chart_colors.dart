import 'package:flutter/material.dart';

/// Fixed chart palette, deliberately separate from [AppTheme]'s green
/// brand seed. Material 3's tonal palette generation keeps
/// secondary/tertiary close in hue to the seed color, so charts built
/// from `colorScheme.secondary`/`tertiary` all read as shades of the same
/// green — not the clearly distinguishable, "analytics dashboard" look
/// charts need. These are used only for data visualization (bars, pies,
/// progress indicators), never for buttons/branding.
class ChartColors {
  ChartColors._();

  static const blue = Color(0xFF2563EB);
  static const red = Color(0xFFDC2626);
  static const amber = Color(0xFFF59E0B);
  static const neutral = Color(0xFFB0B7C3);
}
