import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
import 'package:hapi/tarikh/timeline/timeline_render_widget.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';

typedef ShowMenuCallback = Function();
typedef SelectItemCallback = Function(TimelineEntry item);

/// This is the Stateful Widget associated with the Timeline object.
/// It is built from a [focusItem], that is the event the [Timeline] should
/// focus on when it's created.
// ignore: must_be_immutable
class TarikhTimelineUI extends StatefulWidget {
  TarikhTimelineUI() {
    focusItem = Get.arguments['focusItem'];
    entry = Get.arguments['entry'];
  }

  /// focusItem may have a bigger time span (via menu.json) on the timeline
  /// compared to loading just a single entry (from timeline.json).
  late final MenuItemData focusItem;

  /// if null, we must lookup entry and then set up/dn btns manually
  TimelineEntry? entry;

  // TODO needed for widget update detect?:
  final Timeline timeline = TarikhController.t;

  @override
  _TarikhTimelineUIState createState() => _TarikhTimelineUIState();
}

class _TarikhTimelineUIState extends State<TarikhTimelineUI> {
  static final Timeline t = TarikhController.t; // used a lot so shorten it.

  // TODO fix shows anytime no era on timeline, should be blank or something like "Unnamed Era"
  static const String trKeyDefaultEraName = ''; //i.Birth of the Universe';
  static const double TopOverlap = 0.0; //56.0;

  /// These variables are used to calculate the correct viewport for the timeline
  /// when performing a scaling operation as in [_scaleStart], [_scaleUpdate], [_scaleEnd].
  Offset? _lastFocalPoint;
  double _scaleStartYearStart = -100.0;
  double _scaleStartYearEnd = 100.0;

  /// When touching a bubble on the [Timeline] keep track of which
  /// element has been touched in order to move to the [article_widget].
  TapTarget? _touchedBubble;
  TimelineEntry? _touchedEntry;

  /// Which era the Timeline is currently focused on.
  /// Defaults to [trKeyDefaultEraName].
  String _trValEraName = '';

  Color? _headerTextColor;
  //Color? _headerBackgroundColor; // CAN DO: cleanup/reuse for other coloring

  /// Tez was originally not here, good to have:
  @override
  void dispose() {
    super.dispose();
    TarikhController.to.isActiveTimeline = false;
  }

  @override
  initState() {
    if (widget.entry == null) {
      // lookup entry manually since not provided on init
      widget.entry = TarikhController.to.eventMap[widget.focusItem.label];

      // We need entry just to update down/up past/future btns. Since it wasn't
      // used/available/wanted? by the original caller to this class, we ignore
      // the view/focusItem MenuItemData.fromEntry returns here:
      MenuItemData.fromEntry(widget.entry!);
    }

    TarikhController.to.isActiveTimeline = true;
    _trValEraName = 'i.Era'.tr +
        ': ' +
        (t.currentEra != null
            ? t.currentEra!.trValTitle
            : trKeyDefaultEraName.tr);
    t.onHeaderColorsChanged = (/*Color background,*/ Color text) {
      setState(() {
        _headerTextColor = text;
        //_headerBackgroundColor = background;
      });
    };

    /// Update the label for the [Timeline] object.
    t.onEraChanged = (TimelineEntry? entry) {
      setState(() {
        _trValEraName =
            'i.Era'.tr + ': ' + (entry != null ? entry.trValTitle : '');
      });
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
  onTouchBubble(TapTarget? bubble) {
    _touchedBubble = bubble;
  }

  onTouchEntry(TimelineEntry? entry) {
    _touchedEntry = entry;
  }

  void _tapDown(TapDownDetails details) {
    t.setViewport(velocity: 0.0, animate: true);
  }

  void _navigateToTimeline(TimelineEntry entry, double devicePaddingTop) {
    // updates up/down buttons:
    MenuItemData target = MenuItemData.fromEntry(entry);

    t.padding = EdgeInsets.only(
      top: MediaQuery.of(context).size.height, //TODO WHY DOES THIS CENTER EVENT
      //was: TopOverlap + devicePaddingTop + target.padTop + Timeline.Parallax,
      //bottom: target.padBottom,
    );
    t.setViewport(
        start: target.startMs, end: target.endMs, animate: true, pad: true);
  }

  /// If the [TimelineRenderWidget] has set the [_touchedBubble] to the currently
  /// touched bubble on the timeline, upon removing the finger from the screen,
  /// the app will check if the touch operation consists of a zooming operation.
  ///
  /// If it is, adjust the layout accordingly.
  /// Otherwise trigger a [Navigator.push()] for the tapped bubble. This moves
  /// the app into the [TarikhArticleUI].
  void _tapUp(TapUpDetails details) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    if (_touchedBubble != null) {
      if (_touchedBubble!.zoom) {
        _navigateToTimeline(_touchedBubble!.entry, devicePadding.top);
      } else {
        // stop rendering here, menu controller re-enables it
        TarikhController.to.isActiveTimeline = false;
        MenuController.to.pushSubPage(SubPage.Tarikh_Article, arguments: {
          'article': _touchedBubble!.entry,
        });

        //t.isActive = true; // TODO working? was below:
        // Navigator.of(context)
        //     .push(MaterialPageRoute(
        //         builder: (BuildContext context) => TarikhArticleUI(
        //               article: _touchedBubble!.entry!,
        //               key: null,
        //             )))
        //     .then((v) => widget.t.isActive = true);
      }
    } else if (_touchedEntry != null) {
      _navigateToTimeline(_touchedEntry!, devicePadding.top);
    }
  }

  /// When performing a long-press operation, the viewport will be adjusted so that
  /// the visible start and end times will be updated according to the [TimelineEntry]
  /// information. The long-pressed bubble will float to the top of the viewport,
  /// and the viewport will be scaled appropriately.
  void _longPress() {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    if (_touchedBubble != null) {
      _navigateToTimeline(_touchedBubble!.entry, devicePadding.top);
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
        // _headerBackgroundColor = t.headerBackgroundColor;
      });

      t.onHeaderColorsChanged = (/*Color background,*/ Color text) {
        setState(() {
          _headerTextColor = text;
          // _headerBackgroundColor = background;
        });
      };
      t.onEraChanged = (TimelineEntry? entry) {
        setState(() {
          _trValEraName =
              entry != null ? entry.trValTitle : trKeyDefaultEraName.tr;
        });
      };
      setState(() {
        _trValEraName = t.currentEra != null
            ? t.currentEra!.trValTitle
            : trKeyDefaultEraName.tr;
        //t.isActive = true;
      });
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

    const double fabWidth = 56 + 15;
    const double middleButtonsGap = 5;
    double w2 = (w(context) - (fabWidth * 2) - middleButtonsGap) / 2;
    double titleWidth = w(context) - fabWidth;
    double height = 160;

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
          floatingActionButton: GetBuilder<TarikhController>(builder: (c) {
            TimeBtn btnUp = c.timeBtnUp;
            TimeBtn btnDn = c.timeBtnDn;

            String trValUpTitle1 = '';
            String trValUpTitle2 = btnUp.trValTitle;
            List<String> btnUpList = trValUpTitle2.split('\n');
            if (btnUpList.length == 2) {
              trValUpTitle1 = btnUpList[0];
              trValUpTitle2 = btnUpList[1];
            }

            String trValDnTitle1 = '';
            String trValDnTitle2 = btnDn.trValTitle;
            List<String> btnDnList = trValDnTitle2.split('\n');
            if (btnDnList.length == 2) {
              trValDnTitle1 = btnDnList[0];
              trValDnTitle2 = btnDnList[1];
            }

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
                        padding: const EdgeInsets.only(left: 15),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FloatingActionButton(
                              tooltip: c.isGutterModeOff
                                  ? 'i.Show favorite events'.tr
                                  : c.isGutterModeFav
                                      ? 'i.Show all events'.tr
                                      : 'i.Hide events'.tr,
                              heroTag: 'Tarikh_Favorite',
                              onPressed: () {
                                if (c.isGutterModeOff) {
                                  c.gutterMode = GutterMode.FAV;
                                  showSnackBar(
                                    'i.Show favorite events',
                                    '',
                                    isRed: true, // so shows on white background
                                  );
                                } else if (c.isGutterModeFav) {
                                  c.gutterMode = GutterMode.ALL;
                                  showSnackBar(
                                    'i.Show all events',
                                    '',
                                    isRed: true,
                                  );
                                } else /* if (c.isGutterModeAll) */ {
                                  c.gutterMode = GutterMode.OFF;
                                  if (Get.isSnackbarOpen) {
                                    Get.closeCurrentSnackbar();
                                  }
                                }
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              child: c.isGutterModeOff
                                  ? const Icon(Icons.history_edu_outlined,
                                      size: 36.0)
                                  : c.isGutterModeFav
                                      ? const Icon(
                                          Icons.favorite_border_outlined,
                                          size: 36.0)
                                      : const Icon(Icons.close, size: 36.0),
                            ),
                            T('', tsR, w: w2, h: 17),
                            const SizedBox(height: 1),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: !c.isGutterModeOff && MainController.to.isPortrait
                            ? 25
                            : 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: w2,
                            child: btnUp.entry == null
                                ? Container()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      T(
                                        trValUpTitle1,
                                        tsR,
                                        w: w2,
                                        h: 18,
                                        trVal: true,
                                      ),
                                      T(
                                        trValUpTitle2,
                                        tsR,
                                        w: w2,
                                        h: 18,
                                        trVal: true,
                                      ),
                                      T(
                                        btnUp.trValTimeUntil,
                                        tsR,
                                        w: w2,
                                        h: 17,
                                        trVal: true,
                                      ),
                                      FloatingActionButton(
                                        tooltip: 'i.Navigate to past'.tr,
                                        heroTag: null, // needed
                                        onPressed: () => _navigateToTimeline(
                                            btnUp.entry!, devicePadding.top),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.padded,
                                        child: const Icon(
                                          Icons.arrow_upward_outlined,
                                          size: 30.0,
                                        ),
                                      ),
                                      T(
                                        btnUp.trValPageScrolls,
                                        tsR,
                                        w: w2,
                                        h: 17,
                                        trVal: true,
                                      ),
                                      const SizedBox(height: 1),
                                    ],
                                  ),
                          ),
                          const SizedBox(width: middleButtonsGap),
                          SizedBox(
                            width: w2,
                            child: btnDn.entry == null
                                ? Container()
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      T(
                                        trValDnTitle1,
                                        tsR,
                                        w: w2,
                                        h: 18,
                                        trVal: true,
                                      ),
                                      T(
                                        trValDnTitle2,
                                        tsR,
                                        w: w2,
                                        h: 18,
                                        trVal: true,
                                      ),
                                      T(
                                        btnDn.trValTimeUntil,
                                        tsR,
                                        w: w2,
                                        h: 17,
                                        trVal: true,
                                      ),
                                      FloatingActionButton(
                                        tooltip: 'i.Navigate to future'.tr,
                                        heroTag: null, // needed
                                        onPressed: () => _navigateToTimeline(
                                            btnDn.entry!, devicePadding.top),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.padded,
                                        child: const Icon(
                                          Icons.arrow_downward_outlined,
                                          size: 30.0,
                                        ),
                                      ),
                                      T(
                                        btnDn.trValPageScrolls,
                                        tsR,
                                        w: w2,
                                        h: 17,
                                        trVal: true,
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
                TimelineRenderWidget(
                  needsRepaint: true,
                  topOverlap: TopOverlap + devicePadding.top,
                  focusItem: widget.focusItem,
                  touchBubble: onTouchBubble,
                  touchEntry: onTouchEntry,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: 20,
                    left: MainController.to.isPortrait ? 60 : 20,
                  ),
                  child: T(
                    _trValEraName,
                    tsR,
                    w: titleWidth,
                    h: 25,
                    trVal: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
