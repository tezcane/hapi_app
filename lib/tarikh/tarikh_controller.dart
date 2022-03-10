import 'package:get/get.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main.dart';
import 'package:hapi/tarikh/search_manager.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
import 'package:intl/intl.dart';

enum GutterMode {
  OFF,
  FAV,
  ALL,
}

/// Used for Timeline Up/Down Button data
class TimeBtn {
  TimeBtn({
    required this.title,
    required this.timeUntil,
    required this.pageScrolls,
    this.entry,
  });
  final String title;
  String timeUntil; // not final to allow updating these as page scrolls
  String pageScrolls;
  final TimelineEntry? entry;
}

class TarikhController extends GetxHapi {
  static TarikhController get to => Get.find();

  static late final Timeline t;

  static final NumberFormat formatter = NumberFormat.compact();

  /// Used to start/stop vignettes menu section animations
  bool _isSectionActive = true;
  get isSectionActive => _isSectionActive;
  restoreMenuSection() {
    _isSectionActive = true;
    update();
  }

  pauseMenuSection() {
    _isSectionActive = false;
    update();
  }

  /// List of favorite events shown on Tarikh_Favorites page and timeline gutter
  final List<TimelineEntry> _favorites = [];
  List<TimelineEntry> get favorites => _favorites;

  /// List of all history events for timeline gutter retrieval
  final List<TimelineEntry> _allEvents = [];
  List<TimelineEntry> get allEvents => _allEvents;

  /// Turn timeline gutter off/show favorites/show all history:
  final Rx<GutterMode> _gutterMode = GutterMode.OFF.obs;
  GutterMode get gutterMode => _gutterMode.value;
  set gutterMode(GutterMode newGutterMode) {
    s.write('lastGutterModeIdx', newGutterMode.index);
    _gutterMode.value = newGutterMode;
    update();
  }

  final Rx<TimeBtn> timeBtnUp =
      TimeBtn(title: ' ', timeUntil: ' ', pageScrolls: ' ').obs;
  final Rx<TimeBtn> timeBtnDn =
      TimeBtn(title: ' ', timeUntil: ' ', pageScrolls: ' ').obs;

  @override
  void onInit() {
    super.onInit();

    t = Timeline();

    int lastGutterModeIdx = s.read('lastGutterModeIdx') ?? GutterMode.OFF.index;
    gutterMode = GutterMode.values[lastGutterModeIdx];

    t.loadFromBundle().then(
      (List<TimelineEntry> entries) {
        t.setViewport(
          start: entries.first.start * 2.0,
          end: entries.first.start,
          animate: true,
        );

        /// Advance the timeline to its starting position.
        t.advance(0.0, false);

        /// All the entries are loaded, we can fill in the [favoritesBloc]...
        initFavorites(entries);

        /// ...and initialize the [SearchManager].
        SearchManager.init(entries);

        // /// initialize up down buttons
        // timeBtnUp.value = getTimeBtn(t.prevEntry, t.prevEntryOpacity);
        // timeBtnDn.value = getTimeBtn(t.nextEntry, t.nextEntryOpacity);
      },
    );
  }

  /// This method is called during the [BlocProvider] initialization.
  /// It receives as input the full list of [TimelineEntry], so that it can
  /// use those references to fill [_favorites].
  initFavorites(List<TimelineEntry> entries) async {
    List<dynamic>? favs = s.read("TARIKH_FAVS");

    /// A [Map] is used to optimize retrieval times when checking if a favorite
    /// is already present - in fact the label's used as the key.
    /// Checking if an element is in the map is O(1), making this process O(n)
    /// with n entries.
    Map<String, TimelineEntry> entriesMap = {};
    for (TimelineEntry entry in entries) {
      entriesMap.putIfAbsent(entry.label, () => entry);
      _allEvents.add(entry); // TODO sort this needed? being done in paint...
    }

    if (favs != null) {
      for (String fav in favs) {
        TimelineEntry? entry = entriesMap[fav];
        if (entry != null) {
          _favorites.add(entry);
        }
      }
    }

    /// Sort by starting time, so the favorites' list is always displayed in ascending order.
    _favorites.sort((TimelineEntry a, TimelineEntry b) {
      return a.start.compareTo(b.start);
    });
  }

  /// Save [e] into the list, re-sort it, and store to disk.
  addFavorite(TimelineEntry e) {
    if (!_favorites.contains(e)) {
      _favorites.add(e);
      _favorites.sort((TimelineEntry a, TimelineEntry b) {
        return a.start.compareTo(b.start);
      });
      _saveFavorites();
    }
  }

  /// Remove the entry and save to disk.
  removeFavorite(TimelineEntry e) {
    if (_favorites.contains(e)) {
      _favorites.remove(e);
      _saveFavorites();
    }
  }

  /// Persists the data to disk.
  _saveFavorites() {
    List<String> favsList =
        _favorites.map((TimelineEntry entry) => entry.label).toList();
    s.write("TARIKH_FAVS", favsList);
    update(); // favorites changed so notify people using it
  }

  bool isGutterModeOff() => _gutterMode.value == GutterMode.OFF;
  bool isGutterModeFav() => _gutterMode.value == GutterMode.FAV;
  bool isGutterModeAll() => _gutterMode.value == GutterMode.ALL;

  void setTBtnUp(TimeBtn timeBtn) {
    timeBtnUp.value = timeBtn;
    updateOnThread();
  }

  void setTBtnDn(TimeBtn timeBtn) {
    timeBtnDn.value = timeBtn;
    updateOnThread();
  }

  void updateTBtnUp(String timeUntil, String pageScrolls) {
    timeBtnUp.value.timeUntil = timeUntil;
    timeBtnUp.value.pageScrolls = pageScrolls;
    updateOnThread();
  }

  void updateTBtnDn(String timeUntil, String pageScrolls) {
    timeBtnDn.value.timeUntil = timeUntil;
    timeBtnDn.value.pageScrolls = pageScrolls;
    updateOnThread();
  }

  int count = 0;
  TimeBtn getTimeBtn(TimelineEntry? entry, double opacity) {
    if (entry == null) {
      count++;
    }
    String title = '$count'; // these can't be blank because of FittedBox
    String timeUntil = ' ';
    String pageScrolls = ' ';

    if (entry != null && opacity > 0.0) {
      title = entry.label;

      //was t.renderEnd, had 'page away 0' at bottom page edge, now in middle:
      double pageReference = (t.renderStart + t.renderEnd) / 2.0;
      double timeUntilDouble = entry.start - pageReference;
      timeUntil = TimelineEntry.formatYears(timeUntilDouble).toLowerCase();

      double pageSize = t.renderEnd - t.renderStart;
      double pages = timeUntilDouble / pageSize;
      pageScrolls = '${formatter.format(pages.abs())} pages away';
    }

    return TimeBtn(
      title: title,
      timeUntil: timeUntil,
      pageScrolls: pageScrolls,
      entry: entry,
    );
  }
}
