enum MealType {
  breakfast,
  morningSnack,
  lunch,
  afternoonSnack,
  dinner,
  drink,
  dessert;

  /// "drink"/"dessert" are never auto-assigned here — they're deliberate
  /// user choices, not tied to a time of day — so a solid meal logged late
  /// at night or before dawn defaults to "dinner" instead of misleadingly
  /// landing on "drink" just because the clock fell outside the earlier
  /// explicit ranges.
  static MealType fromHour(int hour) {
    if (hour >= 5 && hour < 10) return MealType.breakfast;
    if (hour >= 10 && hour < 12) return MealType.morningSnack;
    if (hour >= 12 && hour < 15) return MealType.lunch;
    if (hour >= 15 && hour < 18) return MealType.afternoonSnack;
    return MealType.dinner;
  }
}
