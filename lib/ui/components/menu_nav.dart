import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/menu_controller.dart';

/// Signature for creating widget with `showMenu` callback to open/close Side Menu.
typedef SideMenuAnimationBuilder = Widget Function(VoidCallback showMenu);

/// Enables swipe from left to right to display the menu, it's `false` by default.
const bool _enableEdgeDragGesture = true;

/// If `enableEdgeDragGesture` true, `edgeDragWidth` is the swipe detection width area.
const _kEdgeDragWidth = 20.0;

/// Menu width for the Side Menu.
const double _kSideMenuWidth = 88.0;

/// Menu animation total duration time, each item has total_duration/items.length
const Duration _kDuration = Duration(milliseconds: 800);

/// [Curve] used for the animation
const Curve _kCurveAnimation = Curves.linear;

const Color _kButtonColorSelected = Color(0xFFFF595E); // TODO theme
const Color _kButtonColorUnselected = Color(0xFF1F2041);

/// The [MenuNav] controls the items from the lateral menu.
class MenuNav extends StatefulWidget {
  const MenuNav({
    Key? key,
    required this.builder,
    required this.selectedIndexAtInit,
    required this.items,
    required this.onItemSelected,
  }) : super(key: key);

  /// `builder` builds a view/page based on the `selectedIndex`.
  /// It also comes with a `showMenu` callback for opening the Side Menu.
  final SideMenuAnimationBuilder builder;

  /// Initial index selected, if nothing to select pass size/count of items[].
  final int selectedIndexAtInit;

  /// List of items that we want to display on the Side Menu.
  final List<Widget> items;

  /// Function where we receive the current index selected.
  final ValueChanged<int> onItemSelected;

  @override
  _MenuNavState createState() => _MenuNavState();
}

class _MenuNavState extends State<MenuNav> with SingleTickerProviderStateMixin {
  final MenuController c = Get.find();
  late AnimationController _animationController;

  late int _selectedIndex;

  @override
  void initState() {
    _selectedIndex = widget.selectedIndexAtInit;

    _animationController = AnimationController(
      vsync: this,
      duration: _kDuration,
    );
    _animationController.forward(from: 1.0);

    super.initState();
  }

  // @override
  // void didUpdateWidget(MenuNav oldWidget) {
  //   c.isMenuShowing()
  //       ? _animationController.forward()
  //       : _animationController.reverse();
  //
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _displayMenuDragGesture(DragEndDetails endDetails) {
    if (!c.isMenuShowing()) {
      final velocity = endDetails.primaryVelocity!;
      if (velocity < 0) {
        _animationController.reverse();
        c.showMenu();
      }
    }
  }

  void _animationReverse() {
    c.isMenuShowing()
        ? _animationController.reverse()
        : _animationController.forward();
  }

  void _closeMenu() {
    _animationController.forward(from: 0.0);
    c.hideMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          print('constraints.maxHeight=${constraints.maxHeight}');

          int sm = 0; // screen multiplier
          if (constraints.maxHeight > 805) {
            sm = 4;
          } else if (constraints.maxHeight > 705) {
            sm = 3;
          } else if (constraints.maxHeight > 605) {
            sm = 2;
          } else if (constraints.maxHeight > 505) {
            sm = 1;
          }
          print('sm=$sm');
          // was: constraints.maxHeight / widget.items.length;
          // 88 = 16 + 56 + 16 (fabSize and it's padding)
          // +/*  sm since as spacers for big/small screens:
          final itemSize = // TODO don't +/* 2 in portrait mode
              (constraints.maxHeight - 88) / (widget.items.length + sm);
          return Stack(
            children: [
              widget.builder(_animationReverse),
              Padding(
                // TODO use empty size boxes so we can dismiss on anypart of foregroundWiget
                // top centers nav buttons, bottom allows tapping verticle bar
                padding: EdgeInsets.only(top: itemSize * sm, bottom: 88),
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) => Stack(
                    children: [
                      /// dismiss the Menu when user taps outside the widget.
                      if (_animationController.value < 1 &&
                          c.isMenuShowing() &&
                          c.isMenuShowingNav())
                        Align(
                          child: GestureDetector(
                            onTap: () {
                              _closeMenu();
                            },
                            onLongPress: () {
                              _closeMenu();
                            },
                          ),
                        ),

                      /// handle drag out of menu from right side of screen
                      if (_enableEdgeDragGesture &&
                          _animationController.isCompleted)
                        //!c.isMenuShowing()) // hasn't been flagged yet
                        Align(
                          alignment: Alignment.bottomRight, // was centerRight
                          child: GestureDetector(
                            onHorizontalDragEnd: _displayMenuDragGesture,
                            behavior: HitTestBehavior.translucent,
                            excludeFromSemantics: true,
                            child: Container(width: _kEdgeDragWidth),
                          ),
                        ),

                      /// Show Menu:
                      for (int i = 0; i < widget.items.length; i++)
                        MenuItem(
                          index: i,
                          length: widget.items.length,
                          width: _kSideMenuWidth,
                          height: itemSize,
                          controller: _animationController,
                          curve: _kCurveAnimation,
                          color: (i == _selectedIndex)
                              ? _kButtonColorSelected
                              : _kButtonColorUnselected,
                          onTap: () {
                            if (i == _selectedIndex) {
                              c.hideMenuNav(); // TODO show settings!
                            } else {
                              c.hideMenu(); // selected new nav page
                              setState(() {
                                _selectedIndex = i;
                              });
                            }
                            widget.onItemSelected(i); // notify HomeUI.
                          },
                          child: widget.items[i],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// A [MenuItem]/A button for the [MenuNav]
class MenuItem extends StatelessWidget {
  const MenuItem({
    Key? key,
    required this.index,
    required this.length,
    required this.width,
    required this.height,
    required this.controller,
    required this.curve,
    required this.color,
    required this.onTap,
    required this.child,
  }) : super(key: key);

  /// `index` for the [MenuItem]
  final int index;

  /// Number of items
  final int length;

  /// `width` for the [MenuItem]
  final double width;

  /// `height` for the [MenuItem]
  final double height;

  /// [AnimationController] used in the [MenuNav]
  final AnimationController controller;

  /// Animation [Curve]
  final Curve curve;

  /// Background `color`
  final Color color;

  /// Callback invoked `onTap`
  final VoidCallback onTap;

  /// widget `child`
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final _intervalGap = 1 / length;
    final _index = controller.status == AnimationStatus.forward
        ? length - 1 - index
        : index;
    final _animation = Tween(begin: 0.0, end: 1.6).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          _intervalGap * _index,
          _intervalGap * (_index + 1),
          curve: curve,
        ),
      ),
    );

    return Positioned(
      left: null,
      right: 0,
      top: height * index,
      width: width,
      height: height,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(-_animation.value),
        alignment: Alignment.bottomRight, // was topRight
        child: Material(
          color: color,
          child: InkWell(
            onTap: () {
              controller.forward(from: 0.0);
              onTap();
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
