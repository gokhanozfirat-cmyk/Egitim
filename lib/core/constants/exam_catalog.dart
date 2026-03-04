import '../../models/exam.dart';

class ExamCatalog {
  const ExamCatalog._();

  static const List<Exam> exams = <Exam>[
    Exam(
      name: 'LGS',
      subjects: <String>[
        'Türkçe',
        'Matematik',
        'Fen Bilimleri',
        'T.C. İnkılap Tarihi ve Atatürkçülük',
        'Din Kültürü ve Ahlak Bilgisi',
        'İngilizce',
      ],
    ),
    Exam(
      name: 'TYT',
      subjects: <String>[
        'Türkçe',
        'Temel Matematik',
        'Geometri',
        'Fizik',
        'Kimya',
        'Biyoloji',
        'Tarih',
        'Coğrafya',
        'Felsefe',
        'Din Kültürü ve Ahlak Bilgisi',
      ],
    ),
    Exam(
      name: 'AYT',
      subjects: <String>[
        'Matematik',
        'Geometri',
        'Fizik',
        'Kimya',
        'Biyoloji',
        'Türk Dili ve Edebiyatı',
        'Tarih-1',
        'Coğrafya-1',
        'Tarih-2',
        'Coğrafya-2',
        'Felsefe Grubu (Felsefe, Psikoloji, Sosyoloji, Mantık)',
        'Din Kültürü ve Ahlak Bilgisi',
      ],
    ),
    Exam(
      name: 'YDT',
      subjects: <String>[
        'İngilizce',
        'Almanca',
        'Fransızca',
        'Arapça',
        'Rusça',
      ],
    ),
    Exam(
      name: 'KPSS Lisans',
      subjects: <String>[
        'Türkçe',
        'Matematik',
        'Geometri',
        'Sayısal Mantık',
        'Sözel Mantık',
        'Tarih',
        'Coğrafya',
        'Vatandaşlık',
        'Güncel Bilgiler',
      ],
    ),
    Exam(
      name: 'ALES',
      subjects: <String>[
        'Sayısal-1 (Temel Matematik)',
        'Sayısal-2 (Geometri ve İleri Matematik)',
        'Sayısal Mantık',
        'Sözel-1 (Türkçe / Anlam Bilgisi)',
        'Sözel-2 (Dil Bilgisi ve Muhakeme)',
        'Sözel Mantık',
      ],
    ),
  ];
}
