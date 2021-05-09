import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/tarikh/search_manager.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

final TarikhController cTrkh = Get.find();

enum GutterMode {
  OFF,
  FAV,
  ALL,
}

/// Timeline Up Down Button
class TimeBtn {
  TimeBtn({
    required this.title,
    required this.timeUntil,
    required this.pageScrolls,
    required this.color,
    this.entry,
  });
  final String title;
  final String timeUntil;
  final String pageScrolls;
  final Color color;
  final TimelineEntry? entry;
}

class TarikhController extends GetxController {
  static TarikhController get to => Get.find();

  static const String FAVORITES_KEY = "TARIKH_FAVS";

  /// List of favorites shown on Tarikh_Favorites page
  final List<TimelineEntry> _favorites = [];

  /// Turn timerline gutter off/show favorites/show all history:
  Rx<GutterMode> _gutterMode = GutterMode.OFF.obs;
  late Rx<TimeBtn> timeBtnUp;
  late Rx<TimeBtn> timeBtnDn;

  late final Timeline _t;

  Timeline get t => _t; // TODO rename to t

  @override
  void onInit() {
    int lastGutterModeIdx = s.read('lastGutterModeIdx') ?? GutterMode.OFF.index;
    gutterMode = GutterMode.values[lastGutterModeIdx];

    _t = Timeline();
    t
        .loadFromBundle('assets/tarikh/timeline.json')
        .then((List<TimelineEntry> entries) {
      t.setViewport(
          start: entries.first.start! * 2.0,
          end: entries.first.start!,
          animate: true);

      /// Advance the timeline to its starting position.
      t.advance(0.0, false);

      /// initialize up down buttons
      timeBtnUp = t.getTimeBtn(t.prevEntry, t.prevEntryOpacity).obs;
      timeBtnDn = t.getTimeBtn(t.nextEntry, t.nextEntryOpacity).obs;

      /// All the entries are loaded, we can fill in the [favoritesBloc]...
      initFavorites(entries);

      /// ...and initialize the [SearchManager].
      SearchManager.init(entries);
    });

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

  List<TimelineEntry> get favorites {
    return _favorites;
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

  GutterMode get gutterMode => _gutterMode.value;
  bool get isGutterModeOff => _gutterMode.value == GutterMode.OFF;
  bool get isGutterModeFav => _gutterMode.value == GutterMode.FAV;
  bool get isGutterModeAll => _gutterMode.value == GutterMode.ALL;
  set gutterMode(GutterMode newGutterMode) {
    s.write('lastGutterModeIdx', newGutterMode.index);
    _gutterMode.value = newGutterMode;
    update();
  }

  void setTBtnUp(TimeBtn timeBtn) {
    this.timeBtnUp.value = timeBtn;
    //update();
  }

  void setTBtnDn(TimeBtn timeBtn) {
    this.timeBtnDn.value = timeBtn;
    //update();
  }
}
