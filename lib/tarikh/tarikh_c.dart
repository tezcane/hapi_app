import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_c.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_data.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';
import 'package:intl/intl.dart';

import 'event/event_asset.dart';

/// Show states for Tarikh's Gutter (thin panel on left side of screen)
enum GutterMode {
  OFF,
  FAV,
  ALL,
}

/// Used for Timeline Up/Down Button data
class TimeBtn {
  TimeBtn(
    this.trValTitle,
    this.trValTimeUntil,
    this.trValPageScrolls,
    this.event,
  );
  String trValTitle;
  String trValTimeUntil;
  String trValPageScrolls;
  Event? event; // will be null on first/last events
}

class TarikhC extends GetxHapi {
  static TarikhC get to => Get.find();

  static late final Timeline t;
  static late final TimelineInitHandler tih;

  /// Buttons on timeline to go up/down past/future.
  late final TimeBtn timeBtnUp;
  late final TimeBtn timeBtnDn;

  /// This formatter is ok, used to track pages and cni/cns used to convert
  static final NumberFormat formatter = NumberFormat.compact();

  /// We can't show Tarikh Sub Pages until JSON file input data is parsed.
  bool _isTimelineInitDone = false;
  get isTimelineInitDone => _isTimelineInitDone;

  /// TIMELINE RENDER ENABLE/DISABLE:
  /// Toggle start/stop rendering whenever the timeline is visible or hidden.
  bool _isActiveTimeline = false;
  bool get isActiveTimeline => _isActiveTimeline;
  set isActiveTimeline(bool nv) {
    if (nv != _isActiveTimeline) {
      _isActiveTimeline = nv;
      if (_isActiveTimeline) t.startRendering();
    }
    updateOnThread(); //update() causes error
  }

  // MENU SECTION RENDER ENABLE/DISABLE:
  /// Used to start/stop vignettes menu section animations.
  /// Each card section contains a Flare animation that's playing in the
  /// background. These animations are paused when they're not visible anymore
  /// (e.g. when search is visible instead), and are played again once they're
  /// back in view.
  /// Toggle start/stop rendering whenever the tarikh menu is visible or hidden.
  bool _isActiveTarikhMenu = true;
  bool get isActiveTarikhMenu => _isActiveTarikhMenu;
  set isActiveTarikhMenu(bool nv) {
    if (nv != _isActiveTarikhMenu) {
      _isActiveTarikhMenu = nv;
    }
    updateOnThread1Ms(); // needed for bottom bar init
  }

  /// Loaded from JSON input that's stored in the assets folder which provides
  /// all the necessary information for the MenuSection display data, such as
  /// labels, background colors, the background Flare animation asset, and for
  /// each event in the expanded card, the relative position on the timeline.
  /// It does not contain all event info, so the Tarikh Menu requires the
  /// timeline to load to be fully functional.
  final List<MenuSectionData> _tarikhMenuData = [];
  List<MenuSectionData> get tarikhMenuData => _tarikhMenuData;

  /// Turn timeline gutter off/show favorites/show all history:
  GutterMode _gutterMode = GutterMode.OFF;
  GutterMode get gutterMode => _gutterMode;
  set gutterMode(GutterMode newGutterMode) {
    s.wr('lastGutterModeIdx', newGutterMode.index);
    _gutterMode = newGutterMode;
    update();
  }

  @override
  void onInit() async {
    super.onInit();

    await initTarikhMenu(); // init first to show UI fast
    await initTimeline(); // slow init, takes time to load
  }

  initTarikhMenu() async {
    await TarikhMenuInitHandler().loadFromBundle('assets/tarikh/menu.json');
  }

  initTimeline() async {
    timeBtnUp = TimeBtn('', '', '', null);
    timeBtnDn = TimeBtn('', '', '', null);

    int lastGutterModeIdx = s.rd('lastGutterModeIdx') ?? GutterMode.OFF.index;
    gutterMode = GutterMode.values[lastGutterModeIdx];

    // first handle json inputs
    tih = TimelineInitHandler();
    await tih.loadTimelineData();
    // then init static timeline object
    t = Timeline(
      tih.rootEvents,
      tih.tickColors,
      tih._headerColors,
      tih._timeMin,
      tih._timeMax,
    );

    Event event = EventC.to.getEventList(EVENT_TYPE.Incident).first;
    t.setViewport(
      start: event.startMs * 2.0,
      end: event.startMs,
      animate: true,
    ); // TODO needed, what does it and other setViewport do?

    // /// Advance the timeline to its starting position.
    t.advance(0.0, false); // TODO needed?

    _isTimelineInitDone = true;
    l.i('********************* TIMELINE INIT DONE **********************');
    update();
  }

  bool get isGutterModeOff => _gutterMode == GutterMode.OFF;
  bool get isGutterModeFav => _gutterMode == GutterMode.FAV;
  bool get isGutterModeAll => _gutterMode == GutterMode.ALL;
  bool get isGutterFavEmpty =>
      EventC.to.getEventListFav(EVENT_TYPE.Incident).isEmpty;

  /// Updates text around time button, no event is set
  void updateTimeBtn(
    TimeBtn timeBtn,
    String trValTitle,
    String trValTimeUntil,
    String trValPageScrolls,
  ) {
    timeBtn.trValTitle = trValTitle;
    timeBtn.trValTimeUntil = trValTimeUntil;
    timeBtn.trValPageScrolls = trValPageScrolls;
    updateOnThread();
  }

  void updateEventBtn(TimeBtn timeBtn, Event? event) {
    String trValTitle = '';
    String trValTimeUntil = '';
    String trValPageScrolls = '';

    if (event != null) {
      trValTitle = a(event.trKeyTitle);

      //was t.renderEnd, had 'page away 0' at bottom page edge, now in middle:
      double pageReference = (t.renderStart + t.renderEnd) / 2.0;
      double timeUntilDouble = event.startMs - pageReference;
      trValTimeUntil = event.trValYears(timeUntilDouble).toLowerCase();

      double pageSize = t.renderEnd - t.renderStart;
      double pages = timeUntilDouble / pageSize;
      String pagesAwayNum = formatter.format(pages.abs());
      if (pagesAwayNum == '1') {
        trValPageScrolls = cni(1) + ' ' + 'i.page away'.tr;
      } else {
        trValPageScrolls = cns(pagesAwayNum) + ' ' + 'i.pages away'.tr;
      }
    }

    timeBtn.event = event;
    updateTimeBtn(timeBtn, trValTitle, trValTimeUntil, trValPageScrolls);
  }
}

class TimelineInitHandler {
  /// A gradient is shown on the background, depending on the [_currentEra]
  /// we're in.
  final List<TimelineBackgroundColor> _backgroundColors = [];

  get backgroundColors => _backgroundColors;

  /// [TickColors] also have custom colors so that they are always visible
  /// with the changing background.
  final List<TickColors> _tickColors = [];

  List<TickColors> get tickColors => _tickColors;
  late final Iterable<TickColors> _tickColorsReversed;
  final List<HeaderColors> _headerColors = [];

  /// All the [Event]s that are loaded from disk at boot (in [loadFromBundle()]).
  /// List for "root" events, i.e. events with no parents.
  final List<Event> _rootEvents = [];

  get rootEvents => _rootEvents;

  /// This is a special feature to play a particular part of an animation
  final Map<String, Event> _eventsById = {};

  double _timeMin = 0.0;
  double _timeMax = 0.0;

  /// Load all the resources from the local bundle.
  ///
  /// This function used to load and decode `timline.json` from disk.  Now it
  /// populates all the [Event]s through dart code.
  loadTimelineData() async {
    final List<TimelineData> timelineDatas = getTimelineData();

    // TODO test add "era" field per event and also auto generate it's start and end and zoom by looking at its incidents:
    String trKeyEra = '';

    List<Event> eventsTarikh = [];

    /// The JSON decode doesn't provide strong typing, so we'll iterate
    /// on the dynamic events in the [jsonEvents] list.
    for (TimelineData td in timelineDatas) {
      /// The trKeyTitle is a brief description for the current event.
      String trKeyTitle = td.trKeyTitle;

      /// Create the current event and fill in the current date if it's
      /// an `Incident`, or look for the `start` property if it's an `Era` instead.
      /// Some events will have a `start` element, but not an `end` specified.
      /// These events specify a particular event such as the appearance of
      /// "Humans" in history, which hasn't come to an end yet.
      EVENT_TYPE type;
      double startMs;
      if (td.date != null) {
        type = EVENT_TYPE.Incident;
        startMs = td.date!;
      } else {
        type = EVENT_TYPE.Era;
        startMs = td.start!;
        trKeyEra = trKeyTitle;
      }

      /// Some elements will have an `end` time specified.
      /// If not `end` key is present in this event, create the value based
      /// on the type of the event:
      /// - Eras use the current year as an end time.
      /// - Other events are just single points in time (start == end).
      double endMs;
      if (td.end != null) {
        endMs = td.end!;
      } else if (type == EVENT_TYPE.Era) {
        // TODO where timeline eras stretch to future?
        endMs = (await TimeC.to.now()).year.toDouble() * 10.0;
      } else {
        endMs = startMs;
      }

      //l.d('lastEra=$era, label=$label'); TODO fix

      /// Get Timeline Color Setup:
      if (td.timelineColors != null) {
        TimelineColors timelineColors = td.timelineColors!;

        /// If a custom background color for this [Event] is specified,
        /// extract its RGB values and save them for reference, along with the
        /// starting date of the current event.
        _backgroundColors.add(
          TimelineBackgroundColor(
            timelineColors.background,
            startMs,
          ),
        );

        /// [Ticks] can also have custom colors, so that everything's is visible
        /// even with custom colored backgrounds.
        _tickColors.add(
          TickColors(
            timelineColors.ticks.background,
            timelineColors.ticks.long,
            timelineColors.ticks.short,
            timelineColors.ticks.text,
            startMs,
          ),
        );

        /// If a `header` element is present, de-serialize the colors for it too.
        _headerColors.add(
          HeaderColors(
            timelineColors.header.background,
            timelineColors.header.text,
            startMs,
          ),
        );
      }

      /// An accent color is also specified at times.
      Color? accent = td.accent;

      /// Get flare/nima/image asset object
      EventAsset asset = await getEventAsset(td.asset);

      /// Finally create Event object
      Event event = Event(
        type: type,
        trKeyEra: trKeyEra,
        trKeyTitle: trKeyTitle,
        startMs: startMs,
        endMs: endMs,
        accent: accent,
      );
      // used to pass asset in above, now here for easier/cleaner relic inits:
      event.asset = asset;

      /// Add event reference 1 of 2: TODO this is a hack, access via map?
      asset.event = event; // can and must only do this once

      /// Add event reference 2 of 2:
      /// Some events will have an id to find and play the menu animation
      if (td.actorId != null) _eventsById[td.actorId!] = event;

      /// Add this event to the list.
      eventsTarikh.add(event); // sort is probably needed
    }

    /// Major feature here, merge relics into Tarikh events so the relics can
    /// also show up on the UI. With return value, we will init favorites below.
    ///
    /// Note: We must spin wait for relic init completion, its data is need
    /// needed first so it can merge with the timeline events initializing here.
    List<Event> eventsRelics = await RelicC.to
        .mergeRelicAndTarikhEvents(eventsTarikh); // add before sort

    /// sort Tarikh the full list so they are in order of oldest to newest
    eventsTarikh.sort((Event a, Event b) => a.startMs.compareTo(b.startMs));

    _backgroundColors
        .sort((TimelineBackgroundColor a, TimelineBackgroundColor b) {
      return a.startMs.compareTo(b.startMs);
    });

    _tickColorsReversed = _tickColors.reversed;

    _timeMin = double.maxFinite;
    _timeMax = -double.maxFinite;

    /// IMPORTANT NOTE: Do we want to enhance this to allow json file input to
    ///                 define where stuff belongs:
    /// Build up hierarchy (Eras are grouped into "Spanning Eras" and Events are
    /// placed into the Eras they belong to).
    Event? previous;
    for (Event event in eventsTarikh) {
      if (event.startMs < _timeMin) _timeMin = event.startMs;
      if (event.endMs > _timeMax) _timeMax = event.endMs;

      if (previous != null) previous.next = event;
      event.previous = previous;
      previous = event;

      Event? parent;
      double minDistance = double.maxFinite;
      for (Event checkEvent in eventsTarikh) {
        if (checkEvent.type == EVENT_TYPE.Era) {
          double distance = event.startMs - checkEvent.startMs;
          double distanceEnd = event.startMs - checkEvent.endMs;
          if (distance > 0 && distanceEnd < 0 && distance < minDistance) {
            minDistance = distance;
            parent = checkEvent;
          }
        }
      }
      // no parent, so this is a root event.
      if (parent == null) {
        _rootEvents.add(event); // note holds eras, not individual events
      } else {
        // otherwise add as child to parent node
        event.parent = parent;
        parent.children ??= []; // parent node holds children
        parent.children!.add(event);
      }
    }

    /// All setup to this point is done, we need to now init the Tarikh and
    /// Relic event maps and favorites.
    EventC.to.initEvents(eventsTarikh, eventsRelics);
  }

  // Color colorFromList(colorList, {String key = ''}) {
  //   if (key != '') colorList = colorList[key];
  //   List<int> bg = colorList.cast<int>();
  //
  //   int bg3 = 0xFF; // 255 (no opacity)
  //   if (bg.length == 4) bg3 = bg[3];
  //
  //   return Color.fromARGB(bg3, bg[0], bg[1], bg[2]);
  // }

  /// The `asset` key in the current event contains all the information for
  /// the nima/flare animation file that'll be played on the timeline.
  ///
  /// `asset` is an object with:
  ///   - source: the name of the nima/flare/image file in the assets folder.
  ///   - width/height/offset/bounds/gap:
  ///            Sizes of the animation to properly align it in the timeline,
  ///            together with its Axis-Aligned Bounding Box container.
  ///   - intro: Some files have an 'intro' animation, to be played before
  ///            idling.
  ///   - idle:  Some files have one or more idle animations, and these are
  ///            their names.
  ///   - loop:  Some animations shouldn't loop (e.g. Big Bang) but just settle
  ///            onto their idle animation. If that's the case, this flag is
  ///            raised.
  ///   - scale: a custom scale value.
  Future<EventAsset> getEventAsset(Asset asset) async {
    String filename = 'assets/' + asset.source;

    double width = asset.width;
    double height = asset.height;

    bool loop = asset.loop;
    double offset = asset.offset;
    double gap = asset.gap;
    double scale = asset.scale;

    /// Instantiate the correct object based on the file extension.
    EventAsset eventAsset;
    switch (getFileExtension(asset.source)) {
      case 'flr':
        eventAsset = await loadFlareAsset(filename, width, height, scale, loop,
            offset, gap, asset.idle, asset.intro, asset.bounds);
        break;
      case 'nma':
        eventAsset = await loadNimaAsset(filename, width, height, scale, loop,
            offset, gap, asset.idle, asset.bounds);
        break;
      default:
        // Legacy fallback case: some elements just use images.
        eventAsset = await loadImageAsset(filename, width, height, scale);
        break;
    }

    return Future.value(eventAsset);
  }

  /// Helper function for [MenuVignette].
  Event? getEventById(String id) => _eventsById[id];

  TickColors findTickColors(double screen) {
    for (TickColors color in _tickColorsReversed) {
      if (screen >= color.screenY) return color;
    }

    return screen < _tickColors.first.screenY
        ? _tickColors.first
        : _tickColors.last;
  }
}

/// This class has the sole purpose of loading the resources from storage and
/// de-serializing the JSON file appropriately.
///
/// `menu.json` contains an array of objects, each with:
/// * label - the title for the section
/// * background - the color on the section background
/// * color - the accent color for the menu section
/// * asset - the background Flare/Nima asset id that will play the section background
/// * items - an array of elements providing each the start and end times for that link
/// as well as the label to display in the [MenuSection].
class TarikhMenuInitHandler {
  loadFromBundle(String filename) async {
    String jsonData = await rootBundle.loadString(filename);
    List jsonEvents = json.decode(jsonData);

    List<MenuItemData> menuItemList;
    for (Map map in jsonEvents) {
      menuItemList = [];

      String label = map['label'];
      Color textColor = Color(
          int.parse((map['color']).substring(1, 7), radix: 16) + 0xFF000000);
      Color backgroundColor = Color(
          int.parse((map['background']).substring(1, 7), radix: 16) +
              0xFF000000);
      String assetId = map['asset'];

      for (Map itemMap in map['items']) {
        String label = itemMap['label'];

        dynamic startVal = itemMap['start'];
        double start = startVal is int ? startVal.toDouble() : startVal;

        dynamic endVal = itemMap['end'];
        double end = endVal is int ? endVal.toDouble() : endVal;

        menuItemList.add(
          MenuItemData(
            'i.' + label,
            'i.' + label + '_' + 'TODO era',
            start,
            end,
          ),
        ); // TODO asdf i. hack
      }

      TarikhC.to._tarikhMenuData.add(MenuSectionData(
          label, textColor, backgroundColor, assetId, menuItemList));
      TarikhC.to.update();
    }
  }
}
