import "package:mi_refugio_app/shared/models/diary_entry.dart";

final mockDiaryEntries = <DiaryEntry>[
  DiaryEntry(
    id: "1",
    title: "Agradecimiento matinal",
    mood: "Alegre",
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    body:
        "Hoy agradecí por las personas que me apoyan. Empecé el día con respiraciones conscientes.",
  ),
  DiaryEntry(
    id: "2",
    title: "Momento desafiante",
    mood: "Ansioso/a",
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    body:
        "Tuve una reunión compleja. Respiré profundo y anoté mis sensaciones para liberar tensión.",
  ),
];
