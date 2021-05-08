import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/globals.dart';
import 'package:hapi/tarikh/search_manager.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

final TarikhController cTrkh = Get.find();

class TarikhController extends GetxController {
  static TarikhController get to => Get.find();

  static const String FAVORITES_KEY = "TARIKH_FAVS";

  final List<TimelineEntry> _favorites = [];

  late final Timeline _timeline;

  @override
  void onInit() {
    _timeline = Timeline();
    _timeline
        .loadFromBundle('assets/tarikh/timeline.json')
        .then((List<TimelineEntry> entries) {
      _timeline.setViewport(
          start: entries.first.start! * 2.0,
          end: entries.first.start!,
          animate: true);

      /// Advance the timeline to its starting position.
      _timeline.advance(0.0, false);

      /// All the entries are loaded, we can fill in the [favoritesBloc]...
      initFavorites(entries);

      /// ...and initialize the [SearchManager].
      SearchManager.init(entries);
    });

    super.onInit();
  }

  Timeline get timeline => _timeline;
  set timeline(Timeline value) {
    if (_timeline == value) {
      return;
    }
    _timeline = value;
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
      _save();
    }
  }

  /// Remove the entry and save to disk.
  removeFavorite(TimelineEntry e) {
    if (_favorites.contains(e)) {
      this._favorites.remove(e);
      _save();
    }
  }

  /// Persists the data to disk.
  _save() {
    List<String> favsList =
        _favorites.map((TimelineEntry en) => en.label!).toList();
    s.write(TarikhController.FAVORITES_KEY, favsList);
    update(); // favorites changed so notify people using it
  }
}
