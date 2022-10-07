import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/search/search_manager.dart';

/// Used to init and store Tarikh and Relics events and favorites.
class EventC extends GetxHapi {
  static EventC get to => Get.find();

  late final List<Event> _eventListTarikh;
  late final List<Event> _eventListRelics;
  final List<Event> _eventListFavTarikh = [];
  final List<Event> _eventListFavRelics = [];

  final Map<String, Event> _eventMapTarikh = {};
  final Map<String, Event> _eventMapRelics = {};
  final Map<String, Event> _eventMapFavTarikh = {};
  final Map<String, Event> _eventMapFavRelics = {};

  // bool initDoneTarikh = false;
  // bool initDoneRelics = false;

  // eventsTarikh comes in sorted
  initEvents(List<Event> eventsTarikh, List<Event> eventsRelics) {
    _eventListTarikh = eventsTarikh;
    _eventListRelics = eventsRelics;

    // add all list items into an event map
    for (Event event in _eventListTarikh) {
      _eventMapTarikh[event.saveTag] = event;
    }
    for (Event event in _eventListRelics) {
      _eventMapRelics[event.saveTag] = event;
    }

    // events initialized so we can init favorites now
    _initFavorites(EVENT.Incident);
    _initFavorites(EVENT.Nabi);

    // initialize the SearchManager
    SearchManager.init(NavPage.Tarikh, _eventListTarikh);
    // initDoneTarikh = true;
    SearchManager.init(NavPage.Relics, _eventListRelics);
    // initDoneRelics = true;

    update(); // notify UI's they have data now
  }

  List<Event> getEventList(EVENT eventType) =>
      eventType.isRelic ? _eventListRelics : _eventListTarikh;
  List<Event> getEventListFav(EVENT eventType) =>
      eventType.isRelic ? _eventListFavRelics : _eventListFavTarikh;

  Map<String, Event> getEventMap(EVENT eventType) =>
      eventType.isRelic ? _eventMapRelics : _eventMapTarikh;
  Map<String, Event> getEventMapFav(EVENT eventType) =>
      eventType.isRelic ? _eventMapFavRelics : _eventMapFavTarikh;

  _initFavorites(EVENT eventType) {
    final List<dynamic>? rdFavList = s.rd(getSaveTagFavList(eventType));

    final Map<String, Event> eventMap = getEventMap(eventType);
    final Map<String, Event> eventMapFav = getEventMapFav(eventType);
    final List<Event> favList = getEventListFav(eventType);
    if (rdFavList != null) {
      for (String fav in rdFavList) {
        if (eventMap.containsKey(fav)) {
          favList.add(eventMap[fav]!);
          eventMapFav[eventMap[fav]!.saveTag] = eventMap[fav]!;
        }
      }
    }

    // TODO asdf needed?:
    //_sortTarikhFavorites(eventType, favList);
  }

  String getSaveTagFavList(EVENT eventType) =>
      eventType.isRelic ? 'favListRelics' : 'favListTarikh';

  /// Persist favorite data to disk, must convert to List<Event> to List<String>
  _saveFavorites(EVENT eventType) {
    List<String> favStringList = getEventListFav(eventType)
        .map(
          (Event event) => event.saveTag,
        )
        .toList();
    s.wr(getSaveTagFavList(eventType), favStringList);

    update(); // favorites changed so notify people using it
  }

  /// Sort so Tarikh UI's gutter show favorites in order
  _sortTarikhFavorites(EVENT eventType, List<Event> favList) {
    if (eventType == EVENT.Incident || eventType == EVENT.Era) {
      favList.sort((Event a, Event b) => a.startMs.compareTo(b.startMs));
    }
  }

  /// Save [e] into the list, re-sort it, and store to disk.
  addFavorite(EVENT eventType, Event event) {
    final Map<String, Event> favMap = getEventMapFav(eventType);

    String saveTag = event.saveTag;
    if (!favMap.containsKey(saveTag)) {
      final List<Event> favList = getEventListFav(eventType);
      favList.add(event);
      favMap[saveTag] = event;

      _sortTarikhFavorites(eventType, favList); // does eventType check inside

      _saveFavorites(eventType);
    }
  }

  /// Remove the event and save to disk.
  delFavorite(EVENT eventType, Event event) {
    final Map<String, Event> favMap = getEventMapFav(eventType);

    String saveTag = event.saveTag;
    if (favMap.containsKey(saveTag)) {
      final List<Event> favList = getEventListFav(eventType);
      favList.remove(event);
      favMap.remove(saveTag);
      _saveFavorites(eventType);
    }
  }

  /// Force static translations to update, i.e. Tarikh Bubble/Fav/Search text.
  /// Do async so we don't slow app
  reinitAllEventsTexts() async {
    for (Event event in getEventList(EVENT.Incident)) {
      event.reinitBubbleText();
    }
    for (Event event in getEventList(EVENT.Nabi)) {
      if (event.isTimeLineEvent) continue; // already updated in first loop
      event.reinitBubbleText();
    }
  }
}
