import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';

class MenuBottom extends StatefulWidget {
  const MenuBottom({
    required this.navPage,
    required this.foregroundPage,
    required this.bottomWidget,
    required this.settingsWidgets,
    this.scaleWidth = 100,
    this.scaleHeight = 56,
    this.slideAnimationDuration = const Duration(milliseconds: 600),
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
  }) : assert(scaleHeight >= 40);

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
  _MenuBottomState createState() => _MenuBottomState();
}

class _MenuBottomState extends State<MenuBottom>
    with SingleTickerProviderStateMixin {
  final MenuC cMenu = MenuC.to;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuC>(
      builder: (c) {
        final double width = MediaQuery.of(context).size.width;
        final double height = MediaQuery.of(context).size.height;
        const double fabPosition = 16;
        const double fabSize = 56;

        final double xScale =
            (widget.scaleWidth + fabPosition * 2) * 100 / width;
        final double yScale =
            (widget.scaleHeight + fabPosition * 2) * 100 / height;

        return Stack(
          children: <Widget>[
            Container(
              color: AppThemes.logoBackground,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    bottom: fabSize + fabPosition * 4,
                    right: fabPosition,
                    // width is used as max width to prevent overlap
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: widget.scaleWidth,
                        maxWidth: widget.scaleWidth,
                      ),
                      child: GetBuilder<NavPageC>(builder: (c) {
                        return Visibility(
                          visible: cMenu.isMenuShowingSettings,
                          child: widget.settingsWidgets[
                                  c.getLastIdx(widget.navPage)] ??
                              const SizedBox(),
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
              opened: c.isMenuShowing,
              xScale: xScale,
              yScale: yScale,
              duration: widget.slideAnimationDuration,
              child: widget.foregroundPage,
            ),
          ],
        );
      },
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
  Widget build(BuildContext context) =>
      SlideTransition(position: offset, child: widget.child);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
