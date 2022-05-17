import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flare_dart/math/aabb.dart' as flare;
import 'package:flare_flutter/flare.dart' as flare;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/getx_hapi.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/search_manager.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';
import 'package:intl/intl.dart';
import 'package:nima/nima.dart' as nima;
import 'package:nima/nima/animation/actor_animation.dart' as nima;
import 'package:nima/nima/math/aabb.dart' as nima;

enum GutterMode {
  OFF,
  FAV,
  ALL,
}

/// Used for Timeline Up/Down Button data
class TimeBtn {
  TimeBtn(this.title, this.timeUntil, this.pageScrolls, this.entry);
  String title;
  String timeUntil;
  String pageScrolls;
  TimelineEntry? entry; // will be null on first/last entries
}

class TarikhController extends GetxHapi {
  static TarikhController get to => Get.find();

  static late final Timeline t;
  static late final TimelineInitHandler tih;

  /// Buttons on timeline to go up/down past/future.
  late final TimeBtn timeBtnUp;
  late final TimeBtn timeBtnDn;

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
      if (_isActiveTimeline) {
        t.startRendering();
        updateOnThread(); //update() causes error
      }
    } else {
      l.w('_isActiveTimeline already set to $_isActiveTimeline');
    }
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
      updateOnThread1Ms(); // needed for bottom bar init
    } else {
      l.w('_isActiveTarikhMenu already set to $_isActiveTarikhMenu');
    }
  }

  /// Loaded from JSON input that's stored in the assets folder which provides
  /// all the necessary information for the MenuSection display data, such as
  /// labels, background colors, the background Flare animation asset, and for
  /// each event in the expanded card, the relative position on the timeline.
  /// It does not contain all event info, so the Tarikh Menu requires the
  /// timeline to load to be fully functional.
  final List<MenuSectionData> _tarikhMenuData = [];
  get tarikhMenuData => _tarikhMenuData;

  /// List of favorite events shown on Tarikh_Favorites page and timeline gutter
  final List<TimelineEntry> _eventFavorites = [];
  List<TimelineEntry> get eventFavorites => _eventFavorites;

  /// List of all history events for timeline gutter retrieval
  final List<TimelineEntry> _events = [];
  List<TimelineEntry> get events => _events;

  /// A [Map] is used to optimize retrieval times when checking if a favorite
  /// is already present - in fact the label's used as the key.
  /// Checking if an element is in the map is O(1), making this process O(n)
  /// with n entries.
  final Map<String, TimelineEntry> _eventMap = {};
  Map<String, TimelineEntry> get eventMap => _eventMap;

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
    timeBtnUp = TimeBtn(' ', ' ', ' ', null);
    timeBtnDn = TimeBtn(' ', ' ', ' ', null);

    int lastGutterModeIdx = s.rd('lastGutterModeIdx') ?? GutterMode.OFF.index;
    gutterMode = GutterMode.values[lastGutterModeIdx];

    // first handle json inputs
    tih = TimelineInitHandler();
    await tih.loadFromBundle();
    // then init static timeline object
    t = Timeline(
      tih.rootEntries,
      tih.tickColors,
      tih._headerColors,
      tih._timeMin,
      tih._timeMax,
    );

    t.setViewport(
      start: events.first.startMs * 2.0,
      end: events.first.startMs,
      animate: true,
    ); // TODO needed, what does it and other setViewport do?

    /// Advance the timeline to its starting position. // TODO needed?
    t.advance(0.0, false);

    /// All the entries are loaded, we can fill in the [favoritesBloc]...
    _initFavorites();

    /// ...and initialize the [SearchManager].
    SearchManager.init(events);

    l.i('********************* TIMELINE INIT DONE **********************');
    _isTimelineInitDone = true;
    update();
  }

  /// It receives as input the full list of [TimelineEntry], so that it can
  /// use those references to fill [_eventFavorites].
  _initFavorites() {
    List<dynamic>? favs = s.rd('TARIKH_FAVS');

    if (favs != null) {
      for (String fav in favs) {
        if (eventMap.containsKey(fav)) {
          _eventFavorites.add(eventMap[fav]!);
        }
      }
    }

    /// Sort by starting time, so the favorites' list is always displayed in ascending order.
    _eventFavorites.sort((TimelineEntry a, TimelineEntry b) {
      return a.startMs.compareTo(b.startMs);
    });
  }

  /// Persists the data to disk.
  _saveFavorites() {
    // note saves in any order, must sort on reading in from disk
    List<String> favsList =
        _eventFavorites.map((TimelineEntry entry) => entry.label).toList();
    s.wr('TARIKH_FAVS', favsList);
    update(); // favorites changed so notify people using it
  }

  /// Save [e] into the list, re-sort it, and store to disk.
  addFavorite(TimelineEntry e) {
    if (!_eventFavorites.contains(e)) {
      _eventFavorites.add(e);
      // sort for UI to still show in order
      _eventFavorites.sort((TimelineEntry a, TimelineEntry b) {
        return a.startMs.compareTo(b.startMs);
      });
      _saveFavorites();
    }
  }

  /// Remove the entry and save to disk.
  removeFavorite(TimelineEntry e) {
    if (_eventFavorites.contains(e)) {
      _eventFavorites.remove(e);
      _saveFavorites();
    }
  }

  bool isGutterModeOff() => _gutterMode == GutterMode.OFF;
  bool isGutterModeFav() => _gutterMode == GutterMode.FAV;
  bool isGutterModeAll() => _gutterMode == GutterMode.ALL;

  /// Updates text around time button, no entry is set
  void updateTimeBtn(
      TimeBtn timeBtn, String title, String timeUntil, String pageScrolls) {
    timeBtn.title = title;
    timeBtn.timeUntil = timeUntil;
    timeBtn.pageScrolls = pageScrolls;
    updateOnThread();
  }

  void updateTimeBtnEntry(TimeBtn timeBtn, TimelineEntry? entry) {
    String title = ' '; // these can't be blank/'' because of FittedBox
    String timeUntil = ' ';
    String pageScrolls = ' ';

    if (entry != null) {
      title = entry.label;

      //was t.renderEnd, had 'page away 0' at bottom page edge, now in middle:
      double pageReference = (t.renderStart + t.renderEnd) / 2.0;
      double timeUntilDouble = entry.startMs - pageReference;
      timeUntil = TimelineEntry.formatYears(timeUntilDouble).toLowerCase();

      double pageSize = t.renderEnd - t.renderStart;
      double pages = timeUntilDouble / pageSize;
      String pagesAwayNum = formatter.format(pages.abs());
      if (pagesAwayNum == '1') {
        pageScrolls = '1 page away';
      } else {
        pageScrolls = '$pagesAwayNum pages away';
      }
    }

    timeBtn.entry = entry;
    updateTimeBtn(timeBtn, title, timeUntil, pageScrolls);
  }
}

class TimelineInitHandler {
  /// A gradient is shown on the background, depending on the [_currentEra] we're in.
  final List<TimelineBackgroundColor> _backgroundColors = [];
  get backgroundColors => _backgroundColors;

  /// [Ticks] also have custom colors so that they are always visible with the changing background.
  final List<TickColors> _tickColors = [];
  get tickColors => _tickColors;
  late final Iterable<TickColors> _tickColorsReversed;
  final List<HeaderColors> _headerColors = [];

  /// All the [TimelineEntry]s that are loaded from disk at boot (in [loadFromBundle()]).
  /// List for "root" entries, i.e. entries with no parents.
  final List<TimelineEntry> _rootEntries = [];
  get rootEntries => _rootEntries;

  /// This is a special feature to play a particular part of an animation
  final Map<String, TimelineEntry> _entriesById = {};

  double _timeMin = 0.0;
  double _timeMax = 0.0;

  /// Load all the resources from the local bundle.
  ///
  /// This function will load and decode `timline.json` from disk,
  /// decode the JSON file, and populate all the [TimelineEntry]s.
  loadFromBundle() async {
    final String jsonData =
        await rootBundle.loadString('assets/tarikh/timeline.json');
    final List jsonEntries = json.decode(jsonData);

    /// The JSON decode doesn't provide strong typing, so we'll iterate
    /// on the dynamic entries in the [jsonEntries] list.
    for (Map map in jsonEntries) {
      /// The label is a brief description for the current entry.
      String label = map['label'];

      /// Create the current entry and fill in the current date if it's
      /// an `Incident`, or look for the `start` property if it's an `Era` instead.
      /// Some entries will have a `start` element, but not an `end` specified.
      /// These entries specify a particular event such as the appearance of
      /// "Humans" in history, which hasn't come to an end -- yet.
      TimelineEntryType type;
      double startMs;
      if (map.containsKey('date')) {
        type = TimelineEntryType.Incident;
        dynamic date = map['date'];
        startMs = date is int ? date.toDouble() : date;
      } else {
        type = TimelineEntryType.Era;
        dynamic startVal = map['start'];
        startMs = startVal is int ? startVal.toDouble() : startVal;
      }

      /// Some elements will have an `end` time specified.
      /// If not `end` key is present in this entry, create the value based
      /// on the type of the event:
      /// - Eras use the current year as an end time.
      /// - Other entries are just single points in time (start == end).
      double endMs;
      if (map.containsKey('end')) {
        dynamic endVal = map['end'];
        endMs = endVal is int ? endVal.toDouble() : endVal;
      } else if (type == TimelineEntryType.Era) {
        // TODO where timeline eras stretch to future?
        endMs = (await TimeController.to.now()).year.toDouble() * 10.0;
      } else {
        endMs = startMs;
      }

      String articleFilename = map['article'];

      /// Get Timeline Color Setup:
      if (map.containsKey('timelineColors')) {
        var timelineColors = map['timelineColors'];

        /// If a custom background color for this [TimelineEntry] is specified,
        /// extract its RGB values and save them for reference, along with the
        /// starting date of the current entry.
        _backgroundColors.add(
          TimelineBackgroundColor(
            colorFromList(timelineColors['background']),
            startMs,
          ),
        );

        /// [Ticks] can also have custom colors, so that everything's is visible
        /// even with custom colored backgrounds.
        _tickColors.add(
          TickColors(
            colorFromList(timelineColors['ticks'], key: 'background'),
            colorFromList(timelineColors['ticks'], key: 'long'),
            colorFromList(timelineColors['ticks'], key: 'short'),
            colorFromList(timelineColors['ticks'], key: 'text'),
            startMs,
          ),
        );

        /// If a `header` element is present, de-serialize the colors for it too.
        _headerColors.add(
          HeaderColors(
            colorFromList(timelineColors['header'], key: 'background'),
            colorFromList(timelineColors['header'], key: 'text'),
            startMs,
          ),
        );
      }

      /// OPTIONAL FIELD 1 of 2: An accent color is also specified at times.
      Color? accent;
      if (map.containsKey('accent')) {
        accent = colorFromList(map['accent']);
      }

      /// OPTIONAL FIELD 2 of 2: Some entries will also have an id
      String? id;
      if (map.containsKey('id')) {
        id = map['id'];
      }

      /// Get flare/nima/image asset object
      TimelineAsset asset = await getTimelineAsset(map['asset']);

      /// Finally create TimeLineEntry object
      var timelineEntry = TimelineEntry(
        label,
        type,
        startMs,
        endMs,
        articleFilename,
        asset,
        accent,
        id,
      );

      /// Add TimelineEntry reference 1 of 2:
      asset.entry = timelineEntry; // can only do this once

      /// Add TimelineEntry reference 2 of 2:
      if (map.containsKey('id')) {
        _entriesById[id!] = timelineEntry;
      }

      /// Add this entry to the list.
      TarikhController.to.eventMap
          .putIfAbsent(timelineEntry.label, () => timelineEntry);
      TarikhController.to.events.add(timelineEntry); // sort is probably needed
    }

    /// sort the full list so they are in order of oldest to newest
    TarikhController.to.events.sort((TimelineEntry a, TimelineEntry b) {
      return a.startMs.compareTo(b.startMs);
    });

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
    TimelineEntry? previous;
    for (TimelineEntry entry in TarikhController.to.events) {
      if (entry.startMs < _timeMin) {
        _timeMin = entry.startMs;
      }
      if (entry.endMs > _timeMax) {
        _timeMax = entry.endMs;
      }
      if (previous != null) {
        previous.next = entry;
      }
      entry.previous = previous;
      previous = entry;

      TimelineEntry? parent;
      double minDistance = double.maxFinite;
      for (TimelineEntry checkEntry in TarikhController.to.events) {
        if (checkEntry.type == TimelineEntryType.Era) {
          double distance = entry.startMs - checkEntry.startMs;
          double distanceEnd = entry.startMs - checkEntry.endMs;
          if (distance > 0 && distanceEnd < 0 && distance < minDistance) {
            minDistance = distance;
            parent = checkEntry;
          }
        }
      }
      // no parent, so this is a root entry.
      if (parent == null) {
        _rootEntries.add(entry); // note holds eras, not individual entries
      } else {
        // otherwise add as child to parent node
        entry.parent = parent;
        parent.children ??= []; // parent node holds children
        parent.children!.add(entry);
      }
    }
  }

  Color colorFromList(colorList, {String key = ''}) {
    if (key != '') {
      colorList = colorList[key];
    }
    List<int> bg = colorList.cast<int>();

    int bg3 = 0xFF; // 255 (no opacity)
    if (bg.length == 4) {
      bg3 = bg[3];
    }

    return Color.fromARGB(bg3, bg[0], bg[1], bg[2]);
  }

  /// The `asset` key in the current entry contains all the information for
  /// the nima/flare animation file that'll be played on the timeline.
  ///
  /// `asset` is a JSON map with:
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
  Future<TimelineAsset> getTimelineAsset(Map assetMap) async {
    String source = assetMap['source'];
    String filename = 'assets/tarikh/' + source;

    TimelineAsset asset;

    dynamic loopVal = assetMap['loop'];
    bool loop = loopVal is bool ? loopVal : true;

    dynamic offsetVal = assetMap['offset'];
    double offset = offsetVal == null
        ? 0.0
        : offsetVal is int
            ? offsetVal.toDouble()
            : offsetVal;

    dynamic gapVal = assetMap['gap'];
    double gap = gapVal == null
        ? 0.0
        : gapVal is int
            ? gapVal.toDouble()
            : gapVal;

    dynamic widthVal = assetMap['width'];
    double width = widthVal is int ? widthVal.toDouble() : widthVal;

    dynamic heightVal = assetMap['height'];
    double height = heightVal is int ? heightVal.toDouble() : heightVal;

    double scale = 1.0;
    if (assetMap.containsKey('scale')) {
      dynamic scaleVal = assetMap['scale'];
      scale = scaleVal is int ? scaleVal.toDouble() : scaleVal;
    }

    /// Instantiate the correct object based on the file extension.
    switch (getFileExtension(source)) {
      case 'flr':
        asset = await loadFlareAsset(
            assetMap, filename, loop, offset, gap, width, height, scale);
        break;
      case 'nma':
        asset = await loadNimaAsset(
            assetMap, filename, loop, offset, gap, width, height, scale);
        break;
      default: // TODO TEST THIS, MVP can ship with just pictures
        /// Legacy fallback case: some elements could have been just images.
        ByteData data = await rootBundle.load(filename);
        Uint8List list = Uint8List.view(data.buffer);
        ui.Codec codec = await ui.instantiateImageCodec(list);
        ui.FrameInfo frame = await codec.getNextFrame();

        asset = TimelineImage(frame.image, width, height, filename, scale);

        break;
    }

    return Future.value(asset);
  }

  Future<TimelineAsset> loadFlareAsset(
    Map assetMap,
    String filename,
    bool loop,
    double offset,
    double gap,
    double width,
    double height,
    double scale,
  ) async {
    flare.FlutterActor flutterActor = flare.FlutterActor();

    /// Flare library function to load the [FlutterActor]
    await flutterActor.loadFromBundle(rootBundle, filename);

    /// Distinguish between the actual actor, and its instance.
    flare.FlutterActorArtboard actorStatic =
        flutterActor.artboard as flare.FlutterActorArtboard;
    actorStatic.initializeGraphics();
    flare.FlutterActorArtboard actor =
        flutterActor.artboard.makeInstance() as flare.FlutterActorArtboard;
    actor.initializeGraphics();

    /// and the reference to their first animation is grabbed.
    flare.ActorAnimation animation = flutterActor.artboard.animations[0];

    flare.ActorAnimation? idle;
    List<flare.ActorAnimation>? idleAnimations;
    dynamic name = assetMap['idle'];
    if (name is String) {
      if ((idle = actor.getAnimation(name)) != null) {
        animation = idle;
      }
    } else if (name is List) {
      for (String animationName in name) {
        flare.ActorAnimation? animation1 = actor.getAnimation(animationName);
        if (animation1 != null) {
          idleAnimations ??= [];
          idleAnimations.add(animation1);
          animation = animation1;
        }
      }
    }

    flare.ActorAnimation? intro;
    name = assetMap['intro'];
    if (name is String) {
      if ((intro = actor.getAnimation(name)) != null) {
        animation = intro;
      }
    }

    /// Make sure that all the initial values are set for the actor and for the
    /// actor instance.
    actor.advance(0.0);
    flare.AABB setupAABB = actor.computeAABB();
    animation.apply(0.0, actor, 1.0);
    animation.apply(animation.duration, actorStatic, 1.0);
    actor.advance(0.0);
    actorStatic.advance(0.0);

    dynamic bounds = assetMap['bounds'];
    if (bounds is List) {
      /// Override the AABB for this entry with custom values.
      setupAABB = flare.AABB.fromValues(
          bounds[0] is int ? bounds[0].toDouble() : bounds[0],
          bounds[1] is int ? bounds[1].toDouble() : bounds[1],
          bounds[2] is int ? bounds[2].toDouble() : bounds[2],
          bounds[3] is int ? bounds[3].toDouble() : bounds[3]);
    }

    TimelineFlare flareAsset = TimelineFlare(
      actorStatic,
      actor,
      setupAABB,
      animation,
      loop,
      offset,
      gap,
      width,
      height,
      filename,
      scale,
    );

    // set optional fields, if they exist:
    flareAsset.intro = intro;
    flareAsset.idle = idle;
    flareAsset.idleAnimations = idleAnimations;

    return flareAsset;
  }

  Future<TimelineAsset> loadNimaAsset(
    Map assetMap,
    String filename,
    bool loop,
    double offset,
    double gap,
    double width,
    double height,
    double scale,
  ) async {
    nima.FlutterActor flutterActor = nima.FlutterActor();
    await flutterActor.loadFromBundle(filename);

    nima.FlutterActor actorStatic = flutterActor;
    nima.FlutterActor actor = flutterActor.makeInstance() as nima.FlutterActor;

    nima.ActorAnimation animation;
    dynamic name = assetMap['idle'];
    if (name is String) {
      animation = actor.getAnimation(name);
    } else {
      animation = flutterActor.animations[0];
    }

    actor.advance(0.0);
    nima.AABB setupAABB = actor.computeAABB();
    animation.apply(0.0, actor, 1.0);
    animation.apply(animation.duration, actorStatic, 1.0);
    actor.advance(0.0);
    actorStatic.advance(0.0);

    dynamic bounds = assetMap['bounds'];
    if (bounds is List) {
      setupAABB = nima.AABB.fromValues(
          bounds[0] is int ? bounds[0].toDouble() : bounds[0],
          bounds[1] is int ? bounds[1].toDouble() : bounds[1],
          bounds[2] is int ? bounds[2].toDouble() : bounds[2],
          bounds[3] is int ? bounds[3].toDouble() : bounds[3]);
    }

    TimelineNima nimaAsset = TimelineNima(
      actorStatic,
      actor,
      setupAABB,
      animation,
      loop,
      offset,
      gap,
      width,
      height,
      filename,
      scale,
    );

    return nimaAsset;
  }

  /// Helper function for [MenuVignette].
  TimelineEntry? getById(String id) {
    return _entriesById[id];
  }

  TickColors? findTickColors(double screen) {
    for (TickColors color in _tickColorsReversed) {
      if (screen >= color.screenY) {
        return color;
      }
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
    List jsonEntries = json.decode(jsonData);

    List<MenuItemData> menuItemList;
    for (Map map in jsonEntries) {
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

        menuItemList.add(MenuItemData(label, start, end));
      }

      TarikhController.to._tarikhMenuData.add(MenuSectionData(
          label, textColor, backgroundColor, assetId, menuItemList));
      TarikhController.to.update();
    }
  }
}
