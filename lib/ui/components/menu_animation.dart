import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/menu_controller.dart';

/// Signature for creating a widget with a `showMenu` callback
/// for opening the Side Menu.
///
/// See also:
/// * [SideMenuAnimation.builder]
/// * [SideMenuAnimationAppBarBuilder]
typedef SideMenuAnimationBuilder = Widget Function(VoidCallback showMenu);

const _sideMenuWidth = 88.0;
const _sideMenuDuration = Duration(milliseconds: 800);
const _kEdgeDragWidth = 20.0;

/// The [MenuAnimation] controls the items from the lateral menu
/// and also can control the circular reveal transition.
class MenuAnimation extends StatefulWidget {
  /// Creates a [MenuAnimation] without Circular Reveal animation.
  /// Also it is responsible for updating/changing the [AppBar]
  /// based on the index we receive.
  const MenuAnimation.builder({
    Key? key,
    required this.builder,
    required this.items,
    required this.onItemSelected,
    double? menuWidth,
    Duration? duration,
    double? edgeDragWidth,
    this.enableEdgeDragGesture = false,
    this.curveAnimation = Curves.linear,
  })  : indexSelected = null,
        menuWidth = menuWidth ?? _sideMenuWidth,
        duration = duration ?? _sideMenuDuration,
        edgeDragWidth = edgeDragWidth ?? _kEdgeDragWidth,
        super(key: key);

  /// Creates a [MenuAnimation] with Circular Reveal animation.
  /// Also it is responsible for updating/changing the [AppBar]
  /// based on the index we receive.
  const MenuAnimation({
    Key? key,
    required this.builder,
    required this.items,
    required this.onItemSelected,
    double? menuWidth,
    Duration? duration,
    this.indexSelected = 0,
    double? edgeDragWidth,
    this.enableEdgeDragGesture = false,
    this.curveAnimation = Curves.linear,
  })  : menuWidth = menuWidth ?? _sideMenuWidth,
        duration = duration ?? _sideMenuDuration,
        edgeDragWidth = edgeDragWidth ?? _kEdgeDragWidth,
        super(key: key);

  /// `builder` builds a view/page based on the `selectedIndex.
  /// It also comes with a `showMenu` callback for opening the Side Menu.
  final SideMenuAnimationBuilder builder;

  /// List of items that we want to display on the Side Menu.
  final List<Widget> items;

  /// Function where we receive the current index selected.
  final ValueChanged<int> onItemSelected;

  /// Menu width for the Side Menu.
  final double menuWidth;

  /// Duration for the animation when the menu appears, this is
  /// the total duration, each item has total_duration/items.lenght
  final Duration duration;

  /// Initial index selected
  final int? indexSelected;

  /// Enables swipe from left to right to display the menu,
  /// it's `false` by default.
  final bool enableEdgeDragGesture;

  /// If `enableEdgeDragGesture` is true, then we can change
  /// the `edgeDragWidth`, this is the width of the area where we do swipe.
  final double edgeDragWidth;

  /// [Curve] used for the animation
  final Curve curveAnimation;

  @override
  _MenuAnimationState createState() => _MenuAnimationState();
}

class _MenuAnimationState extends State<MenuAnimation>
    with SingleTickerProviderStateMixin {
  final MenuController c = Get.find();

  late AnimationController _animationController;

  late int _selectedIndex;

  bool menuShownAlready = false;

  @override
  void initState() {
    // select home by default:
    _selectedIndex = widget.indexSelected ?? widget.items.length - 2;
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animationController.forward(from: 1.0);
    super.initState();
  }

  @override //TODO asdf needed?
  void didUpdateWidget(MenuAnimation oldWidget) {
    print("didUpdateWidget didUpdateWidget didUpdateWidget asddfffffffffff");
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _animationController.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    // TODO asdf
    print("dispose dispose dispose asddfffffffffff");
    _animationController.dispose();
    super.dispose();
  }

  void _displayMenuDragGesture(DragEndDetails endDetails) {
    c.handleOnPressed();
    print(// TODO asdf
        "_displayMenuDragGesture _displayMenuDragGesture _displayMenuDragGesture asddfffffffffff");
    final velocity = endDetails.primaryVelocity!;
    if (velocity < 0) _animationReverse();
  }

  void _animationReverse() {
    this.menuShownAlready = true;
    print(// TODO asdf
        "_animationReverse _animationReverse _animationReverse asddfffffffffff");
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // final itemSize = constraints.maxHeight / widget.items.length;
          // 88 = 16 + 56 + 16 (fabSize and it's padding)
          // - 1 since last index (close button) is deleted:
          final itemSize =
              (constraints.maxHeight - 88) / (widget.items.length - 1);
          return Stack(
            children: [
              widget.builder(_animationReverse),
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => Stack(
                  children: [
                    /// Enables to dismiss the [MenuAnimation] when user taps outside
                    /// the widget.
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
                    // handle drag out of menu from right side of screen
                    if (widget.enableEdgeDragGesture &&
                        _animationController.isCompleted &&
                        !menuShownAlready)
                      Align(
                        alignment: Alignment.bottomRight, // was centerRight
                        child: GestureDetector(
                          onHorizontalDragEnd: _displayMenuDragGesture,
                          behavior: HitTestBehavior.translucent,
                          excludeFromSemantics: true,
                          child: Container(width: widget.edgeDragWidth),
                        ),
                      ),
                    // -1 hide the close button, use fab to close:
                    for (int i = 0; i < widget.items.length - 1; i++)
                      MenuItem(
                        index: i,
                        length: widget.items.length,
                        width: widget.menuWidth,
                        height: itemSize,
                        controller: _animationController,
                        curve: widget.curveAnimation,
                        color: (i == _selectedIndex)
                            ? Color(0xFFFF595E) // TODO theme
                            : Color(0xFF1F2041),
                        onTap: () {
                          if (i != _selectedIndex) {
                            if (i != widget.items.length - 1) {
                              setState(() {
                                //_oldSelectedIndex = _selectedIndex;
                                // _selectedIndex = i - 1;
                                _selectedIndex = i;
                              });
                            }
                            widget.onItemSelected(i); // TODO asdf needed?
                          }
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

/// {@template MenuItem}
/// A [MenuItem] for the [MenuAnimation]
/// {@endtemplate}
class MenuItem extends StatelessWidget {
  /// {@macro MenuItem}
  const MenuItem({
    Key? key,
    required this.index,
    required this.length,
    required this.width,
    required this.height,
    required this.curve,
    required this.controller,
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

  /// [AnimationController] used in the [MenuAnimation]
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
