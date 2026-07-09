import 'activity_level.dart';
import 'nutrition_goal.dart';
import 'sex.dart';

class UserProfile {
  final int userId;
  final String name;
  final DateTime birthDate;
  final Sex sex;
  final double heightCm;
  final double currentWeightKg;
  final double targetWeightKg;
  final ActivityLevel activityLevel;
  final List<NutritionGoal> goals;
  final List<String> restrictions;
  final List<String> allergies;
  final List<String> diseases;

  const UserProfile({
    required this.userId,
    required this.name,
    required this.birthDate,
    required this.sex,
    required this.heightCm,
    required this.currentWeightKg,
    required this.targetWeightKg,
    required this.activityLevel,
    this.goals = const [],
    this.restrictions = const [],
    this.allergies = const [],
    this.diseases = const [],
  });

  int get ageYears {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  /// Mifflin-St Jeor basal metabolic rate estimate.
  double get bmr {
    final base = 10 * currentWeightKg + 6.25 * heightCm - 5 * ageYears;
    return switch (sex) {
      Sex.male => base + 5,
      Sex.female => base - 161,
      Sex.other => base - 78, // midpoint offset
    };
  }

  double get dailyCalorieGoal => bmr * activityLevel.multiplier;

  UserProfile copyWith({
    String? name,
    DateTime? birthDate,
    Sex? sex,
    double? heightCm,
    double? currentWeightKg,
    double? targetWeightKg,
    ActivityLevel? activityLevel,
    List<NutritionGoal>? goals,
    List<String>? restrictions,
    List<String>? allergies,
    List<String>? diseases,
  }) {
    return UserProfile(
      userId: userId,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      activityLevel: activityLevel ?? this.activityLevel,
      goals: goals ?? this.goals,
      restrictions: restrictions ?? this.restrictions,
      allergies: allergies ?? this.allergies,
      diseases: diseases ?? this.diseases,
    );
  }
}
