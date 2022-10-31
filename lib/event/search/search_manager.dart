import 'dart:collection';

import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/event/event.dart';

/// This Singlton object handles the search operation in the app. When it is
/// initialized, receiving the full list of events as input, the object fills in
/// a [SplayTreeMap], i.e. a self-balancing binary tree.
class SearchManager {
  /// Constructor definition.
  SearchManager._internal();

  static final SearchManager _searchManager = SearchManager._internal();

  /// This map creates a dictionary for every possible substring that each of
  /// the [Event] labels have, and uses a [Set] as a value, allowing for
  /// multiple entries to be stored for a single key.
  final SplayTreeMap<String, Set<Event>> _queryMapTarikh =
      SplayTreeMap<String, Set<Event>>();
  final SplayTreeMap<String, Set<Event>> _queryMapRelics =
      SplayTreeMap<String, Set<Event>>();

  /// Factory constructor that will perform the initialization, and return the
  /// reference the _searchManager (constructing it if called a first time).
  factory SearchManager.init([NavPage? navPage, List<Event>? events]) {
    if (events != null) _searchManager._fill(navPage!, events);
    return _searchManager;
  }

  /// Fill the map with all the possible searchable substrings. This operation
  /// is O(n^2), thus very slow, and performed only once upon initialization.
  _fill(NavPage navPage, List<Event> events) {
    final SplayTreeMap<String, Set<Event>> queryMap =
        navPage == NavPage.Tarikh ? _queryMapTarikh : _queryMapRelics;

    queryMap.clear(); // Sanity check, but needed for re-init on lang change

    for (Event event in events) {
      String label = event.tvTitle;
      // TODO we can also search for en/ar/other relic/filter types here
      int len = label.length;
      for (int i = 0; i < len; i++) {
        for (int j = i + 1; j <= len; j++) {
          String substring = label.substring(i, j).toLowerCase();
          if (queryMap.containsKey(substring)) {
            Set<Event> labels = queryMap[substring]!;
            labels.add(event);
          } else {
            queryMap.putIfAbsent(substring, () => {event});
          }
        }
      }
    }
  }

  /// Use the [SplayTreeMap] query function to return the full [Set] of results.
  /// This operation amortized logarithmic time.
  Set<Event> performSearch(NavPage navPage, String query) {
    final SplayTreeMap<String, Set<Event>> queryMap =
        navPage == NavPage.Tarikh ? _queryMapTarikh : _queryMapRelics;

    Set<Event> eventSet = {};

    if (queryMap.containsKey(query)) {
      return queryMap[query]!;
    } else if (query.isNotEmpty) {
      return eventSet;
    }

    Iterable<String> keys = queryMap.keys;
    for (String k in keys) {
      eventSet.addAll(queryMap[k]!);
    }
    return eventSet;
  }
}
