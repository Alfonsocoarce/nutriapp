import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/enum_labels.dart';
import '../../../core/theme/chart_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final progressAsync = ref.watch(dailyProgressProvider);
    final profileAsync = ref.watch(profileControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dashboardTitle)),
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(l10n.commonError)),
          data: (profile) {
            if (profile == null) {
              return Center(child: Text(l10n.profileTitle));
            }
            return progressAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(l10n.commonError)),
              data: (progress) {
                if (progress == null) {
                  return Center(child: Text(l10n.commonError));
                }
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _CalorieRing(
                      consumed: progress.caloriesConsumed,
                      goal: progress.caloriesGoal,
                      remaining: progress.caloriesRemaining,
                      l10n: l10n,
                    ),
                    const SizedBox(height: 24),
                    if (progress.proteinGrams + progress.carbsGrams + progress.fatGrams > 0)
                      _MacroDistributionChart(
                        proteinGrams: progress.proteinGrams,
                        carbsGrams: progress.carbsGrams,
                        fatGrams: progress.fatGrams,
                        l10n: l10n,
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                              child: _MacroCard(
                                  label: l10n.dashboardProtein,
                                  grams: progress.proteinGrams)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _MacroCard(
                                  label: l10n.dashboardCarbs,
                                  grams: progress.carbsGrams)),
                          const SizedBox(width: 8),
                          Expanded(
                              child: _MacroCard(
                                  label: l10n.dashboardFat, grams: progress.fatGrams)),
                        ],
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.dashboardCurrentWeight,
                            style: Theme.of(context).textTheme.titleMedium),
                        Text('${profile.currentWeightKg} ${l10n.commonKg}'),
                      ],
                    ),
                    const Divider(height: 32),
                    Text(l10n.dashboardTodayMeals,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (progress.meals.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(l10n.dashboardNoMealsYet),
                      )
                    else
                      ...progress.meals.map((meal) => _MealRow(
                            name: meal.foodName,
                            mealTypeLabel: meal.mealType.label(l10n),
                            calorieText: meal.nutrition.calories?.toStringAsFixed(0) ??
                                l10n.foodLogNotAvailable,
                            l10n: l10n,
                          )),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.name,
    required this.mealTypeLabel,
    required this.calorieText,
    required this.l10n,
  });

  final String name;
  final String mealTypeLabel;
  final String calorieText;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  mealTypeLabel,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('$calorieText ${l10n.commonKcal}',
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({
    required this.consumed,
    required this.goal,
    required this.remaining,
    required this.l10n,
  });

  final double consumed;
  final double goal;
  final double remaining;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final fraction = goal <= 0 ? 0.0 : (consumed / goal).clamp(0, 1).toDouble();
    final overGoal = goal > 0 && consumed > goal;
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              startDegreeOffset: -90,
              sectionsSpace: 0,
              centerSpaceRadius: 70,
              sections: [
                PieChartSectionData(
                  value: fraction * 100,
                  color: overGoal ? ChartColors.red : ChartColors.blue,
                  showTitle: false,
                  radius: 22,
                ),
                PieChartSectionData(
                  value: (1 - fraction) * 100,
                  color: ChartColors.neutral.withValues(alpha: 0.3),
                  showTitle: false,
                  radius: 22,
                ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(consumed.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.headlineMedium),
              Text(l10n.dashboardCaloriesConsumed,
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text('${remaining.toStringAsFixed(0)} ${l10n.dashboardCaloriesRemaining}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroDistributionChart extends StatelessWidget {
  const _MacroDistributionChart({
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    required this.l10n,
  });

  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final proteinKcal = proteinGrams * 4;
    final carbsKcal = carbsGrams * 4;
    final fatKcal = fatGrams * 9;
    final total = proteinKcal + carbsKcal + fatKcal;

    final colors = [ChartColors.blue, ChartColors.red, ChartColors.amber];
    final entries = [
      (l10n.dashboardProtein, proteinGrams, proteinKcal, colors[0]),
      (l10n.dashboardCarbs, carbsGrams, carbsKcal, colors[1]),
      (l10n.dashboardFat, fatGrams, fatKcal, colors[2]),
    ];

    return Row(
      children: [
        SizedBox(
          height: 110,
          width: 110,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 28,
              sections: [
                for (final e in entries)
                  PieChartSectionData(
                    value: total <= 0 ? 1 : e.$3,
                    color: e.$4,
                    showTitle: false,
                    radius: 18,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final e in entries)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration:
                            BoxDecoration(color: e.$4, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      Text(e.$1, style: theme.textTheme.bodySmall),
                      const Spacer(),
                      Text('${e.$2.round()} g',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({required this.label, required this.grams});

  final String label;
  final double grams;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text('${grams.toStringAsFixed(0)} g',
                style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
