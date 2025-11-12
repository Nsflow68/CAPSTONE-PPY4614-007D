import 'package:mi_refugio_app/shared/models/diary_entry.dart';

DateTime _day(int daysAgo) {
  final now = DateTime.now();
  return DateTime(
    now.year,
    now.month,
    now.day,
  ).subtract(Duration(days: daysAgo));
}

DateTime _timestamp(int daysAgo, int hour, int minute) {
  final date = _day(daysAgo);
  return DateTime(date.year, date.month, date.day, hour, minute);
}

final mockDiaryEntries = <DiaryEntry>[
  DiaryEntry(
    id: '1',
    title: 'Amanecer agradecido',
    content:
        'Inicie el dia con respiraciones suaves y escribi tres cosas que valoro.',
    mood: 'Calma',
    moodText: 'Te sentiste en calma y con gratitud.',
    score: 7,
    date: _day(0),
    createdAt: _timestamp(0, 7, 40),
    emotions: ['Gratitud', 'Calma', 'Esperanza'],
    tags: ['gratitud', 'rutina'],
  ),
  DiaryEntry(
    id: '2',
    title: 'Pequenos logros',
    content:
        'Cerre pendientes de la universidad y me premie con una caminata corta.',
    mood: 'Motivado',
    moodText: 'Reconociste avances concretos.',
    score: 8,
    date: _day(1),
    createdAt: _timestamp(1, 18, 5),
    emotions: ['Orgullo', 'Motivacion'],
    tags: ['estudios', 'logros'],
  ),
  DiaryEntry(
    id: '3',
    title: 'Tarde desafiante',
    content:
        'Senti ansiedad en una reunion dificil, pero pedi una pausa y hable con sinceridad.',
    mood: 'Ansiedad',
    moodText: 'Hubo tension pero encontraste alivio.',
    score: 4,
    date: _day(2),
    createdAt: _timestamp(2, 15, 20),
    emotions: ['Ansiedad', 'Alivio'],
    tags: ['trabajo', 'autocuidado'],
  ),
  DiaryEntry(
    id: '4',
    title: 'Conexion con amistades',
    content: 'Organice una videollamada y compartimos emociones sin juicio.',
    mood: 'Agradecido',
    moodText: 'Disfrutaste acompanamiento seguro.',
    score: 9,
    date: _day(4),
    createdAt: _timestamp(4, 21, 0),
    emotions: ['Gratitud', 'Alegria', 'Serenidad'],
    tags: ['amistad', 'apoyo'],
  ),
];
