import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/colors.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';
import 'package:hapi/tarikh/timeline/timeline_render_widget.dart';
import 'package:hapi/tarikh/timeline/timeline_utils.dart';

typedef ShowMenuCallback();
typedef SelectItemCallback(TimelineEntry item);

/// This is the Stateful Widget associated with the Timeline object.
/// It is built from a [focusItem], that is the event the [Timeline] should
/// focus on when it's created.
class TarikhTimelineUI extends StatefulWidget {
  TarikhTimelineUI() {
    focusItem = Get.arguments['focusItem'];
  }

  late final MenuItemData focusItem;
  final Timeline timeline =
      TarikhController.t; // TODO needed for widget update detect?

  @override
  _TarikhTimelineUIState createState() => _TarikhTimelineUIState();
}

class _TarikhTimelineUIState extends State<TarikhTimelineUI> {
  static final Timeline t = TarikhController.t;

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

  @override
  initState() {
    t.isActive = true;
    _eraName = t.currentEra != null ? t.currentEra!.label! : DefaultEraName;
    t.onHeaderColorsChanged = (Color background, Color text) {
      setState(() {
        _headerTextColor = text;
        _headerBackgroundColor = background;
      });
    };

    /// Update the label for the [Timeline] object.
    t.onEraChanged = (TimelineEntry? entry) {
      setState(() {
        _eraName = 'Era: ' + (entry != null ? entry.label! : DefaultEraName);
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
      top: TopOverlap + devicePaddingTop + target.padTop + Timeline.Parallax,
      bottom: target.padBottom,
    );
    t.setViewport(
        start: target.start!, end: target.end!, animate: true, pad: true);
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
        _navigateToTimeline(_touchedEntry!, devicePadding.top);
      } else {
        t.isActive = false;

        cMenu.pushSubPage(SubPage.TARIKH_ARTICLE, arguments: {
          'article': _touchedBubble!.entry!,
        });

        t.isActive = true; // TODO working? was below:
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
      _navigateToTimeline(_touchedBubble!.entry!, devicePadding.top);
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
          _eraName = entry != null ? entry.label! : DefaultEraName;
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

    Color? color = _headerTextColor != null
        ? _headerTextColor
        : darkText.withOpacity(darkText.opacity * 0.75);

    return FabSubPage(
      subPage: SubPage.TARIKH_TIMELINE,
      child: Scaffold(
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        floatingActionButton: GetBuilder<TarikhController>(
            init: TarikhController(),
            builder: (c) {
              TimeBtn btnUp = c.timeBtnUp();
              TimeBtn btnDn = c.timeBtnDn();
              return Align(
                alignment: Alignment.bottomLeft,
                child: Row(
                  //mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Column dummy to easily verticle align up/down fabs:
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        //mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FloatingActionButton(
                            tooltip: 'Show/hide favorite or all events',
                            heroTag: SubPage.TARIKH_FAVORITE,
                            onPressed: () {
                              if (c.isGutterModeOff()) {
                                c.gutterMode = GutterMode.FAV;
                              } else if (c.isGutterModeFav()) {
                                c.gutterMode = GutterMode.ALL;
                              } else /* if (c.isGutterModeAll) */ {
                                c.gutterMode = GutterMode.OFF;
                              }
                            },
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            child: c.isGutterModeOff()
                                ? const Icon(Icons.favorite_border_outlined,
                                    size: 36.0)
                                : c.isGutterModeFav()
                                    ? Icon(Icons.favorite_outlined, size: 36.0)
                                    : Icon(Icons.close, size: 36.0),
                          ),
                          Text(''),
                          SizedBox(height: 1.8),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: c.isGutterModeOff() ? 0 : 45),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        //mainAxisAlignment: MainAxisAlignment.center,
                        //crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              btnUp.title,
                              style: TextStyle(color: color),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              btnUp.timeUntil,
                              style: TextStyle(color: color),
                            ),
                          ),
                          FloatingActionButton(
                            tooltip: 'Navigate to past',
                            heroTag: null, // needed
                            onPressed: () {
                              if (btnUp.entry != null) {
                                print(
                                    'Navigate to past: ' + btnUp.entry!.label!);
                                _navigateToTimeline(
                                    btnUp.entry!, devicePadding.top);
                              }
                            },
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            child: Icon(Icons.expand_less_outlined, size: 36.0),
                          ),
                          FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              btnUp.pageScrolls,
                              style: TextStyle(color: color),
                            ),
                          ),
                          SizedBox(height: 1.8),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            btnDn.title,
                            style: TextStyle(color: color),
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            btnDn.timeUntil,
                            style: TextStyle(color: color),
                          ),
                        ),
                        FloatingActionButton(
                          tooltip: 'Navigate to future',
                          heroTag: null, // needed
                          onPressed: () {
                            if (btnDn.entry != null) {
                              print(
                                  'Navigate to future: ' + btnDn.entry!.label!);
                              _navigateToTimeline(
                                  btnDn.entry!, devicePadding.top);
                            }
                          },
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          child: Icon(Icons.expand_more_outlined, size: 36.0),
                        ),
                        FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            btnDn.pageScrolls,
                            style: TextStyle(color: color),
                          ),
                        ),
                        SizedBox(height: 1.8),
                      ],
                    ),
                    Container(
                        constraints: BoxConstraints(
                          minWidth: 61,
                          maxWidth: 61,
                          minHeight: 63,
                          maxHeight: 63,
                        ),
                        child: SizedBox(width: 56)),
                  ],
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
              Align(
                alignment: Alignment.topCenter,
                // FYI used to have container and background:
                // color: _headerBackgroundColor != null
                //     ? _headerBackgroundColor
                //     : Color.fromRGBO(238, 240, 242, 0.81),
                child: Padding(
                  padding: EdgeInsets.only(top: 20, left: 40),
                  child: Text(
                    _eraName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "RobotoMedium",
                      fontSize: 20.0,
                      color: _headerTextColor != null
                          ? _headerTextColor
                          : darkText.withOpacity(darkText.opacity * 0.75),
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
