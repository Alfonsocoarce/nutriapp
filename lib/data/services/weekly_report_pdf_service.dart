import 'dart:io';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../domain/entities/food_frequency.dart';
import '../../domain/entities/weekly_summary.dart';

const _weekdayNames = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const _monthNames = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

String _fullDate(DateTime d) => '${d.day} de ${_monthNames[d.month - 1]} de ${d.year}';

String weekRangeLabel(DateTime start, DateTime end) {
  if (start.month == end.month) {
    return '${start.day} al ${end.day} de ${_monthNames[start.month - 1]} de ${start.year}';
  }
  return '${_fullDate(start)} al ${_fullDate(end)}';
}

/// Builds a one-page-or-more PDF weekly report (daily calories vs. goal,
/// weekly averages, most-consumed foods, and nutrition recommendations)
/// and saves it under the app's documents/reports directory so it stays
/// available for later re-sharing without regenerating it. The caller
/// supplies the recommendations (AI-generated, with a rule-based fallback —
/// see [GeminiWeeklyRecommendationsService]) so this service stays a pure
/// PDF layout concern.
class WeeklyReportPdfService {
  Future<File> generate(
    WeeklySummary summary, {
    required List<FoodFrequency> topFoods,
    required List<String> recommendations,
  }) async {
    final document = PdfDocument();
    var page = document.pages.add();
    final pageWidth = page.getClientSize().width;

    final titleFont = PdfStandardFont(PdfFontFamily.helvetica, 20, style: PdfFontStyle.bold);
    final subtitleFont = PdfStandardFont(PdfFontFamily.helvetica, 12);
    final sectionFont = PdfStandardFont(PdfFontFamily.helvetica, 14, style: PdfFontStyle.bold);
    final bodyFont = PdfStandardFont(PdfFontFamily.helvetica, 10);
    final smallItalicFont =
        PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.italic);

    double y = 0;
    page.graphics.drawString(
      'NutriApp - Resumen semanal',
      titleFont,
      bounds: Rect.fromLTWH(0, y, pageWidth, 28),
    );
    y += 30;
    page.graphics.drawString(
      '${summary.profile.name} · ${weekRangeLabel(summary.weekStart, summary.weekEnd)}',
      subtitleFont,
      bounds: Rect.fromLTWH(0, y, pageWidth, 20),
    );
    y += 32;

    final grid = PdfGrid();
    grid.columns.add(count: 7);
    final header = grid.headers.add(1)[0];
    const headerLabels = [
      'Día',
      'Meta (kcal)',
      'Consumido (kcal)',
      'Dif.',
      'Prot. (g)',
      'Carbs (g)',
      'Grasas (g)',
    ];
    for (var i = 0; i < headerLabels.length; i++) {
      header.cells[i].value = headerLabels[i];
    }
    header.style = PdfGridRowStyle(
      backgroundBrush: PdfSolidBrush(PdfColor(10, 102, 194)),
      textBrush: PdfSolidBrush(PdfColor(255, 255, 255)),
      font: PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold),
    );

    for (final day in summary.days) {
      final row = grid.rows.add();
      final logged = day.mealCount > 0;
      row.cells[0].value = '${_weekdayNames[day.date.weekday - 1]} ${day.date.day}/${day.date.month}';
      row.cells[1].value = day.caloriesGoal.round().toString();
      row.cells[2].value = logged ? day.caloriesConsumed.round().toString() : 'Sin registros';
      row.cells[3].value =
          logged ? '${day.calorieDifference >= 0 ? '+' : ''}${day.calorieDifference.round()}' : '-';
      row.cells[4].value = logged ? day.proteinGrams.round().toString() : '-';
      row.cells[5].value = logged ? day.carbsGrams.round().toString() : '-';
      row.cells[6].value = logged ? day.fatGrams.round().toString() : '-';
    }

    final gridResult = grid.draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0));
    page = gridResult?.page ?? page;
    y = (gridResult?.bounds.bottom ?? y) + 24;

    page.graphics.drawString('Promedios de la semana', sectionFont,
        bounds: Rect.fromLTWH(0, y, pageWidth, 20));
    y += 26;

    final avgLines = [
      'Calorías: ${summary.avgCaloriesConsumed.round()} kcal/día (meta: ${summary.avgCaloriesGoal.round()} kcal/día)',
      'Proteína: ${summary.avgProteinGrams.round()} g/día',
      'Carbohidratos: ${summary.avgCarbsGrams.round()} g/día',
      'Grasas: ${summary.avgFatGrams.round()} g/día',
      'Días con registros: ${summary.daysLogged} de 7',
    ];
    for (final line in avgLines) {
      final result = PdfTextElement(text: '-  $line', font: bodyFont)
          .draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0));
      page = result?.page ?? page;
      y = (result?.bounds.bottom ?? y + 16) + 2;
    }
    y += 14;

    if (topFoods.isNotEmpty) {
      page.graphics.drawString('Alimentos más consumidos', sectionFont,
          bounds: Rect.fromLTWH(0, y, pageWidth, 20));
      y += 26;
      for (final food in topFoods) {
        final times = food.count == 1 ? 'vez' : 'veces';
        final result = PdfTextElement(
          text: '-  ${food.name}: ${food.count} $times'
              '${food.totalCalories > 0 ? ' (${food.totalCalories.round()} kcal en total)' : ''}',
          font: bodyFont,
        ).draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0));
        page = result?.page ?? page;
        y = (result?.bounds.bottom ?? y + 16) + 2;
      }
      y += 14;
    }

    page.graphics.drawString('Recomendaciones', sectionFont,
        bounds: Rect.fromLTWH(0, y, pageWidth, 20));
    y += 26;

    for (final tip in recommendations) {
      final result = PdfTextElement(text: '-  $tip', font: bodyFont)
          .draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0));
      page = result?.page ?? page;
      y = (result?.bounds.bottom ?? y + 16) + 8;
    }
    y += 14;

    PdfTextElement(
      text: 'Este resumen es generado con inteligencia artificial a partir de '
          'tus propios registros y no sustituye la consulta con un '
          'profesional de la salud o nutrición.',
      font: smallItalicFont,
    ).draw(page: page, bounds: Rect.fromLTWH(0, y, pageWidth, 0));

    final bytes = await document.save();
    document.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/reports');
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    final fileName = 'nutriapp_resumen_'
        '${summary.weekStart.year}-${summary.weekStart.month.toString().padLeft(2, '0')}-${summary.weekStart.day.toString().padLeft(2, '0')}'
        '.pdf';
    final file = File('${reportsDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<List<File>> listGeneratedReports() async {
    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/reports');
    if (!await reportsDir.exists()) return const [];
    final files = await reportsDir
        .list()
        .where((e) => e is File && e.path.endsWith('.pdf'))
        .cast<File>()
        .toList();
    files.sort((a, b) => b.path.compareTo(a.path));
    return files;
  }
}
