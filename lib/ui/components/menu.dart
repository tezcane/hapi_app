import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/controllers/menu_controller.dart';

class Menu extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget foregroundPage;
  final Widget columnWidget;
  final Widget bottomWidget;

  final IconData buttonIcon;
  final double scaleWidth;
  final double scaleHeight;
  final Duration slideAnimationDuration;
  final Duration buttonAnimationDuration;
  final Curve openAnimationCurve;
  final Curve closeAnimationCurve;

  const Menu({
    Key? key,
    required this.onPressed,
    required this.foregroundPage,
    required this.columnWidget,
    required this.bottomWidget,
    this.buttonIcon = Icons.add,
    this.scaleWidth = 56,
    this.scaleHeight = 56, // * Globals.PHI,
    this.slideAnimationDuration = const Duration(milliseconds: 800),
    this.buttonAnimationDuration = const Duration(milliseconds: 240),
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
  })  : assert(scaleHeight >= 40),
        super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  final MenuController c = Get.find();
  AnimationController? _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));

    // Do this so we can change fab button menu/close animation when
    // menu_nav updates this
    c.initMenuButtonAnimatedController(_animationController!);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (_animationController != null) {
      _animationController!.dispose();
    }
  }

  void _handleOnPressed() {
    // shows animated icons only if menu is not open. For case when same menu
    // was hit twice to show settings, so next time fab is hit, it closes menu.
    if (!c.isOpen()) {
      widget.onPressed.call(); // TODO move to controller
    }

    c.handleOnPressed(); // toggle open/closed menu state
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    final double _fabPosition = 16;
    final double _fabSize = 56;

    final double _xScale =
        (widget.scaleWidth + _fabPosition * 2) * 100 / _width;
    final double _yScale =
        (widget.scaleHeight + _fabPosition * 2) * 100 / _height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                // iconSize: 50,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _animationController!,
                ),
                onPressed: () => _handleOnPressed(),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
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
                    constraints: BoxConstraints(maxWidth: widget.scaleWidth),
                    child: widget.columnWidget,
                  ),
                ),
                Positioned(
                  right: widget.scaleWidth + _fabPosition * 2,
                  bottom: _fabPosition * 1.5,
                  // height is used as max height to prevent overlap
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.scaleHeight - _fabPosition,
                    ),
                    child: widget.bottomWidget,
                  ),
                ),
              ],
            ),
          ),
          GetBuilder<MenuController>(
            builder: (c) {
              return SlideAnimation(
                opened: c.isOpen(),
                xScale: _xScale,
                yScale: _yScale,
                duration: widget.slideAnimationDuration,
                child: widget.foregroundPage,
              );
            },
          ),
        ],
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
  final MenuController c = Get.find();
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
