import 'package:flutter/material.dart';

import '../../../data/content/nutritionist_exchange_plan.dart';
import '../../../domain/entities/food_exchange_group.dart';

/// Shows the mother's real diet plan in the simplest form possible: big
/// icons, big text, one food group per card, one portion size per item —
/// built for someone with low reading fluency, not for someone who wants
/// to browse a database.
class MyPlanScreen extends StatelessWidget {
  const MyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi plan de alimentación')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              elevation: 0,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'De cada grupo, elegí solo una opción por comida. '
                  'Si un día no tenés uno de los alimentos, podés cambiarlo '
                  'por otro del mismo grupo.',
                  style: TextStyle(fontSize: 17, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            for (final group in nutritionistExchangePlan) _PlanGroupCard(group: group),
          ],
        ),
      ),
    );
  }
}

class _PlanGroupCard extends StatelessWidget {
  const _PlanGroupCard({required this.group});

  final FoodExchangeGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fromNutritionist = group.source == FoodExchangeSource.nutritionist;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: fromNutritionist,
        expandedAlignment: Alignment.centerLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        leading: Text(group.icon, style: const TextStyle(fontSize: 32)),
        title: Text(
          group.name,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Chip(
                label: Text(
                  fromNutritionist ? 'De tu nutricionista' : 'Guía general',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                backgroundColor: fromNutritionist
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                visualDensity: VisualDensity.compact,
                side: BorderSide.none,
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              group.guidance,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.35),
            ),
          ),
          for (final item in group.items)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.food, style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item.portion,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
