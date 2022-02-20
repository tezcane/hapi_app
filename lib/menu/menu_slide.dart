import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class MenuSlide extends StatefulWidget {
  final Widget foregroundPage; // where the app/navigation lives
  final Widget bottomWidget; // bottom row/horizontal menu bar
  final Widget? settingsWidget; // right column/verticle menu bar

  final double scaleWidth;
  final double scaleHeight;
  final Duration slideAnimationDuration;
  final Duration buttonAnimationDuration;
  final Curve openAnimationCurve;
  final Curve closeAnimationCurve;

  const MenuSlide({
    Key? key,
    required this.foregroundPage,
    required this.bottomWidget,
    this.settingsWidget,
    this.scaleWidth = 100,
    this.scaleHeight = 56,
    this.slideAnimationDuration = const Duration(milliseconds: 600),
    this.buttonAnimationDuration = const Duration(milliseconds: 650),
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
  })  : assert(scaleHeight >= 40),
        super(key: key);

  @override
  _MenuSlideState createState() => _MenuSlideState();
}

class _MenuSlideState extends State<MenuSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _acFabIcon;

  @override
  void initState() {
    _acFabIcon = AnimationController(
        vsync: this, duration: widget.buttonAnimationDuration);

    // Needed for fab button menu/close animation when menu_nav closes menu
    cMenu.initACFabIcon(_acFabIcon);

    super.initState();
  }

  @override
  void dispose() {
    _acFabIcon.dispose();
    super.dispose(); // must do this last!
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Show or hide the main menu',
        onPressed: null,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                iconSize: 30.0,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close, //cMenu.getFabAnimatedIcon(),
                  progress: _acFabIcon,
                ),
                onPressed: () => _handleOnPressed(),
              ),
            ],
          ),
        ),
      ),
      body: GetBuilder<MenuController>(
        builder: (c) {
          final double _width = MediaQuery.of(context).size.width;
          final double _height = MediaQuery.of(context).size.height;
          final double _fabPosition = 16;
          final double _fabSize = 56;

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
                        child: Visibility(
                            visible: cMenu.isMenuShowingSettings(),
                            child: widget.settingsWidget ?? Column()),
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

  void _handleOnPressed() {
    // if (cMenu.isFabBackMode()) {
    //   print('menu/fab is in back <- mode');
    //   if (cMenu.isMenuShowing()) {
    //     cMenu.hideMenu(); // TODO menu x here?
    //   } else {
    //     cMenu.handleBackButtonHit();
    //   }
    // } else {
    // menu open/close mode
    // print('menu open/close mode');
    if (cMenu.isMenuShowing()) {
      cMenu.hideMenu(); // just hit close on fab
    } else {
      cMenu.showMenu(); // just hit menu on fab
    }
    // }
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
      begin: Offset(0.0, 0.0),
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
