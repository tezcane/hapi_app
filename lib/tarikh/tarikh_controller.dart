import 'dart:async';

import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/tarikh/search_manager.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
import 'package:intl/intl.dart';

final TarikhController cTrkh = Get.find();

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

class TarikhController extends GetxController {
  static TarikhController get to => Get.find();

  static final Timeline t = Timeline();

  static const String FAVORITES_KEY = "TARIKH_FAVS";

  static final NumberFormat formatter = NumberFormat.compact();

  /// List of favorites shown on Tarikh_Favorites page
  final List<TimelineEntry> _favorites = [];
  List<TimelineEntry> get favorites => _favorites;

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
    int lastGutterModeIdx = s.read('lastGutterModeIdx') ?? GutterMode.OFF.index;
    gutterMode = GutterMode.values[lastGutterModeIdx];

    t.loadFromBundle().then(
      (List<TimelineEntry> entries) {
        t.setViewport(
          start: entries.first.start! * 2.0,
          end: entries.first.start!,
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

    super.onInit();
  }

  /// This method is called during the [BlocProvider] initialization.
  /// It receives as input the full list of [TimelineEntry], so that it can
  /// use those references to fill [_favorites].
  initFavorites(List<TimelineEntry> entries) async {
    List<dynamic>? favs = s.read(TarikhController.FAVORITES_KEY);

    /// A [Map] is used to optimize retrieval times when checking if a favorite
    /// is already present - in fact the label's used as the key.
    /// Checking if an element is in the map is O(1), making this process O(n)
    /// with n entries.
    Map<String, TimelineEntry> entriesMap = Map();
    for (TimelineEntry entry in entries) {
      entriesMap.putIfAbsent(entry.label!, () => entry);
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
      return a.start!.compareTo(b.start!);
    });
  }

  /// Save [e] into the list, re-sort it, and store to disk.
  addFavorite(TimelineEntry e) {
    if (!_favorites.contains(e)) {
      this._favorites.add(e);
      _favorites.sort((TimelineEntry a, TimelineEntry b) {
        return a.start!.compareTo(b.start!);
      });
      _saveFavorites();
    }
  }

  /// Remove the entry and save to disk.
  removeFavorite(TimelineEntry e) {
    if (_favorites.contains(e)) {
      this._favorites.remove(e);
      _saveFavorites();
    }
  }

  /// Persists the data to disk.
  _saveFavorites() {
    List<String> favsList =
        _favorites.map((TimelineEntry en) => en.label!).toList();
    s.write(TarikhController.FAVORITES_KEY, favsList);
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

  // TODO We update() in another thread or there is a render/build error:
  void updateOnThread() => Timer(const Duration(seconds: 0), () => update());

  int count = 0;
  TimeBtn getTimeBtn(TimelineEntry? entry, double opacity) {
    if (entry == null) {
      count++;
    }
    String title = '$count'; // these can't be blank because of FittedBox
    String timeUntil = ' ';
    String pageScrolls = ' ';

    if (entry != null && opacity > 0.0) {
      title = entry.label!;

      //was t.renderEnd, had 'page away 0' at bottom page edge, now in middle:
      double pageReference = (t.renderStart + t.renderEnd) / 2.0;
      double timeUntilDouble = entry.start! - pageReference;
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
