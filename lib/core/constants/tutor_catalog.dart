import '../../models/tutor_profile.dart';

class TutorCatalog {
  const TutorCatalog._();

  static const List<TutorProfile> tutors = <TutorProfile>[
    TutorProfile(
      subject: 'Biyoloji',
      tutorName: 'Biyoloji Eğitmeni',
      assetPath: 'assets/tutors/Biyoloji Man.png',
      lessonTitles: <String>[
        'Hücre ve Organeller',
        'DNA ve Kalıtım',
        'Ekosistem ve Madde Döngüsü',
      ],
    ),
    TutorProfile(
      subject: 'Coğrafya',
      tutorName: 'Coğrafya Eğitmeni',
      assetPath: 'assets/tutors/Coğrafya Women.png',
      lessonTitles: <String>[
        'Harita Bilgisi',
        'İklim Tipleri',
        'Türkiye Coğrafi Bölgeleri',
      ],
    ),
    TutorProfile(
      subject: 'Edebiyat',
      tutorName: 'Edebiyat Eğitmeni',
      assetPath: 'assets/tutors/Edebiyat Woman.png',
      lessonTitles: <String>[
        'Söz Sanatları',
        'Şiir Türleri',
        'Cumhuriyet Dönemi Edebiyatı',
      ],
    ),
    TutorProfile(
      subject: 'Felsefe',
      tutorName: 'Felsefe Eğitmeni',
      assetPath: 'assets/tutors/Felsefe Woman.png',
      lessonTitles: <String>[
        'Bilgi Felsefesi',
        'Ahlak Felsefesi',
        'Varlık Felsefesi',
      ],
    ),
    TutorProfile(
      subject: 'Fizik',
      tutorName: 'Fizik Eğitmeni',
      assetPath: 'assets/tutors/Fizik Woman.png',
      lessonTitles: <String>[
        'Hareket ve Kuvvet',
        'Enerji ve İş',
        'Elektrik ve Manyetizma',
      ],
    ),
    TutorProfile(
      subject: 'Geometri',
      tutorName: 'Geometri Eğitmeni',
      assetPath: 'assets/tutors/Geometri Man.png',
      lessonTitles: <String>['Üçgenler', 'Çokgenler', 'Analitik Geometri'],
    ),
    TutorProfile(
      subject: 'İngilizce',
      tutorName: 'İngilizce Eğitmeni',
      assetPath: 'assets/tutors/İngilizce Man.png',
      lessonTitles: <String>[
        'Tenses',
        'Reading Comprehension',
        'Sentence Transformation',
      ],
    ),
    TutorProfile(
      subject: 'Kimya',
      tutorName: 'Kimya Eğitmeni',
      assetPath: 'assets/tutors/Kimya Woman.png',
      lessonTitles: <String>[
        'Atom ve Periyodik Sistem',
        'Kimyasal Tepkimeler',
        'Asitler, Bazlar, Tuzlar',
      ],
    ),
    TutorProfile(
      subject: 'Tarih',
      tutorName: 'Tarih Eğitmeni',
      assetPath: 'assets/tutors/Tarih Woman.png',
      lessonTitles: <String>[
        'İlk Türk Devletleri',
        'Osmanlı Yükselme Dönemi',
        'Kurtuluş Savaşı',
      ],
    ),
  ];
}
