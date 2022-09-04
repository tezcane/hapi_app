import 'package:hapi/main_controller.dart';
import 'package:hapi/quran/quran.dart';
import 'package:hapi/relic/relic.dart';

class Prophet extends Relic {
  Prophet(
      String category,
      String trKeyEndTag,
      String? dateEra,
      int? dateBegin,
      int? dateEnd,
      this.mentionsInQuran,
      this.sentTo,
      // this.quranVerses,
      this.nabi, {
        this.rasul,
        this.ulualazm,
        this.nameLatin,
        this.trKeyNameNicknamesAr,
        this.locationBirth,
        this.locationDeath,
        this.tomb,
        this.predecessorAr,
        this.successorAr,
        this.motherAr,
        this.fatherAr,
        this.spousesAr,
        this.childrenAr,
        this.relativesAr,
        this.kitabAr,
        this.livedDuring,
      }) : super(category, trKeyEndTag, a('a.$trKeyEndTag'), 'ps.$trKeyEndTag', 'pq.$trKeyEndTag', dateEra, dateBegin, dateEnd);
  // Prophet (nabī) نَبِيّ	Messenger (rasūl) رَسُول
  // Archprophet (ʾulu al-'azm)
  final int mentionsInQuran;
  final String sentTo;
  // final List<QV> quranVerses;
  final QV nabi;

  final QV? rasul;
  final List<QV>? ulualazm;
  final String? nameLatin;
  final List<String>? trKeyNameNicknamesAr;
  final String? locationBirth;
  final String? locationDeath;
  final String? tomb;
  final String? predecessorAr;
  final String? successorAr;
  final String? motherAr;
  final String? fatherAr;
  final List<String>? spousesAr;
  final List<String>? childrenAr;
  final List<String>? relativesAr;
  final String? kitabAr;
  final String? livedDuring;
}

List<Prophet> prophets = [];
initProphets() {
  prophets.add(Prophet('Prophet', 'Adam', 'p.Birth of humanity', -3400000, -3399050, 25, 'p.Earth (4:1)', QV(2,31), rasul: QV(2,31), nameLatin: 'Adam', locationBirth: 'a.Jennah', locationDeath: '', tomb: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: ['p.Hawwa'], childrenAr: ['p.Habel', 'p.Qabel', 'p.Sheth'], relativesAr: [], kitabAr: '―', livedDuring: 'Birth of humanity'));
  prophets.add(Prophet('Prophet', 'Idris', '?', null, null, 2, 'p.Babylon', QV(19,56), nameLatin: 'Enoch', locationBirth: 'p.Babylon', locationDeath: 'p.Hebron, Shaam', tomb: 'Ibrahimi Mosque, Hebron', predecessorAr: 'p.Sheth', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: ["p.'Anaq'"], relativesAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Nuh', 'p.Great Flood', null, null, 43, 'p.The people of Noah (26:105)', QV(6,89), rasul: QV(25,107), ulualazm: [QV(46, 35), QV(33,7)], nameLatin: 'Noah', locationBirth: '', locationDeath: '', tomb: '', predecessorAr: 'p.Idris', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: [], kitabAr: '―', livedDuring: 'Great Flood'));
  prophets.add(Prophet('Prophet', 'Hud', '?', -2400, null, 7, 'p.Ad tribe (7:65)', QV(26,125), rasul: QV(26,125), locationBirth: '', locationDeath: '', tomb: '', predecessorAr: 'p.Nuh', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [        'p.Shem', 'p.Ham', 'p.Yam', 'p.Japheth'], relativesAr: [], kitabAr: '―', livedDuring: 'c. 2400 BC[78]'));
  prophets.add(Prophet('Prophet', 'Saleh', '?', null, null, 9, 'p.Thamud tribe (7:73)', QV(26,143), rasul: QV(26,143), nameLatin: 'Selah', locationBirth: '', locationDeath: '', tomb: 'Hasik (present day Oman)', predecessorAr: 'p.Hud', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: ['Thamud'], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Ibrahim', 'p.Migration of the Jews to Iraq', null, null, 69, 'p.Babylon, The people of Iraq & Syria (22:43)', QV(19,41), rasul: QV(9,70), ulualazm: [QV(2,124)], nameLatin: 'Abraham', trKeyNameNicknamesAr: ['a.Khalīlullāh'], locationBirth: 'p.Ur al-Chaldees, Bilād ar-Rāfidayn', locationDeath: 'p.Hebron, Shaam', tomb: 'Ibrahimi Mosque, Hebron', predecessorAr: '', successorAr: 'p.', motherAr: 'p.Mahalath', fatherAr: 'p.Aazar', spousesAr: [''], childrenAr: [], relativesAr: ['Lut (nephew)'], kitabAr: 'Scrolls of Abraham (87:19)', livedDuring: 'Migration of the Jews to Iraq'));
  prophets.add(Prophet('Prophet', 'Lut', '?', null, null, 27, 'p.Sodom and Gomorrah (7:80)', QV(6,86), rasul: QV(37,133), nameLatin: 'Lot', locationBirth: '', locationDeath: "p.Bani Na'im", tomb: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.Haran', spousesAr: [''], childrenAr: ["p.Isma'il", 'p.Isḥaq'], relativesAr: [        'Ibrahim (uncle)'], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Ismail', '?', -1800, -1664, 12, 'p.Pre-Islamic Arabia (Mecca)', QV(19,54), rasul: QV(19,54), nameLatin: 'Ishmael', locationBirth: 'p.Palestine/Canaan', locationDeath: 'p.Age 136, Mecca, Arabia', tomb: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.Hajar', fatherAr: 'p.Ibrahim', spousesAr: [''], childrenAr: [], relativesAr: ["Is'haq (half-brother)"], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Ishaq', '?', null, null, 17, 'p.Palestine/Canaan', QV(19,49), nameLatin: 'Isaac', locationBirth: '', locationDeath: '', tomb: 'Cave of the Patriarchs, Hebron', predecessorAr: '', successorAr: 'p.', motherAr: 'p.Sarah', fatherAr: 'p.Ibrahim', spousesAr: [''], childrenAr: ['Children of Isma‘il (Arabs)'], relativesAr: ['Ismail (half-brother)', 'forefather of the Twelve Tribes of Israel'], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Yaqub', 'p.Twelve Tribes of Israel', null, null, 16, 'p.Palestine/Canaan', QV(19,49), nameLatin: 'Jacob', trKeyNameNicknamesAr: ['a.Israel'], locationBirth: '', locationDeath: '', tomb: 'Cave of the Patriarchs, Hebron', predecessorAr: '', successorAr: 'p.', motherAr: 'p.Rafeqa', fatherAr: 'p.Ishaaq', spousesAr: [''], childrenAr: ['p.Yaqub', 'p.Esau'], relativesAr: [], kitabAr: '―', livedDuring: 'Twelve Tribes of Israel'));
  prophets.add(Prophet('Prophet', 'Yusuf', '?', null, null, 27, 'p.Ancient Kingdom of Egypt', QV(4,89), rasul: QV(40,34), nameLatin: 'Joseph', locationBirth: '', locationDeath: '', tomb: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.Rahil', fatherAr: 'p.Yaqub', spousesAr: [''], childrenAr: ['p.Yusuf', 'p.Benyamýn', '10 others'], relativesAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Ayyub', '?', null, null, 4, 'p.Edom', QV(4,89), nameLatin: 'Job', locationBirth: '', locationDeath: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', "Shu'ayb", '?', null, null, 9, 'p.Midian (7:85)', QV(26,178), rasul: QV(26,178), locationBirth: '', locationDeath: '', tomb: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Musa', 'p.Ancient Pharaoh Kingdoms Of Egypt', -1300, -1200, 136, 'p.Egypt Pharaoh and his establishment (43:46)', QV(20,47), rasul: QV(20,47), ulualazm: [QV(46,35), QV(33,7)], nameLatin: 'Moses', locationBirth: '', locationDeath: '', tomb: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: ['Harun (Brother)'], kitabAr: 'Ten Commandments, Tawrah (Torah); Scrolls of Moses (53:36)', livedDuring: 'c. 1400s BCE – c. 1300s BCE, or c. 1300s BCE – c. 1200s BCE'));
  prophets.add(Prophet('Prophet', 'Harun', '?', -1300, -1200, 20, 'p.Egypt Pharaoh and his establishment (43:46)', QV(19,53), rasul: QV(20,47), nameLatin: 'Aaron', locationBirth: '', locationDeath: '', tomb: '', predecessorAr: 'p.Musa', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: ['Musa (Brother)'], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Dawud', 'p.King of Israel', -1000, -971, 16, 'p.Jerusalem', QV(6,89), rasul: QV(6,89), nameLatin: 'David', locationBirth: '', locationDeath: '', tomb: '"Tomb of Aaron', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: [], kitabAr: 'Zabur (Psalms) (17:55, 4:163, 17:55, 21:105)', livedDuring: 'c. 1000s BCE – c. 971 BCE'));
  prophets.add(Prophet('Prophet', 'Sulayman', 'p.King of Israel', -971, -931, 17, 'p.Jerusalem', QV(6,89), nameLatin: 'Solomon', locationBirth: 'p.Jerusalem, Kingdom of Israel', locationDeath: 'p.Jerusalem, Kingdom of Israel', tomb: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.Dāwūd', spousesAr: [''], childrenAr: [], relativesAr: [], kitabAr: '―', livedDuring: 'c. 971 BCE – c. 931 BCE'));
  prophets.add(Prophet('Prophet', 'Ilyas', '?', null, null, 2, 'p.Sumaria, The people of Ilyas (37:124)', QV(6,89), rasul: QV(37,123), nameLatin: 'Elijah', locationBirth: '', locationDeath: '', tomb: 'A 14th-century shrine built on top of the supposed grave of Aaron on Jabal Hārūn near Petra, Jordan', predecessorAr: 'p.Suleyman', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Alyasa', '?', null, null, 2, 'p.Samaria, Eastern Arabia, & Persia', QV(6,89), nameLatin: 'Elisha', locationBirth: '', locationDeath: '', tomb: 'According to one Islamic tradition, the tomb of Aaron is located on Jabal Harun (Arabic: جَـبـل هَـارون, Mountain of Aaron), near Petra in Jordan, with another tradition placing it in Sinai.', predecessorAr: 'p.Ilyas', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Yunus', '?', null, null, 4, 'p.Ninevah, The people of Yunus (10:98)', QV(6,89), rasul: QV(37,139), nameLatin: 'Jonah', locationBirth: '', locationDeath: '', tomb: '', predecessorAr: 'p.Alyasa', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.Amittai', spousesAr: [''], childrenAr: [], relativesAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Dhu al-Kifl', '?', null, null, 2, 'p.Babylon', QV(21, 85,ayaEnd: 86), nameLatin: 'Ezekiel?, Buddha?, Joshua?, Obadiah?, Isaiah?', locationBirth: '', locationDeath: '', tomb: 'At 1,350.0 m (4,429.1 feet) above sea-level, Jabal Hārūn is the highest peak in the area and a place of great sanctity to the local people. A 14th-century Mamluk mosque stands there with its white dome visible from most areas in and around Petra."', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Zakariyya', '?', null, null, 7, 'p.Jerusalem', QV(6,89), nameLatin: 'Zechariah', locationBirth: '', locationDeath: '', tomb: '', predecessorAr: '', successorAr: 'p.', motherAr: 'p.', fatherAr: 'p.', spousesAr: [''], childrenAr: [], relativesAr: [], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Yahya', '?', null, null, 5, 'p.Jerusalem', QV(3,39), nameLatin: 'John', locationBirth: '', locationDeath: '', predecessorAr: 'p.Zakariya', successorAr: 'p.', motherAr: 'p.Elizabeth', fatherAr: 'p.Zakariya', spousesAr: [''], childrenAr: [], relativesAr: ['Isa (cousin)'], kitabAr: '―', livedDuring: '?'));
  prophets.add(Prophet('Prophet', 'Isa', '?', -4, 30, 25, 'p.Banu Israel, The Children of Israel (61:6)', QV(19,30), rasul: QV(4,171), ulualazm: [QV(42, 13)], nameLatin: 'Jesus', trKeyNameNicknamesAr: ['a.Masih'], locationBirth: 'p.Judea, Roman Empire', locationDeath: 'p.Age 33, Raised to Heaven in 30 CE, Gethsemane, Jerusalem, Roman Empire', tomb: 'Al-Ḥaram ash-Sharīf, Jerusalem', predecessorAr: 'p.Yahya', successorAr: 'p.', motherAr: 'p.Maryam', fatherAr: 'p.i.None', spousesAr: [''], childrenAr: [], relativesAr: ['Zakariyya (uncle)', 'Yahya (cousin)'], kitabAr: 'Injil (Gospel) (57:27)', livedDuring: 'c. 4 BCE – c. 30 CE'));
  prophets.add(Prophet('Prophet', 'Muhammad', '?', 570, 632, 4, 'p.All humanity and jinn (21:107)', QV(33,40), rasul: QV(33,40), ulualazm: [QV(2,124)], trKeyNameNicknamesAr: ['a.Khātam al-Nabiyyīn', 'a.Ahmad','a.Al-Mahi','a.al-Hashir','a.Al-Aqib','a.al-Nabī','a.Rasūl’Allāh','a.al-Ḥabīb','a.Ḥabīb Allāh',"a.al-Raḥmah lil-'Ālamīn",'a.An-Nabiyyu l-Ummiyy','a.Mustafa'], locationBirth: at("at.{0}, 12 Rabi' al-Awwal 53 BH (570 CE), Mecca, Hejaz, Arabia", ['a.Aliathnayn']), locationDeath: at("at.{0} 12 Rabi' al-Awwal 11 AH (8 June 632 CE), Medina, Hejaz, Arabia", ['a.Aliathnayn']), tomb: '', predecessorAr: 'p.Isa', successorAr: 'p.', motherAr: 'p.Amina bint Wahb', fatherAr: 'p.Abd Allah ibn Abd al-Muttalib', spousesAr: [''], childrenAr: ['Al-Qasim (598–601)', 'Zainab (599–629)', 'Ruqayyah (601–624)', 'Umm Kulthum (603–630)', 'Fatimah (605–632)', 'Abdullah (611–613)', 'Ibrahim 630–632)'], relativesAr: [], kitabAr: 'Quran (42:7)', livedDuring: '571 – 632'));
}