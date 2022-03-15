import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/nav_page_controller.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class MenuSlide extends StatefulWidget {
  const MenuSlide({
    Key? key,
    required this.navPage,
    required this.foregroundPage,
    required this.bottomWidget,
    required this.settingsWidgets,
    this.scaleWidth = 100,
    this.scaleHeight = 56,
    this.slideAnimationDuration = const Duration(milliseconds: 600),
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
  })  : assert(scaleHeight >= 40),
        super(key: key);

  final NavPage navPage;
  final Widget foregroundPage; // where the app/navigation lives
  final Widget bottomWidget; // bottom row/horizontal menu bar
  final List<Widget?> settingsWidgets; // right column/vertical menu bar

  final double scaleWidth;
  final double scaleHeight;
  final Duration slideAnimationDuration;
  final Curve openAnimationCurve;
  final Curve closeAnimationCurve;

  @override
  _MenuSlideState createState() => _MenuSlideState();
}

class _MenuSlideState extends State<MenuSlide>
    with SingleTickerProviderStateMixin {
  final MenuController cMenu = MenuController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<MenuController>(
        builder: (c) {
          final double _width = MediaQuery.of(context).size.width;
          final double _height = MediaQuery.of(context).size.height;
          const double _fabPosition = 16;
          const double _fabSize = 56;

          final double _xScale =
              (widget.scaleWidth + _fabPosition * 2) * 100 / _width;
          final double _yScale =
              (widget.scaleHeight + _fabPosition * 2) * 100 / _height;

          return Stack(
            children: <Widget>[
              Container(
                color: AppThemes.logoBackground,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      bottom: _fabSize + _fabPosition * 4,
                      right: _fabPosition,
                      // width is used as max width to prevent overlap
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: widget.scaleWidth,
                          maxWidth: widget.scaleWidth,
                        ),
                        child: GetBuilder<NavPageController>(builder: (c) {
                          return Visibility(
                            visible: cMenu.isMenuShowingSettings(),
                            child: widget.settingsWidgets[
                                    c.getLastIdx(widget.navPage)] ??
                                Column(),
                          );
                        }),
                      ),
                    ),
                    Positioned(
                      //right: widget.scaleWidth + _fabPosition * 2,
                      //bottom: _fabPosition * 1.5,
                      bottom: 0, //_fabPosition * 1.5,
                      // height is used as max height to prevent overlap
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          //maxHeight: widget.scaleHeight - _fabPosition,
                          minHeight: widget.scaleHeight + 35,
                          maxHeight: widget.scaleHeight + 35, // TODO tune
                        ),
                        child: widget.bottomWidget,
                      ),
                    ),
                  ],
                ),
              ),
              SlideAnimation(
                opened: c.isMenuShowing(),
                xScale: _xScale,
                yScale: _yScale,
                duration: widget.slideAnimationDuration,
                child: widget.foregroundPage,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// [opened] is a flag for forwarding or reversing the animation.
/// you can change the animation curves as you like, but you might need to
/// pay a close attention to [xScale] and [yScale], as they're setting
/// the end values of the animation tween.
class SlideAnimation extends StatefulWidget {
  final Widget child;
  final bool opened;
  final double xScale;
  final double yScale;
  final Duration duration;

  final Curve openAnimationCurve;
  final Curve closeAnimationCurve;

  const SlideAnimation({
    Key? key,
    required this.child,
    required this.opened,
    required this.xScale,
    required this.yScale,
    required this.duration,
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
  }) : super(key: key);

  @override
  _SlideState createState() => _SlideState();
}

class _SlideState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> offset;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    offset = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: Offset(-widget.xScale * 0.01, -widget.yScale * 0.01),
    ).animate(
      CurvedAnimation(
        curve: Interval(0, 1, curve: widget.openAnimationCurve),
        reverseCurve: Interval(0, 1, curve: widget.closeAnimationCurve),
        parent: _animationController,
      ),
    );

    super.initState();
  }

  /// This is needed to move/slide the foregroundPage up/down
  @override
  void didUpdateWidget(SlideAnimation oldWidget) {
    widget.opened
        ? _animationController.forward()
        : _animationController.reverse();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: offset, child: widget.child);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
