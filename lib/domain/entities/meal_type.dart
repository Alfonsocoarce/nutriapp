enum MealType {
  breakfast,
  morningSnack,
  lunch,
  afternoonSnack,
  dinner,
  drink,
  dessert;

  static MealType fromHour(int hour) {
    if (hour >= 5 && hour < 10) return MealType.breakfast;
    if (hour >= 10 && hour < 12) return MealType.morningSnack;
    if (hour >= 12 && hour < 15) return MealType.lunch;
    if (hour >= 15 && hour < 18) return MealType.afternoonSnack;
    if (hour >= 18 && hour < 22) return MealType.dinner;
    return MealType.drink;
  }
}
