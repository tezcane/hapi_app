import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/tarikh/event/et.dart';
import 'package:hapi/tarikh/event/et_extension.dart';
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
    _initFavorites(ET.Tarikh);
    _initFavorites(ET.Nabi);

    // initialize the SearchManager
    SearchManager.init(NavPage.Tarikh, _eventListTarikh);
    // initDoneTarikh = true;
    SearchManager.init(NavPage.Alathar, _eventListRelics);
    // initDoneRelics = true;

    update(); // notify UI's they have data now
  }

  List<Event> getEventList(ET et) =>
      et.isRelic ? _eventListRelics : _eventListTarikh;
  List<Event> getEventListFav(ET et) =>
      et.isRelic ? _eventListFavRelics : _eventListFavTarikh;

  Map<String, Event> getEventMap(ET et) =>
      et.isRelic ? _eventMapRelics : _eventMapTarikh;
  Map<String, Event> getEventMapFav(ET et) =>
      et.isRelic ? _eventMapFavRelics : _eventMapFavTarikh;

  _initFavorites(ET et) {
    final List<dynamic>? rdFavList = s.rd(getSaveTagFavList(et));

    final Map<String, Event> eventMap = getEventMap(et);
    final Map<String, Event> eventMapFav = getEventMapFav(et);
    final List<Event> favList = getEventListFav(et);
    if (rdFavList != null) {
      for (String fav in rdFavList) {
        if (eventMap.containsKey(fav)) {
          favList.add(eventMap[fav]!);
          eventMapFav[eventMap[fav]!.saveTag] = eventMap[fav]!;
        }
      }
    }

    // TODO asdf needed?:
    //_sortTarikhFavorites(et, favList);
  }

  String getSaveTagFavList(ET et) =>
      et.isRelic ? 'favListRelics' : 'favListTarikh';

  /// Persist favorite data to disk, must convert to List<Event> to List<String>
  _saveFavorites(ET et) {
    List<String> favStringList = getEventListFav(et)
        .map(
          (Event event) => event.saveTag,
        )
        .toList();
    s.wr(getSaveTagFavList(et), favStringList);

    update(); // favorites changed so notify people using it
  }

  /// Save [e] into the list, re-sort it, and store to disk.
  addFavorite(ET et, Event event) {
    final Map<String, Event> favMap = getEventMapFav(et);

    String saveTag = event.saveTag;
    if (!favMap.containsKey(saveTag)) {
      final List<Event> favList = getEventListFav(et);
      favList.add(event);
      favMap[saveTag] = event;

      // Sort so Tarikh UI's gutter show favorites in order
      if (et == ET.Tarikh) {
        favList.sort((Event a, Event b) => a.startMs.compareTo(b.startMs));
      }

      _saveFavorites(et);
    }
  }

  /// Remove the event and save to disk.
  delFavorite(ET et, Event event) {
    final Map<String, Event> favMap = getEventMapFav(et);

    String saveTag = event.saveTag;
    if (favMap.containsKey(saveTag)) {
      final List<Event> favList = getEventListFav(et);
      favList.remove(event);
      favMap.remove(saveTag);
      _saveFavorites(et);
    }
  }

  /// Force static translations to update, i.e. Tarikh Bubble/Fav/Search text.
  /// Do async so we don't slow app
  reinitAllEventsTexts() async {
    for (Event event in getEventList(ET.Tarikh)) {
      event.reinitTranslationTexts();
    }
    for (Event event in getEventList(ET.Nabi)) {
      if (event.isTimeLineEvent) continue; // already updated in first loop
      event.reinitTranslationTexts();
    }
  }
}
