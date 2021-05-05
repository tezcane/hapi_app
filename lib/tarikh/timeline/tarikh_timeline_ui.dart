import 'dart:ui';

import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/article/tarikh_article_ui.dart';
import 'package:hapi/tarikh/blocs/bloc_provider.dart';
import 'package:hapi/tarikh/colors.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
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
  late MenuItemData focusItem;
  late Timeline timeline;

  TarikhTimelineUI() {
    focusItem = Get.arguments['focusItem'];
    timeline = Get.arguments['timeline'];
  }

  @override
  _TarikhTimelineUIState createState() => _TarikhTimelineUIState();
}

class _TarikhTimelineUIState extends State<TarikhTimelineUI> {
  // TODO fix shows anytime no era on timeline, should be blank or something like "Unnamed Era"
  static const String DefaultEraName = "Birth of the Universe";
  static const double TopOverlap = 56.0;

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
  late String _eraName;

  Color? _headerTextColor;
  Color? _headerBackgroundColor;

  /// This state variable toggles the rendering of the left sidebar
  /// showing the favorite elements already on the timeline.
  bool _showFavorites = false;

  @override
  initState() {
    widget.timeline.isActive = true;
    _eraName = widget.timeline.currentEra != null
        ? widget.timeline.currentEra!.label!
        : DefaultEraName;
    widget.timeline.onHeaderColorsChanged = (Color background, Color text) {
      setState(() {
        _headerTextColor = text;
        _headerBackgroundColor = background;
      });
    };

    /// Update the label for the [Timeline] object.
    widget.timeline.onEraChanged = (TimelineEntry? entry) {
      setState(() {
        _eraName = 'Era: " + (entry != null ? entry.label! : DefaultEraName);
      });
    };

    if (widget.timeline.headerTextColor != null) {
      _headerTextColor = widget.timeline.headerTextColor!;
    } else {
      // _headerTextColor = null; // TODO
    }
    if (widget.timeline.headerBackgroundColor != null) {
      _headerBackgroundColor = widget.timeline.headerBackgroundColor!;
    } else {
      // _headerBackgroundColor = null; // TODO
    }
    _showFavorites = widget.timeline.showFavorites;

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
    _scaleStartYearStart = widget.timeline.start;
    _scaleStartYearEnd = widget.timeline.end;
    widget.timeline.isInteracting = true;
    widget.timeline.setViewport(velocity: 0.0, animate: true);
  }

  void _scaleUpdate(ScaleUpdateDetails details) {
    double changeScale = details.scale;
    double scale =
        (_scaleStartYearEnd - _scaleStartYearStart) / context.size!.height;

    double focus = _scaleStartYearStart + details.focalPoint.dy * scale;
    double focalDiff =
        (_scaleStartYearStart + _lastFocalPoint!.dy * scale) - focus;
    widget.timeline.setViewport(
        start: focus + (_scaleStartYearStart - focus) / changeScale + focalDiff,
        end: focus + (_scaleStartYearEnd - focus) / changeScale + focalDiff,
        height: context.size!.height,
        animate: true);
  }

  void _scaleEnd(ScaleEndDetails details) {
    widget.timeline.isInteracting = false;
    widget.timeline.setViewport(
        velocity: details.velocity.pixelsPerSecond.dy, animate: true);
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
    widget.timeline.setViewport(velocity: 0.0, animate: true);
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
        MenuItemData target = MenuItemData.fromEntry(_touchedBubble!.entry!);

        widget.timeline.padding = EdgeInsets.only(
            top: TopOverlap +
                devicePadding.top +
                target.padTop +
                Timeline.Parallax,
            bottom: target.padBottom);
        widget.timeline.setViewport(
            start: target.start!, end: target.end!, animate: true, pad: true);
      } else {
        widget.timeline.isActive = false;

        cMenu.pushSubPage(SubPage.TARIKH_ARTICLE, arguments: {
          'article': _touchedBubble!.entry!,
        });

        widget.timeline.isActive = true; // TODO working? was below:
        // Navigator.of(context)
        //     .push(MaterialPageRoute(
        //         builder: (BuildContext context) => TarikhArticleUI(
        //               article: _touchedBubble!.entry!,
        //               key: null,
        //             )))
        //     .then((v) => widget.widget.timeline.isActive = true);
      }
    } else if (_touchedEntry != null) {
      MenuItemData target = MenuItemData.fromEntry(_touchedEntry!);

      widget.timeline.padding = EdgeInsets.only(
          top: TopOverlap +
              devicePadding.top +
              target.padTop +
              Timeline.Parallax,
          bottom: target.padBottom);
      widget.timeline.setViewport(
          start: target.start!, end: target.end!, animate: true, pad: true);
    }
  }

  // TODO what do you do???
  /// When performing a long-press operation, the viewport will be adjusted so that
  /// the visible start and end times will be updated according to the [TimelineEntry]
  /// information. The long-pressed bubble will float to the top of the viewport,
  /// and the viewport will be scaled appropriately.
  void _longPress() {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    if (_touchedBubble != null) {
      MenuItemData target = MenuItemData.fromEntry(_touchedBubble!.entry!);

      widget.timeline.padding = EdgeInsets.only(
          top: TopOverlap +
              devicePadding.top +
              target.padTop +
              Timeline.Parallax,
          bottom: target.padBottom);
      widget.timeline.setViewport(
          start: target.start!, end: target.end!, animate: true, pad: true);
    }
  }

  /// Update the current view and change the timeline header, color and background color,
  @override
  void didUpdateWidget(covariant TarikhTimelineUI oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.timeline != oldWidget.timeline) {
      setState(() {
        _headerTextColor = widget.timeline.headerTextColor;
        _headerBackgroundColor = widget.timeline.headerBackgroundColor;
      });

      widget.timeline.onHeaderColorsChanged = (Color background, Color text) {
        setState(() {
          _headerTextColor = text;
          _headerBackgroundColor = background;
        });
      };
      widget.timeline.onEraChanged = (TimelineEntry? entry) {
        setState(() {
          _eraName = entry != null ? entry.label! : DefaultEraName;
        });
      };
      setState(() {
        _eraName = widget.timeline.currentEra != null
            ? widget.timeline.currentEra as String
            : DefaultEraName;
        _showFavorites = widget.timeline.showFavorites;
      });
    }
  }

  /// This is a [StatefulWidget] life-cycle method. It's being overridden here
  /// so that we can properly update the [Timeline] widget.
  @override
  deactivate() {
    super.deactivate();

    widget.timeline.onHeaderColorsChanged = null;
    widget.timeline.onEraChanged = null;
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
    widget.timeline.devicePadding = devicePadding;

    return FabSubPage(
      child: Scaffold(
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
                  timeline: widget.timeline,
                  favorites: BlocProvider.favorites(context).favorites,
                  topOverlap: TopOverlap + devicePadding.top,
                  focusItem: widget.focusItem,
                  touchBubble: onTouchBubble,
                  touchEntry: onTouchEntry),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: devicePadding.top,
                    color: _headerBackgroundColor != null
                        ? _headerBackgroundColor
                        : Color.fromRGBO(238, 240, 242, 0.81),
                  ),
                  Container(
                    color: _headerBackgroundColor != null
                        ? _headerBackgroundColor
                        : Color.fromRGBO(238, 240, 242, 0.81),
                    height: 56.0,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        // IconButton(
                        //   padding: EdgeInsets.only(left: 20.0, right: 20.0),
                        //   color: _headerTextColor != null
                        //       ? _headerTextColor
                        //       : Colors.black.withOpacity(0.5),
                        //   alignment: Alignment.centerLeft,
                        //   icon: Icon(Icons.arrow_back),
                        //   onPressed: () {
                        //     widget.widget.timeline.isActive = false;
                        //     Get.back();
                        //     return; // TODO was returning true?
                        //   },
                        // ),
                        GestureDetector(
                          child: Transform.translate(
                            offset: const Offset(0.0, 0.0),
                            child: Container(
                              height: 60.0,
                              width: 60.0,
                              padding: EdgeInsets.all(18.0),
                              color: Colors.white.withOpacity(0.0),
                              child: FlareActor(
                                  "assets/tarikh/heart_toolbar.flr",
                                  animation: _showFavorites ? "On" : "Off",
                                  shouldClip: false,
                                  color: _headerTextColor != null
                                      ? _headerTextColor
                                      : darkText
                                          .withOpacity(darkText.opacity * 0.75),
                                  alignment: Alignment.centerLeft),
                            ),
                          ),
                          onTap: () {
                            widget.timeline.showFavorites =
                                !widget.timeline.showFavorites;
                            setState(() {
                              _showFavorites = widget.timeline.showFavorites;
                            });
                          },
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            _eraName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "RobotoMedium",
                              fontSize: 20.0,
                              color: _headerTextColor != null
                                  ? _headerTextColor
                                  : darkText
                                      .withOpacity(darkText.opacity * 0.75),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
