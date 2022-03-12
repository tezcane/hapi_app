//import 'dart:ui'; TODO needed?

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';
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

  final Timeline timeline =
      TarikhController.t; // TODO needed for widget update detect?

  @override
  _TarikhTimelineUIState createState() => _TarikhTimelineUIState();
}

class _TarikhTimelineUIState extends State<TarikhTimelineUI> {
  static final Timeline t = TarikhController.t; // used a lot so shorten it.

  // TODO fix shows anytime no era on timeline, should be blank or something like "Unnamed Era"
  static const String DefaultEraName = "Birth of the Universe";
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
  /// Defaults to [DefaultEraName].
  String _eraName = '';

  Color? _headerTextColor;
  Color? _headerBackgroundColor; // TODO should we delete?

  /// Tez was originally not here, good to have:
  @override
  void dispose() {
    super.dispose();
    t.isActive = false;
  }

  @override
  initState() {
    if (widget.entry == null) {
      // lookup entry manually since not provided on init
      widget.entry = t.findEntry(widget.focusItem.label);

      // We need entry just to update down/up past/future btns. Since it wasn't
      // used/available/wanted? by the original caller to this class, we ignore
      // the view/focusItem MenuItemData.fromEntry returns here:
      MenuItemData.fromEntry(widget.entry!);
    }

    t.isActive = true;
    _eraName = t.currentEra != null ? t.currentEra!.label : DefaultEraName;
    t.onHeaderColorsChanged = (Color background, Color text) {
      setState(() {
        _headerTextColor = text;
        _headerBackgroundColor = background;
      });
    };

    /// Update the label for the [Timeline] object.
    t.onEraChanged = (TimelineEntry? entry) {
      setState(() {
        _eraName = 'Era: ' + (entry != null ? entry.label : DefaultEraName);
      });
    };

    if (t.headerTextColor != null) {
      _headerTextColor = t.headerTextColor!;
    } else {
      // _headerTextColor = null; // TODO
    }
    if (t.headerBackgroundColor != null) {
      _headerBackgroundColor = t.headerBackgroundColor!;
    } else {
      // _headerBackgroundColor = null; // TODO
    }

    // Timer(Duration(milliseconds: 2000), //TODO i think this was always commented
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
        animate: true);
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
    MenuItemData target = MenuItemData.fromEntry(entry);

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
  /// the app into the [TarikhArticleUI].
  void _tapUp(TapUpDetails details) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    if (_touchedBubble != null) {
      if (_touchedBubble!.zoom) {
        _navigateToTimeline(_touchedBubble!.entry, devicePadding.top);
      } else {
        t.isActive = false; // stop rendering here, menu controller re-enables
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

    // TODO what is this doing?:
    if (t != oldWidget.timeline) {
      print('Timeline: didUpdateWidget true');
      setState(() {
        _headerTextColor = t.headerTextColor;
        _headerBackgroundColor = t.headerBackgroundColor;
      });

      t.onHeaderColorsChanged = (Color background, Color text) {
        setState(() {
          _headerTextColor = text;
          _headerBackgroundColor = background;
        });
      };
      t.onEraChanged = (TimelineEntry? entry) {
        setState(() {
          _eraName = entry != null ? entry.label : DefaultEraName;
        });
      };
      setState(() {
        _eraName =
            t.currentEra != null ? t.currentEra as String : DefaultEraName;
        //t.isActive = true; //TODO old showFavirts called _startRendering(), but i think was for heart flare animation
      });
    } else {
      print('Timeline: didUpdateWidget false');
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

    // Color? color = _headerTextColor != null
    //     ? _headerTextColor
    //     : darkText.withOpacity(darkText.opacity * 0.75);

    return FabSubPage(
      subPage: SubPage.Tarikh_Timeline,
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: GetBuilder<TarikhController>(
          builder: (c) {
            const Color fabTextColor = AppThemes.logoText;
            TimeBtn btnUp = c.timeBtnUp();
            TimeBtn btnDn = c.timeBtnDn();
            return Stack(
              children: [
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    //mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Column dummy to easily vertical align up/down fabs:
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 14.5),
                      //   child: Column(
                      //     mainAxisSize: MainAxisSize.min,
                      //     //mainAxisAlignment: MainAxisAlignment.start,
                      //     children: [
                      //       Container(
                      //         constraints: BoxConstraints(
                      //           minWidth: 56,
                      //           maxWidth: 56,
                      //           minHeight: 56,
                      //           maxHeight: 56,
                      //         ),
                      //         child: SizedBox(width: 56, height: 56),
                      //       ),
                      //       Text(''),
                      //       SizedBox(height: 1.8),
                      //     ],
                      //   ),
                      // ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: c.isGutterModeOff() ? 10 : 55,
                          right: 9, // gap between text
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                btnUp.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: fabTextColor),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                btnUp.timeUntil,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: fabTextColor),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 88,
                                maxWidth: 88,
                                minHeight: 56,
                                maxHeight: 56,
                              ),
                              child: const SizedBox(width: 56, height: 56),
                            ),
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                btnUp.pageScrolls,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: fabTextColor),
                              ),
                            ),
                            const SizedBox(height: 1.8),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                btnDn.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: fabTextColor),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                btnDn.timeUntil,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: fabTextColor),
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(
                                minWidth: 88,
                                maxWidth: 88,
                                minHeight: 56,
                                maxHeight: 56,
                              ),
                              child: const SizedBox(width: 56, height: 56),
                            ),
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Text(
                                btnDn.pageScrolls,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: fabTextColor),
                              ),
                            ),
                            const SizedBox(height: 1.8),
                          ],
                        ),
                      ),
                      // Container(
                      //   constraints: BoxConstraints(
                      //     minWidth: 61,
                      //     maxWidth: 61,
                      //     minHeight: 63,
                      //     maxHeight: 63,
                      //   ),
                      //   child: SizedBox(width: 56),
                      // ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Row(
                    //mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Column dummy to easily vertical align up/down fabs:
                      Padding(
                        padding: const EdgeInsets.only(left: 14.5),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FloatingActionButton(
                              tooltip: 'Show/hide favorite or all events',
                              heroTag: SubPage.Tarikh_Favorite,
                              onPressed: () {
                                if (c.isGutterModeOff()) {
                                  c.gutterMode = GutterMode.FAV;
                                } else if (c.isGutterModeFav()) {
                                  c.gutterMode = GutterMode.ALL;
                                } else /* if (c.isGutterModeAll) */ {
                                  c.gutterMode = GutterMode.OFF;
                                }
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              child: c.isGutterModeOff()
                                  ? const Icon(Icons.favorite_border_outlined,
                                      size: 36.0)
                                  : c.isGutterModeFav()
                                      ? const Icon(Icons.favorite_outlined,
                                          size: 36.0)
                                      : const Icon(Icons.history_edu_outlined,
                                          size: 36.0),
                            ),
                            const Text(''),
                            const SizedBox(height: 1.8),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: c.isGutterModeOff() ? 0 : 45,
                          right: 9,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          //mainAxisAlignment: MainAxisAlignment.center,
                          //crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(''),
                            const Text(''),
                            if (btnUp.entry != null)
                              FloatingActionButton(
                                tooltip: 'Navigate to past',
                                heroTag: null, // needed
                                onPressed: () {
                                  print('Navigate to past: ' +
                                      btnUp.entry!.label);
                                  // cTrkh.setTBtnUp(cTrkh.getTimeBtn(
                                  //     btnUp.entry!.previous, 1.0));
                                  _navigateToTimeline(
                                      btnUp.entry!, devicePadding.top);
                                  // cTrkh.setTBtnDn(
                                  //     cTrkh.getTimeBtn(btnUp.entry, 1.0));
                                },
                                materialTapTargetSize:
                                    MaterialTapTargetSize.padded,
                                child: const Icon(Icons.arrow_upward_outlined,
                                    size: 30.0),
                              ),
                            const Text(''),
                            const SizedBox(height: 1.8),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        //mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(''),
                          const Text(''),
                          if (btnDn.entry != null)
                            FloatingActionButton(
                              tooltip: 'Navigate to future',
                              heroTag: null, // needed
                              onPressed: () {
                                print('Navigate to future: ' +
                                    btnDn.entry!.label);
                                // cTrkh.setTBtnDn(
                                //     cTrkh.getTimeBtn(btnDn.entry!.next, 1.0));
                                _navigateToTimeline(
                                    btnDn.entry!, devicePadding.top);
                                // cTrkh.setTBtnUp(
                                //     cTrkh.getTimeBtn(btnDn.entry, 1.0));
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                              child: const Icon(Icons.arrow_downward_outlined,
                                  size: 30.0),
                            ),
                          const Text(''),
                          const SizedBox(height: 1.8),
                        ],
                      ),
                      Container(
                        constraints: const BoxConstraints(
                          minWidth: 61,
                          maxWidth: 61,
                          minHeight: 63,
                          maxHeight: 63,
                        ),
                        child: const SizedBox(width: 56),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
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
              Align(
                alignment: Alignment.topCenter,
                // FYI used to have container and background:
                // color: _headerBackgroundColor != null
                //     ? _headerBackgroundColor
                //     : Color.fromRGBO(238, 240, 242, 0.81),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 40),
                  child: Text(
                    _eraName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "RobotoMedium",
                      fontSize: 20.0,
                      color: _headerTextColor ?? AppThemes.colorDarkText,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
