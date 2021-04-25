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
  bool menuShownAlready = false; // TODO bugs here

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _displayMenuDragGesture(DragEndDetails endDetails) {
    print("_displayMenuDragGesture called");
    c.handleOnPressed();

    final velocity = endDetails.primaryVelocity!;
    if (velocity < 0) _animationReverse();
  }

  void _animationReverse() {
    print("_animationReverse called");

    this.menuShownAlready = true;
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // was: constraints.maxHeight / widget.items.length;
          // 88 = 16 + 56 + 16 (fabSize and it's padding)
          // - 1 since last index (close button) is hidden for fab control:
          final itemSize =
              (constraints.maxHeight - 88) / (widget.items.length - 1);
          return Stack(
            children: [
              widget.builder(_animationReverse),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => Stack(
                  children: [
                    /// dismiss the Menu when user taps outside the widget.
                    if (_animationController.value < 1)
                      Align(
                        child: GestureDetector(
                          onTap: () {
                            _animationController.forward(from: 0.0);
                            menuShownAlready = false;
                            c.handleOnPressed();
                          },
                        ),
                      ),

                    /// handle drag out of menu from right side of screen
                    if (_enableEdgeDragGesture &&
                        _animationController.isCompleted &&
                        !menuShownAlready)
                      Align(
                        alignment: Alignment.bottomRight, // was centerRight
                        child: GestureDetector(
                          onHorizontalDragEnd: _displayMenuDragGesture,
                          behavior: HitTestBehavior.translucent,
                          excludeFromSemantics: true,
                          child: Container(width: _kEdgeDragWidth),
                        ),
                      ),

                    /// Show Menu, -1 hide the close button, use fab to close:
                    for (int i = 0; i < widget.items.length - 1; i++)
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
                          if (i != _selectedIndex) {
                            if (i != widget.items.length - 1) {
                              setState(() {
                                _selectedIndex = i;
                              });
                            }
                            c.handleOnPressed(); // hide menu
                          }
                          widget.onItemSelected(i);
                        },
                        child: widget.items[i],
                      ),
                  ],
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
