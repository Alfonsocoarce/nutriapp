/// Warm, family-affection affirmations shown occasionally around the app —
/// never as a popup, always as a small dismissable card — so the emotional
/// support around the health/weight-loss goal is as present as the data.
const affirmationPhrases = <String>[
  'En la familia todos te amamos y te apoyamos, pase lo que pase.',
  'Sabemos que los cambios y las enfermedades no son fáciles. Estamos con vos en cada paso.',
  'Cada pequeña decisión saludable de hoy es un regalo que te das a vos misma.',
  'No estás sola en esto. Toda la familia está caminando este proceso con vos.',
  'Tu esfuerzo se nota, y estamos muy orgullosos de vos.',
  'Ir despacio también es avanzar. Lo importante es que seguís adelante.',
  'Te queremos ver bien y con salud por muchos años más. Por eso vale la pena.',
  'Cada comida es una oportunidad nueva, no importa cómo haya sido la anterior.',
];

String affirmationForDay(DateTime day) {
  final dayIndex = day.difference(DateTime(day.year)).inDays;
  return affirmationPhrases[dayIndex % affirmationPhrases.length];
}
