enum ActivityLevel {
  sedentary,
  light,
  moderate,
  active,
  veryActive;

  /// Multiplier applied to BMR to estimate total daily energy expenditure.
  double get multiplier => switch (this) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.light => 1.375,
        ActivityLevel.moderate => 1.55,
        ActivityLevel.active => 1.725,
        ActivityLevel.veryActive => 1.9,
      };
}
