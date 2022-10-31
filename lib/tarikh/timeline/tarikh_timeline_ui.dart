import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/event/et.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/event/event_c.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_render_widget.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';

typedef ShowMenuCallback = Function();
typedef SelectItemCallback = Function(Event event);

/// This is the Stateful Widget associated with the Timeline object.
/// It is built from a [focusItem], that is the event the [Timeline] should
/// focus on when it's created.
// ignore: must_be_immutable
class TarikhTimelineUI extends StatefulWidget {
  TarikhTimelineUI() {
    focusItem = Get.arguments['focusItem'];
    event = Get.arguments['event'];
  }

  /// focusItem may have a bigger time span (via menu.json) on the timeline
  /// compared to loading just a single event (from timeline.json).
  late final MenuItemData focusItem;

  /// if null, we must lookup event and then set up/dn btns manually
  Event? event;

  // TODO needed for widget update detect?:
  final Timeline timeline = TarikhC.t;

  @override
  _TarikhTimelineUIState createState() => _TarikhTimelineUIState();
}

class _TarikhTimelineUIState extends State<TarikhTimelineUI> {
  static final Timeline t = TarikhC.t; // used a lot so shorten it.

  static const double TopOverlap = 0.0; //56.0;

  /// These variables are used to calculate the correct viewport for the timeline
  /// when performing a scaling operation as in [_scaleStart], [_scaleUpdate], [_scaleEnd].
  Offset? _lastFocalPoint;
  double _scaleStartYearStart = -100.0;
  double _scaleStartYearEnd = 100.0;

  /// When touching a bubble on the [Timeline] keep track of which
  /// element has been touched in order to move to the [article_widget].
  TapTarget? _touchedBubble;
  Event? _touchedEvent;

  /// Which era the Timeline is currently focused on.
  /// Defaults to [tkDefaultEraName].
  String _tvEraName = '';

  Color? _headerTextColor;
  //Color? _headerBackgroundColor; // CAN DO: cleanup/reuse for other coloring

  /// Tez was originally not here, good to have:
  @override
  void dispose() {
    super.dispose();
    TarikhC.to.isActiveTimeline = false;
  }

  @override
  initState() {
    if (widget.event == null) {
      // lookup event manually since not provided on init
      widget.event = EventC.to.getEventMap(ET.Tarikh)[widget.focusItem.saveTag];

      // We need event just to update down/up past/future btns. Since it wasn't
      // used/available/wanted? by the original caller to this class, we ignore
      // the view/focusItem MenuItemData.fromEvent returns here:
      MenuItemData.fromEvent(widget.event!);
    }

    TarikhC.to.isActiveTimeline = true;

    _tvEraName =
        t.currentEra != null ? 'Era'.tr + ': ' + a(t.currentEra!.tkTitle) : '';

    t.onHeaderColorsChanged = (/*Color background,*/ Color text) {
      setState(() {
        _headerTextColor = text;
//      _headerBackgroundColor = background;
      });
    };

    /// Update the label for the [Timeline] object.
    t.onEraChanged = (Event? event) {
      setState(() => _tvEraName =
          'Era'.tr + ': ' + (event != null ? a(event.tkTitle) : ''));
    };

    if (t.headerTextColor != null) {
      _headerTextColor = t.headerTextColor!;
    } else {
      _headerTextColor = null;
    }
    // if (t.headerBackgroundColor != null) {
    //   _headerBackgroundColor = t.headerBackgroundColor!;
    // } else {
    //   _headerBackgroundColor = null;
    // }

    // Timer(Duration(milliseconds: 2000), //Tez: I think this was always commented
    //     () => _tapUp(new TapUpDetails(kind: PointerDeviceKind.values[0])));

    super.initState();
  }

  /// The following three functions define are the callbacks used by the
  /// [GestureDetector] widget when rendering this widget.
  /// First gather the information regarding the starting point of the scaling operation.
  /// Then perform the update based on the incoming [ScaleUpdateDetails] data,
  /// and pass the relevant information down to the [Timeline], so that it can display
  /// all the relevant information properly.
  void _scaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
    _scaleStartYearStart = t.start;
    _scaleStartYearEnd = t.end;
    t.isInteracting = true;
    t.setViewport(velocity: 0.0, animate: true);
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    double changeScale = details.scale;
    double scale =
        (_scaleStartYearEnd - _scaleStartYearStart) / context.size!.height;

    double focus = _scaleStartYearStart + details.focalPoint.dy * scale;
    double focalDiff =
        (_scaleStartYearStart + _lastFocalPoint!.dy * scale) - focus;
    t.setViewport(
      start: focus + (_scaleStartYearStart - focus) / changeScale + focalDiff,
      end: focus + (_scaleStartYearEnd - focus) / changeScale + focalDiff,
      height: context.size!.height,
      animate: true,
    );
  }

  void _scaleEnd(ScaleEndDetails details) {
    t.isInteracting = false;
    t.setViewport(velocity: details.velocity.pixelsPerSecond.dy, animate: true);
  }

  /// The following two callbacks are passed down to the [TimelineRenderWidget] so
  /// that it can pass the information back to this widget.
  onTouchBubble(TapTarget? bubble) => _touchedBubble = bubble;

  onTouchEvent(Event? event) => _touchedEvent = event;

  void _tapDown(TapDownDetails details) =>
      t.setViewport(velocity: 0.0, animate: true);

  void _navigateToTimeline(Event event, double devicePaddingTop) {
    // updates up/down buttons:
    MenuItemData target = MenuItemData.fromEvent(event);

    t.padding = EdgeInsets.only(
      top: MediaQuery.of(context).size.height, //TODO WHY DOES THIS CENTER EVENT
      //was: TopOverlap + devicePaddingTop + target.padTop + Timeline.Parallax,
      //bottom: target.padBottom,
    );
    t.setViewport(
        start: target.start, end: target.end, animate: true, pad: true);
  }

  /// If the [TimelineRenderWidget] has set the [_touchedBubble] to the currently
  /// touched bubble on the timeline, upon removing the finger from the screen,
  /// the app will check if the touch operation consists of a zooming operation.
  ///
  /// If it is, adjust the layout accordingly.
  /// Otherwise trigger a [Navigator.push()] for the tapped bubble. This moves
  /// the app into the [EventUI].
  void _tapUp(TapUpDetails details) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    if (_touchedBubble != null) {
      if (_touchedBubble!.zoom) {
        _navigateToTimeline(_touchedBubble!.event, devicePadding.top);
      } else {
        // stop rendering here, menu controller re-enables it
        TarikhC.to.isActiveTimeline = false;
        MenuC.to.pushSubPage(SubPage.Event_Details, arguments: {
          'et': ET.Tarikh,
          'eventMap': EventC.to.getEventMap(ET.Tarikh),
          'saveTag': _touchedBubble!.event.saveTag,
        });

        //t.isActive = true; // TODO working? was below:
        // Navigator.of(context)
        //     .push(MaterialPageRoute(
        //         builder: (BuildContext context) => TarikhArticleUI(
        //               event: _touchedBubble!.event!,
        //               key: null,
        //             )))
        //     .then((v) => widget.t.isActive = true);
      }
    } else if (_touchedEvent != null) {
      _navigateToTimeline(_touchedEvent!, devicePadding.top);
    }
  }

  /// When performing a long-press operation, the viewport will be adjusted so that
  /// the visible start and end times will be updated according to the [Event]
  /// information. The long-pressed bubble will float to the top of the viewport,
  /// and the viewport will be scaled appropriately.
  void _longPress() {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    if (_touchedBubble != null) {
      _navigateToTimeline(_touchedBubble!.event, devicePadding.top);
    }
  }

  // TODO needed? never saw it called
  /// Update the current view and change the timeline header, color and background color,
  @override
  void didUpdateWidget(covariant TarikhTimelineUI oldWidget) {
    super.didUpdateWidget(oldWidget);

    l.w('********************* Timeline: didUpdateWidget ******************');

    // TODO what is this doing?:
    if (t != oldWidget.timeline) {
      l.w('Timeline: didUpdateWidget true');
      setState(() {
        _headerTextColor = t.headerTextColor;
//      _headerBackgroundColor = t.headerBackgroundColor;
      });

      t.onHeaderColorsChanged = (/*Color background,*/ Color text) {
        setState(() {
          _headerTextColor = text;
//        _headerBackgroundColor = background;
        });
      };
      t.onEraChanged = (Event? event) {
        setState(() => _tvEraName = event != null ? a(event.tkTitle) : '');
      };
      setState(() =>
          _tvEraName = t.currentEra != null ? a(t.currentEra!.tkTitle) : '');
    } else {
      l.w('Timeline: didUpdateWidget false');
    }
  }

  /// This is a [StatefulWidget] life-cycle method. It's being overridden here
  /// so that we can properly update the [Timeline] widget.
  @override
  deactivate() {
    super.deactivate();

    t.onHeaderColorsChanged = null;
    t.onEraChanged = null;
  }

  /// This widget is wrapped in a [Scaffold] to have the classic Material Design visual layout structure.
  /// Then the body of the app is made of a [GestureDetector] to properly handle all the user-input events.
  /// This widget then lays down a [Stack]:
  ///   - [TimelineRenderWidget] renders the actual contents of the timeline such as the currently visible
  ///   bubbles with their corresponding [FlareWidget]s, the left bar with the ticks, etc.
  ///   - [BackdropFilter] that wraps the top header bar, with the back button, the favorites button, and its coloring.
  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    t.devicePadding = devicePadding;

    const double fabWidth = 71; // 56 + 15
    const double middleButtonsGap = 5;
    final double w2 = (w(context) - (fabWidth * 2) - middleButtonsGap) / 2;
    final double titleWidth = w(context) - fabWidth;
    const double height = 160;

    // Color? color = _headerTextColor != null
    //     ? _headerTextColor
    //     : darkText.withOpacity(darkText.opacity * 0.75);

    return FabSubPage(
      subPage: SubPage.Tarikh_Timeline,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.miniCenterDocked,
          floatingActionButton: GetBuilder<TarikhC>(builder: (c) {
            TimeBtn btnUp = c.timeBtnUp;
            TimeBtn btnDn = c.timeBtnDn;

            return Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(
                height: height,
                child: Row(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Column dummy to easily vertical align up/down fabs:
                    SizedBox(
                      width: fabWidth,
                      child: Padding(
                        //TODO RTL ok?
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FloatingActionButton(
                              tooltip: _tkGutterTooltip(c).tr,
                              heroTag: Icons.favorite_border_outlined,
                              onPressed: () => _handleGutterBtnHit(c),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              child: Icon(_getGutterIconData(c), size: 36),
                            ),
                            T('', tsRe, w: w2, h: 17),
                            const SizedBox(height: 1),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      //TODO RTL ok?
                      padding: EdgeInsets.only(
                        left:
                            !c.isGutterModeOff && MainC.to.isPortrait ? 25 : 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: w2,
                            child: btnUp.event == null
                                ? Container()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      T(
                                        btnUp.tvTitleLine1,
                                        tsRe,
                                        w: w2,
                                        h: 18,
                                        tv: true,
                                      ),
                                      if (btnUp.tvTitleLine2 != '')
                                        T(
                                          btnUp.tvTitleLine2,
                                          tsRe,
                                          w: w2,
                                          h: 18,
                                          tv: true,
                                        ),
                                      T(
                                        btnUp.tvPageScrolls,
                                        tsRe,
                                        w: w2,
                                        h: 17,
                                        tv: true,
                                      ),
                                      FloatingActionButton(
                                        tooltip: 'Navigate to past'.tr,
                                        heroTag: 'btnUp', // needed
                                        onPressed: () => _navigateToTimeline(
                                            btnUp.event!, devicePadding.top),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.padded,
                                        child: const Icon(
                                          Icons.arrow_upward_outlined,
                                          size: 30.0,
                                        ),
                                      ),
                                      T(
                                        btnUp.tvTimeUntil,
                                        tsRe,
                                        w: w2,
                                        h: 17,
                                        tv: true,
                                      ),
                                      const SizedBox(height: 1),
                                    ],
                                  ),
                          ),
                          const SizedBox(width: middleButtonsGap),
                          SizedBox(
                            width: w2,
                            child: btnDn.event == null
                                ? Container()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      T(
                                        btnDn.tvTitleLine1,
                                        tsRe,
                                        w: w2,
                                        h: 18,
                                        tv: true,
                                      ),
                                      if (btnDn.tvTitleLine2 != '')
                                        T(
                                          btnDn.tvTitleLine2,
                                          tsRe,
                                          w: w2,
                                          h: 18,
                                          tv: true,
                                        ),
                                      T(
                                        btnDn.tvPageScrolls,
                                        tsRe,
                                        w: w2,
                                        h: 17,
                                        tv: true,
                                      ),
                                      FloatingActionButton(
                                        tooltip: 'Navigate to future'.tr,
                                        heroTag: 'btnDn', // needed
                                        onPressed: () => _navigateToTimeline(
                                            btnDn.event!, devicePadding.top),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.padded,
                                        child: const Icon(
                                          Icons.arrow_downward_outlined,
                                          size: 30.0,
                                        ),
                                      ),
                                      T(
                                        btnDn.tvTimeUntil,
                                        tsRe,
                                        w: w2,
                                        h: 17,
                                        tv: true,
                                      ),
                                      const SizedBox(height: 1),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                    // const SizedBox(width: rightFabWidth), // menu fab
                  ],
                ),
              ),
            );
          }),
          backgroundColor: Colors.white,
          body: GestureDetector(
            onLongPress: _longPress,
            onTapDown: _tapDown,
            onScaleStart: _scaleStart,
            onScaleUpdate: _scaleUpdate,
            onScaleEnd: _scaleEnd,
            onTapUp: _tapUp,
            child: Stack(
              children: <Widget>[
                Hero(
                  tag: widget.focusItem.saveTag, // TODO use it or remove...
                  child: TimelineRenderWidget(
                    needsRepaint: true,
                    topOverlap: TopOverlap + devicePadding.top,
                    focusItem: widget.focusItem,
                    touchBubble: onTouchBubble,
                    touchEvent: onTouchEvent,
                  ),
                ),
                Padding(
                  //TODO RTL ok?
                  padding: EdgeInsets.only(
                    top: 20,
                    left: MainC.to.isPortrait ? 60 : 20,
                  ),
                  child: T(
                    _tvEraName,
                    tsRe,
                    w: titleWidth,
                    h: 25,
                    tv: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tkGutterTooltip(TarikhC c) {
    switch (c.gutterMode) {
      case GutterMode.OFF:
        return 'Show favorite events';
      case GutterMode.FAV:
        return 'Show all events';
      case GutterMode.ALL:
        return 'Hide events';
    }
  }

  _handleGutterBtnHit(TarikhC c) {
    switch (c.gutterMode) {
      case GutterMode.OFF:
        c.gutterMode = GutterMode.FAV;
        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        showSnackBar('Show favorite events', '', isRed: true); // for white bg
        break;
      case GutterMode.FAV:
        c.gutterMode = GutterMode.ALL;
        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        showSnackBar('Show all events', '', isRed: true);
        break;
      case GutterMode.ALL:
        c.gutterMode = GutterMode.OFF;
        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        break;
    }
  }

  IconData _getGutterIconData(TarikhC c) {
    switch (c.gutterMode) {
      case GutterMode.OFF:
        return Icons.favorite_border_outlined;
      case GutterMode.FAV:
        if (c.isGutterFavEmpty) return Icons.heart_broken_outlined;
        return Icons.favorite_outlined;
      case GutterMode.ALL:
        return Icons.history_edu_outlined;
    }
  }
}
