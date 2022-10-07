import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/getx_hapi.dart';
import 'package:hapi/controller/time_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
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
    this.tvTitleLine1,
    this.tvTitleLine2,
    this.tvTimeUntil,
    this.tvPageScrolls,
    this.event,
  );
  String tvTitleLine1;
  String tvTitleLine2;
  String tvTimeUntil;
  String tvPageScrolls;
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
    updateOnThread1Sec(); //update() causes error
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
    if (nv != _isActiveTarikhMenu) _isActiveTarikhMenu = nv;

    if (_isActiveTarikhMenu) {
      update(); // instant show animations
    } else {
      updateOnThread1Sec(); // allow fast menu scroll then disable animations
    }
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
  void onInit() {
    super.onInit();

    _initTimelineRelicsAndTarikhMenu(); // slow init, takes time to load
  }

  _initTimelineRelicsAndTarikhMenu() async {
    /// If we don't wait for LangC to init, then several of the first
    /// translations fail (always English) on the Timeline and Tarikh Menu.
    if (LanguageC.to.initNeeded) {
      int sleepBackoffMs = 250;
      // No internet needed if already initialized
      while (LanguageC.to.initNeeded) {
        l.d('_initTimelineRelicsAndTarikhMenu: Language translations not ready, try again after sleeping $sleepBackoffMs ms...');
        await Future.delayed(Duration(milliseconds: sleepBackoffMs));
        if (sleepBackoffMs < 1000) sleepBackoffMs += 250;
      }
    }

    timeBtnUp = TimeBtn('', '', '', '', null);
    timeBtnDn = TimeBtn('', '', '', '', null);

    int lastGutterModeIdx = s.rd('lastGutterModeIdx') ?? GutterMode.OFF.index;
    gutterMode = GutterMode.values[lastGutterModeIdx];

    // first handle json inputs
    tih = TimelineInitHandler();
    await tih._loadTimelineData();
    // then init static timeline object
    t = Timeline(
      tih.rootEvents,
      tih.tickColors,
      tih._headerColors,
      tih._timeMin,
      tih._timeMax,
    );

    Event event = EventC.to.getEventList(EVENT.Tarikh).first;
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
  bool get isGutterFavEmpty => EventC.to.getEventListFav(EVENT.Tarikh).isEmpty;

  /// Updates text around time button, no event is set
  void updateTimeBtn(
    TimeBtn timeBtn,
    String tvTitleLine1,
    String tvTitleLine2,
    String tvTimeUntil,
    String tvPageScrolls,
  ) {
    timeBtn.tvTitleLine1 = tvTitleLine1;
    timeBtn.tvTitleLine2 = tvTitleLine2;
    timeBtn.tvTimeUntil = tvTimeUntil;
    timeBtn.tvPageScrolls = tvPageScrolls;
    updateOnThread1Sec();
  }

  void updateEventBtn(TimeBtn timeBtn, Event? event) {
    String tvTitleLine1 = '';
    String tvTitleLine2 = '';
    String tvTimeUntil = '';
    String tvPageScrolls = '';

    if (event != null) {
      tvTitleLine1 = event.tvTitleLine1;
      tvTitleLine2 = event.tvTitleLine2;

      //was t.renderEnd, had 'page away 0' at bottom page edge, now in middle:
      double pageReference = (t.renderStart + t.renderEnd) / 2.0;
      double timeUntilDouble = event.startMs - pageReference;
      tvTimeUntil = event.tvYears(timeUntilDouble).toLowerCase();

      double pageSize = t.renderEnd - t.renderStart;
      double pages = timeUntilDouble / pageSize;
      String pagesAwayNum = formatter.format(pages.abs());
      if (pagesAwayNum == '1') {
        tvPageScrolls = cni(1) + ' ' + 'page away'.tr;
      } else {
        tvPageScrolls = cns(pagesAwayNum) + ' ' + 'pages away'.tr;
      }
    }

    timeBtn.event = event;
    updateTimeBtn(
      timeBtn,
      tvTitleLine1,
      tvTitleLine2,
      tvTimeUntil,
      tvPageScrolls,
    );
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

  double _timeMin = 0.0;
  double _timeMax = 0.0;

  /// Load all the resources from the local bundle.
  ///
  /// This function used to load and decode `timline.json` from disk.  Now it
  /// populates all the [Event]s through dart code.
  _loadTimelineData() async {
    final List<TimelineData> timelineDatas = getTimelineData();

    List<Event> eventsTarikh = [];

    /// The JSON decode doesn't provide strong typing, so we'll iterate
    /// on the dynamic events in the [jsonEvents] list.
    for (TimelineData td in timelineDatas) {
      /// Create the current event and fill in the current date if it's
      /// an `Incident`, or look for the `start` property if it's an `Era` instead.
      /// Some events will have a `start` element, but not an `end` specified.
      /// These events specify a particular event such as the appearance of
      /// "Humans" in history, which hasn't come to an end yet.
      bool isEra = false;
      double startMs;
      if (td.date != null) {
        startMs = td.date!;
      } else {
        isEra = true;
        startMs = td.start!;
      }

      /// Some elements will have an `end` time specified.
      /// If not `end` key is present in this event, create the value based
      /// on the type of the event:
      /// - Eras use the current year as an end time.
      /// - Other events are just single points in time (start == end).
      double endMs;
      if (td.end != null) {
        endMs = td.end!;
      } else if (isEra) {
        endMs = (await TimeC.to.now()).year.toDouble() * 10.0;
      } else {
        endMs = startMs;
      }

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

      /// Finally create Event object
      Event event = Event(
        eventType: EVENT.Tarikh,
        tkEra: td.tkEra ?? '',
        tkTitle: td.tkTitle,
        startMs: startMs,
        endMs: endMs,
        startMenu: td.startMenu,
        endMenu: td.endMenu,
        accent: td.accent, // accent color specified sometimes
      );

      /// Get flare/nima/image asset object
      EventAsset asset = await getEventAsset(td.asset);

      /// Add event reference:
      asset.event = event; // can and must only do this once

      // used to pass asset in Event(), here for easier/cleaner relic inits:
      event.asset = asset;

      /// Add this event to the list.
      eventsTarikh.add(event);
    }

    /// Major feature here, merge relics into Tarikh events so the relics can
    /// also show up on the UI. With return value, we will init favorites below.
    ///
    /// Note: We must spin wait for relic init completion, its data is need
    /// needed first so it can merge with the timeline events initializing here.
    List<Event> eventsRelics = await RelicC.to
        .mergeRelicAndTarikhEvents(eventsTarikh); // add Relics before sort

    /// sort Tarikh the full list so they are in order of oldest to newest
    eventsTarikh.sort((Event a, Event b) => a.startMs.compareTo(b.startMs));

    _backgroundColors
        .sort((TimelineBackgroundColor a, TimelineBackgroundColor b) {
      return a.startMs.compareTo(b.startMs);
    });

    _tickColorsReversed = _tickColors.reversed;

    _timeMin = double.maxFinite;
    _timeMax = -double.maxFinite;

    /// Enhanced menu.json to below. Now we auto build menu sections off eras:
    Map<String, EraMenuSection> eraMenuSectionMap = {};

    Event? previous;
    for (Event event in eventsTarikh) {
      /// Step 1 of 2: Build Era map of all menu items belonging to that era:
      if (event.tkEra != '') {
        EraMenuSection eraMenuSection;
        if (eraMenuSectionMap.containsKey(event.tkEra)) {
          eraMenuSection = eraMenuSectionMap[event.tkEra]!;
        } else {
          eraMenuSection = EraMenuSection(
            textColor: Colors.white,
            backgroundColor: Colors.black,
            event: event,
          );
          eraMenuSectionMap[event.tkEra] = eraMenuSection; // first time init
        }
        eraMenuSection.addEraEvent(event);
      }

      /// Build up hierarchy (Eras are grouped into "Spanning Eras" and Events
      ///  are placed into the Eras they belong to). TODO do we need this?
      if (event.startMs < _timeMin) _timeMin = event.startMs;
      if (event.endMs > _timeMax) _timeMax = event.endMs;

      if (previous != null) previous.next = event;
      event.previous = previous;
      previous = event;

      Event? parent;
      double minDistance = double.maxFinite;
      for (Event checkEvent in eventsTarikh) {
        if (checkEvent.isEra) {
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

    /// Step 2 of 2: Build menu section data off eraMenuSectionMap:
    for (String tkEra in eraMenuSectionMap.keys) {
      List<MenuItemData> menuItemList = [];
      EraMenuSection eraMenuSection = eraMenuSectionMap[tkEra]!;

      for (Event event in eraMenuSection.events) {
        menuItemList.add(
          MenuItemData(
            event.tkTitle,
            event.saveTag,
            event.startMenu != null
                ? event.startMenu!
                : eraMenuSection.getTimeMin(event),
            event.endMenu != null
                ? event.endMenu!
                : eraMenuSection.getTimeMax(event),
          ),
        );
      }

      TarikhC.to._tarikhMenuData.add(
        MenuSectionData(
          eraMenuSection.events[0].tkEra,
          eraMenuSection.textColor,
          eraMenuSection.backgroundColor,
          eraMenuSection.events[0],
          menuItemList,
        ),
      );
    }

    /// All setup to this point is done, we need to now init the Tarikh and
    /// Relic event maps and favorites.
    EventC.to.initEvents(eventsTarikh, eventsRelics);
  }

  TickColors findTickColors(double screen) {
    for (TickColors color in _tickColorsReversed) {
      if (screen >= color.screenY) return color;
    }

    return screen < _tickColors.first.screenY
        ? _tickColors.first
        : _tickColors.last;
  }
}

class EraMenuSection {
  EraMenuSection({
    required this.textColor,
    required this.backgroundColor,
    required this.event,
  });
  final Color textColor;
  final Color backgroundColor;
  final Event? event;

  final List<Event> events = [];
  // double timeMin = -1;
  // double timeMax = -1;

  // TODO we can also set this based off close next/previous to zoom in more
  double getTimeMin(Event event) =>
      event.startMs < 0 ? event.startMs * 1.2 : event.startMs * .8;
  double getTimeMax(Event event) =>
      event.startMs < 0 ? event.endMs * .8 : event.endMs * 1.2;

  addEraEvent(Event event) {
    // if (timeMin == -1 || event.startMs < timeMin) timeMin = event.startMs;
    // if (timeMax == -1 || event.endMs > timeMax) timeMax = event.endMs;
    events.add(event);
  }
}
