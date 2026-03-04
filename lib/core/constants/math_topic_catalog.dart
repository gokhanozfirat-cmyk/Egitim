class MathTopicCatalog {
  const MathTopicCatalog._();

  static const List<String> lgs = <String>[
    'Carpanlar ve Katlar',
    'Uslu Ifadeler',
    'Karekoklu Ifadeler',
    'Veri Analizi',
    'Basit Olaylarin Olma Olasiligi',
    'Cebirsel Ifadeler ve Ozdeslikler',
    'Dogrusal Denklemler',
    'Esitsizlikler',
    'Ucgenler',
    'Eslik ve Benzerlik',
    'Donusum Geometrisi',
    'Geometrik Cisimler',
  ];

  static const List<String> tyt = <String>[
    'Sayi Kumesi ve Cesitleri',
    'Bolme ve Bolunebilme Kurallari',
    'EBOB - EKOK',
    'Rasyonel Sayilar',
    'Birinci Dereceden Denklemler',
    'Basit Esitsizlikler',
    'Mutlak Deger',
    'Uslu Sayilar',
    'Koklu Sayilar',
    'Carpanlara Ayirma',
    'Oran - Oranti',
    'Problemler',
    'Kumeler ve Kartezyen Carpim',
    'Fonksiyonlar',
    'Polinomlar',
    'Ikinci Dereceden Denklemler',
    'Permutasyon - Kombinasyon',
    'Binom - Olasilik',
    'Veri ve Istatistik',
  ];

  static const List<String> ayt = <String>[
    'Karmasik Sayilar',
    'Ikinci Dereceden Esitsizlikler',
    'Logaritma',
    'Diziler',
    'Trigonometri',
    'Limit ve Sureklilik',
    'Turev',
    'Integral',
  ];

  static const List<String> kpss = <String>[
    'Temel Kavramlar ve Sayilar',
    'Bolme - Bolunebilme',
    'Asal Carpanlar ve EBOB-EKOK',
    'Rasyonel Sayilar',
    'Ondalik Sayilar',
    'Basit Esitsizlikler',
    'Mutlak Deger',
    'Uslu Sayilar',
    'Koklu Sayilar',
    'Carpanlara Ayirma',
    'Denklemler',
    'Oran - Oranti',
    'Problemler',
    'Kumeler',
    'Islem ve Moduler Aritmetik',
    'Permutasyon - Kombinasyon ve Olasilik',
    'Grafik Yorumlama',
    'Sayisal Mantik ve Akil Yurutme',
  ];

  static const List<String> ales = <String>[
    'Temel Kavramlar ve Cozumleme',
    'Bolme ve Bolunebilme',
    'Asal Carpanlar, EBOB-EKOK',
    'Rasyonel Sayilar ve Siralama',
    'Birinci Dereceden Denklemler',
    'Uslu Sayilar',
    'Koklu Sayilar',
    'Ozdeslikler ve Carpanlara Ayirma',
    'Oran - Oranti',
    'Sayi ve Kesir Problemleri',
    'Yas Problemleri',
    'Isci ve Havuz Problemleri',
    'Hareket Problemleri',
    'Yuzde, Kar-Zarar ve Faiz Problemleri',
    'Karisim Problemleri',
    'Kumeler ve Islem',
    'Sayisal Mantik',
    'Permutasyon, Kombinasyon ve Olasilik',
  ];

  static List<String> topicsForExam(String examName) {
    switch (examName.trim()) {
      case 'LGS':
        return lgs;
      case 'TYT':
      case 'YDT':
        return tyt;
      case 'AYT':
        return <String>[...tyt, ...ayt];
      case 'KPSS Lisans':
        return kpss;
      case 'ALES':
        return ales;
      default:
        return tyt;
    }
  }
}
