import 'dart:collection';

import 'package:hapi/main_c.dart';
import 'package:hapi/tarikh/event/event.dart';

/// This object handles the search operation in the app. When it is initialized,
/// receiving the full list of events as input, the object fills in a [SplayTreeMap],
/// i.e. a self-balancing binary tree.
class SearchManager {
  static final SearchManager _searchManager = SearchManager._internal();

  /// This map creates a dictionary for every possible substring that each of the
  /// [Event] labels have, and uses a [Set] as a value, allowing for multiple
  /// entires to be stored for a single key.
  final SplayTreeMap<String, Set<Event>> _queryMap =
      SplayTreeMap<String, Set<Event>>();

  /// Constructor definition.
  SearchManager._internal();

  /// Factory constructor that will perform the initialization, and return the reference
  /// the _searchManager (constructing it if called a first time.).
  factory SearchManager.init([List<Event>? events]) {
    if (events != null) {
      _searchManager._fill(events);
    }
    return _searchManager;
  }

  _fill(List<Event> events) {
    /// Sanity check.
    _queryMap.clear();

    /// Fill the map with all the possible searchable substrings.
    /// This operation is O(n^2), thus very slow, and performed only once upon initialization.
    for (Event event in events) {
      String label = a(event.trKeyTitle);
      int len = label.length;
      for (int i = 0; i < len; i++) {
        for (int j = i + 1; j <= len; j++) {
          String substring = label.substring(i, j).toLowerCase();
          if (_queryMap.containsKey(substring)) {
            Set<Event> labels = _queryMap[substring]!;
            labels.add(event);
          } else {
            _queryMap.putIfAbsent(substring, () => {event});
          }
        }
      }
    }
  }

  /// Use the [SplayTreeMap] query function to return the full [Set] of results.
  /// This operation amortized logarithmic time.
  Set<Event> performSearch(String query) {
    Set<Event> res = {};

    if (_queryMap.containsKey(query)) {
      return _queryMap[query]!;
    } else if (query.isNotEmpty) {
      return res;
    }

    Iterable<String> keys = _queryMap.keys;
    for (String k in keys) {
      res.addAll(_queryMap[k]!);
    }
    return res;
  }
}
