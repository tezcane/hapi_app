/// ET = EVENT TYPE
///
/// NOTE: We moved ET here because we need to call it from the command line
///       program [update_localizations.dart] and those don't support code that
///       even import UI libraries ([event.dart] and even [EtExtension.dart] has
///       links to UI code).
///
/// Tell certain UIs (Timeline/Relic views) what type(s) of events to use. This
/// Name is used to init tarikh and relic events, get tk keys to translate, used
/// to index the database maps storing ajrLevels, etc.
///
/// NOTE: After adding a new ET, you must update:
///   - [EtExtension.dart], the enum extension on ET
///   - add "assets/i18n/event/<ET.name.toLowerCase()>/" to pubspec.yaml assets
///   - add "assets/i18n/event/<ET.name.toLowerCase()>/" directory
///   - add translations to online translation spreadsheet,
///   - Then run "dart update_localizations.dart" (auto-builds from ET.values)
enum ET {
//   // LEADERS
//   Al_Asma_ul_Husna, // اَلاسْمَاءُ الْحُسناى TODO all names mentioned in Quran? AsmaUlHusna - 99 names of allah
  Nabi, // Prophets TODO non-Quran mentioned prophets
//   Muhammad, // Laqab, Family Tree here?
//   Righteous, // People: Mentioned in Quran/possible prophets/Sahabah/Promised Jannah
//
//   //ISLAM
//   Delil, //Quran,Sunnah,Nature,Ruins // See "Miracles of Quran" at bottom of file
//   Tenets, // Islam_5Pillars/6ArticlesOfFaith
//   Jannah, // Doors/Levels/Beings(Insan,Angels,Jinn,Hurlieen,Servants,Burak)
// //Heaven_LevelsOfHell,
//
//   //ACADEMIC
//   Scriptures, //  Hadith Books/Quran/Injil/Torah/Zabur/Scrolls of X/Talmud?
  Surah, // Mecca/Medina/Revelation Date/Ayat Length/Quran Order
//   Scholars, // Tabieen, TabiTabieen, Ulama (ImamAzam,Madhab+ Tirmidihi, Ibn Taymiyah), Dai (Givers of Dawah),
//   Relics, // Kaba, black stone, Prophets Bow, Musa Staff, Yusuf Turban, etc. Coins?
//   Quran_Mentions, // Tribes, Animals, Foods, People (disbelievers)
//   Arabic, // Alphabet (Muqattaʿat letters 14 of 28: ʾalif أ, hā هـ, ḥā ح, ṭā ط, yā ي, kāf ك, lām ل, mīm م, nūn ن, sīn س, ʿain ع, ṣād ص, qāf ق, rā ر.)
//
//   // Ummah
//   Amir, // Khalif/Generals
//   Muslims, // alive/dead, AlBayt (Zojah, Children), Famous (Malcom X, Mike Tyson, Shaqeel Oneil), // Amirs/Khalif not in Dynasties, Athletes,
//   Places, // HolyPlaces, Mosques, Schools, Cities  (old or new), mentioned in the Quran,Ruins, Conquered or not, Istanbul, Rome
//
//   // Dynasties (Leaders/Historical Events/Battles)
//   Dynasties, // Muhammad, Rashidun, Ummayad, Andalus, Abbasid, Seljuk, Ayyubi, Mamluk, Ottoman,
//   Rasulallah, //Muhammad Battles (Badr, Uhud, etc.)
//   Rashidun,
//   Ummayad,
//   Andalus,
//   Abbasid,
//   Seljuk,
//   Ayyubi,
//   Mamluk,
//   Ottoman,

  /// Originally timeline.json events. TODO Some will turn into relics but many
  /// will not need db storage so we put it last to avoid gaps in ET.index to
  /// simplify relic/db index init and lookups.
  Tarikh, // Single event/incident in history (uses "date" in input)
}
