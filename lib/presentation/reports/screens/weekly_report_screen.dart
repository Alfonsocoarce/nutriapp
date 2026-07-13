import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/chart_colors.dart';
import '../../../data/services/weekly_report_pdf_service.dart';
import '../../../domain/entities/food_frequency.dart';
import '../../../domain/entities/weekly_summary.dart';
import '../../../domain/usecases/compute_weekly_summary_usecase.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/weekly_report_providers.dart';

class WeeklyReportScreen extends ConsumerStatefulWidget {
  const WeeklyReportScreen({super.key});

  @override
  ConsumerState<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends ConsumerState<WeeklyReportScreen> {
  bool _generating = false;

  Future<void> _generateAndShare(WeeklySummary summary) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _generating = true);
    try {
      final topFoods = await ref.read(topFoodsProvider.future);
      final recommendations = await ref
          .read(weeklyRecommendationsServiceProvider)
          .generate(summary, topFoods);
      final pantryItems = await ref.read(currentPantryItemsProvider.future);
      final habitEntries = await ref.read(habitEntriesProvider.future);
      final mealPlan = await ref
          .read(mealPlannerServiceProvider)
          .generate(summary, pantryItems, habitEntries);
      final file = await ref.read(weeklyReportPdfServiceProvider).generate(
            summary,
            topFoods: topFoods,
            recommendations: recommendations,
            mealPlan: mealPlan,
          );
      ref.invalidate(generatedReportsProvider);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: l10n.reportsShareSubject,
        text: l10n.reportsShareSubject,
        sharePositionOrigin: box == null ? null : (box.localToGlobal(Offset.zero) & box.size),
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.reportsGeneratedSnackbar)));
    } catch (error, stackTrace) {
      debugPrint('Weekly report generation failed: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.reportsGenerationFailed)));
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final weekStart = ref.watch(selectedWeekStartProvider);
    final summaryAsync = ref.watch(weeklySummaryProvider);
    final topFoodsAsync = ref.watch(topFoodsProvider);
    final reportsAsync = ref.watch(generatedReportsProvider);
    final isCurrentOrFutureWeek = !weekStart.isBefore(rollingWeekStart(DateTime.now()));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reportsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => ref
                      .read(selectedWeekStartProvider.notifier)
                      .state = weekStart.subtract(const Duration(days: 7)),
                ),
                Expanded(
                  child: Text(
                    weekRangeLabel(weekStart, weekStart.add(const Duration(days: 6))),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: isCurrentOrFutureWeek
                      ? null
                      : () => ref
                          .read(selectedWeekStartProvider.notifier)
                          .state = weekStart.add(const Duration(days: 7)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('$error')),
              ),
              data: (summary) => summary == null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: Text(l10n.reportsNoProfile)),
                    )
                  : _WeeklyReportBody(
                      summary: summary,
                      topFoods: topFoodsAsync.valueOrNull ?? const [],
                      generating: _generating,
                      onGenerate: () => _generateAndShare(summary),
                    ),
            ),
            const SizedBox(height: 24),
            Text(l10n.reportsPreviousReports,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            reportsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (files) => files.isEmpty
                  ? Text(l10n.reportsNoPreviousReports,
                      style: Theme.of(context).textTheme.bodyMedium)
                  : Column(
                      children: files
                          .map((f) => ListTile(
                                dense: true,
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(Icons.picture_as_pdf_outlined),
                                title: Text(f.uri.pathSegments.last,
                                    maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: IconButton(
                                  icon: const Icon(Icons.share),
                                  tooltip: l10n.reportsShare,
                                  onPressed: () {
                                    final box =
                                        context.findRenderObject() as RenderBox?;
                                    SharePlus.instance.share(ShareParams(
                                      files: [XFile(f.path, mimeType: 'application/pdf')],
                                      subject: l10n.reportsShareSubject,
                                      text: l10n.reportsShareSubject,
                                      sharePositionOrigin: box == null
                                          ? null
                                          : (box.localToGlobal(Offset.zero) & box.size),
                                    ));
                                  },
                                ),
                              ))
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyReportBody extends StatelessWidget {
  const _WeeklyReportBody({
    required this.summary,
    required this.topFoods,
    required this.generating,
    required this.onGenerate,
  });

  final WeeklySummary summary;
  final List<FoodFrequency> topFoods;
  final bool generating;
  final VoidCallback onGenerate;

  static const _weekdayShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.reportsCaloriesChartTitle, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        _CaloriesBarChart(summary: summary),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              for (final day in summary.days) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text(_weekdayShort[day.date.weekday - 1],
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        day.mealCount == 0
                            ? l10n.reportsNoEntriesThisDay
                            : '${day.caloriesConsumed.round()} / ${day.caloriesGoal.round()} kcal',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    if (day.mealCount > 0)
                      Text(
                        '${day.calorieDifference >= 0 ? '+' : ''}${day.calorieDifference.round()}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: day.calorieDifference > 0
                              ? ChartColors.red
                              : ChartColors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                if (day != summary.days.last) const Divider(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(l10n.reportsAverages, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _StatChip(
                label: l10n.foodLogCalories,
                value: '${summary.avgCaloriesConsumed.round()} kcal'),
            _StatChip(
                label: l10n.dashboardProtein,
                value: '${summary.avgProteinGrams.round()} g'),
            _StatChip(
                label: l10n.dashboardCarbs,
                value: '${summary.avgCarbsGrams.round()} g'),
            _StatChip(
                label: l10n.dashboardFat, value: '${summary.avgFatGrams.round()} g'),
            _StatChip(
                label: l10n.reportsDaysLogged, value: '${summary.daysLogged}/7'),
          ],
        ),
        if (topFoods.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(l10n.reportsTopFoods, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          _TopFoodsChart(topFoods: topFoods),
        ],
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: generating ? null : onGenerate,
          icon: generating
              ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf),
          label: Text(generating ? l10n.reportsGenerating : l10n.reportsGeneratePdf),
        ),
      ],
    );
  }
}

class _CaloriesBarChart extends StatelessWidget {
  const _CaloriesBarChart({required this.summary});

  final WeeklySummary summary;

  static const _weekdayShort = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goal = summary.avgCaloriesGoal;
    final maxConsumed = summary.days
        .map((d) => d.caloriesConsumed)
        .fold<double>(0, (a, b) => a > b ? a : b);
    final maxY = [goal, maxConsumed].reduce((a, b) => a > b ? a : b) * 1.2;

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 100 : maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(_weekdayShort[value.toInt()],
                      style: theme.textTheme.labelSmall),
                ),
              ),
            ),
          ),
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: goal,
              color: theme.colorScheme.outline,
              strokeWidth: 1.5,
              dashArray: [6, 4],
            ),
          ]),
          barGroups: [
            for (var i = 0; i < summary.days.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: summary.days[i].caloriesConsumed,
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                  color: summary.days[i].mealCount == 0
                      ? ChartColors.neutral
                      : summary.days[i].caloriesConsumed > goal
                          ? ChartColors.red
                          : ChartColors.blue,
                ),
              ]),
          ],
        ),
      ),
    );
  }
}

class _TopFoodsChart extends StatelessWidget {
  const _TopFoodsChart({required this.topFoods});

  final List<FoodFrequency> topFoods;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxCount = topFoods.map((f) => f.count).reduce((a, b) => a > b ? a : b);

    return Column(
      children: topFoods.map((food) {
        final fraction = maxCount == 0 ? 0.0 : food.count / maxCount;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(food.name,
                        style: theme.textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                  ),
                  Text('${food.count}×',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: fraction,
                  minHeight: 8,
                  backgroundColor: ChartColors.neutral.withValues(alpha: 0.3),
                  color: ChartColors.amber,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          Text(value,
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
