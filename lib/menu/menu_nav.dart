import 'package:flutter/material.dart';
import 'package:hapi/menu/menu_controller.dart';

/// Menu animation total duration time, each item has total_duration/items.length
const Duration navMenuShowHideMs = Duration(milliseconds: 600);

/// Signature for creating widget to open/close Side Menu.
typedef SideMenuAnimationBuilder = Widget Function();

/// Enables swipe from left to right to display the menu, it's `false` by default.
const bool _enableEdgeDragGesture = true;

/// If `enableEdgeDragGesture` true, `edgeDragWidth` is the swipe detection width area.
const _kEdgeDragWidth = 20.0;

/// Menu width for the Side Menu.
const double _kSideMenuWidth = 132.0;

/// [Curve] used for the animation
const Curve _kCurveAnimation = Curves.linear;

const Color _kButtonColorSelected = Color(0xFFFF595E); // TODO theme
const Color _kButtonColorUnselected = Color(0xFF1F2041);

/// The [MenuNav] controls the items from the lateral menu.
class MenuNav extends StatefulWidget {
  const MenuNav({
    Key? key,
    required this.builder,
    required this.initNavPage,
    required this.items,
  }) : super(key: key);

  /// `builder` builds a view/page based on the `selectedIndex`.
  final SideMenuAnimationBuilder builder;

  /// NavPage to know what is selected in nav menu.
  final NavPage initNavPage;

  /// List of items that we want to display on the Side Menu.
  final List<Widget> items;

  @override
  _MenuNavState createState() => _MenuNavState();
}

class _MenuNavState extends State<MenuNav> with SingleTickerProviderStateMixin {
  late AnimationController _acNavMenu;

  @override
  void initState() {
    _acNavMenu = AnimationController(
      vsync: this,
      duration: navMenuShowHideMs,
    );
    cMenu.initACNavMenu(_acNavMenu);
    _acNavMenu.forward(from: 1.0); // needed to hide at init

    super.initState();
  }

  @override
  void dispose() {
    _acNavMenu.dispose();
    super.dispose();
  }

  void _displayMenuDragGesture(DragEndDetails endDetails) {
    if (!cMenu.isMenuShowing()) {
      final velocity = endDetails.primaryVelocity!;
      if (velocity < 0) {
        cMenu.showMenu();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          //print('constraints.maxHeight=${constraints.maxHeight}');

          int sm = 0; // screen multiplier
          if (constraints.maxHeight > 805) {
            sm = 1;
          }
          // else if (constraints.maxHeight > 705) {
          //   sm = 0;
          // } else if (constraints.maxHeight > 605) {
          //   sm = 0;
          // } else if (constraints.maxHeight > 505) {
          //   sm = 0;
          // }
          // print('sm=$sm');
          // was: constraints.maxHeight / widget.items.length;
          // 88 = 16 + 56 + 16 (fabSize and it's padding)
          // +/*  sm since as spacers for big/small screens:
          final itemSize = // TODO don't +/* 2 in portrait mode
              (constraints.maxHeight - 88) / (widget.items.length + sm);
          return Stack(
            children: [
              widget.builder(), // need to embed menu_nav and menu together
              Padding(
                // TODO use empty size boxes so we can dismiss on anypart of foregroundWiget
                // top centers nav buttons, bottom allows tapping verticle bar
                padding: EdgeInsets.only(top: itemSize * sm, bottom: 88),
                child: AnimatedBuilder(
                  animation: _acNavMenu,
                  builder: (context, child) => Stack(
                    children: [
                      /// dismiss the Menu when user taps outside the widget.
                      if (_acNavMenu.value < 1 &&
                          cMenu.isMenuShowing() &&
                          cMenu.isMenuShowingNav())
                        Align(
                          child: GestureDetector(
                            onTap: () => cMenu.hideMenu(),
                            onLongPress: () => cMenu.hideMenu(),
                          ),
                        ),

                      /// handle drag out of menu from right side of screen
                      if (_enableEdgeDragGesture && _acNavMenu.isCompleted)
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
                      for (NavPage navPage in NavPage.values)
                        MenuItem(
                          index: navPage.index,
                          length: NavPage.values.length,
                          width: _kSideMenuWidth,
                          height: itemSize,
                          acNavMenu: _acNavMenu,
                          curve: _kCurveAnimation,
                          color: (navPage == widget.initNavPage)
                              ? _kButtonColorSelected
                              : _kButtonColorUnselected,
                          onTap: () {
                            if (navPage == widget.initNavPage &&
                                cMenu.getShowNavSettings()) {
                              cMenu.hideMenuNav(); // shows settings
                            } else if (navPage == widget.initNavPage) {
                              cMenu.hideMenu(); // same page selected
                            } else {
                              // selected new nav page
                              cMenu.hideMenu();
                              cMenu.navigateToNavPage(navPage);
                            }
                          },
                          child: widget.items[navPage.index],
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
    required this.acNavMenu,
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
  final AnimationController acNavMenu;

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
    final _index = acNavMenu.status == AnimationStatus.forward
        ? length - 1 - index
        : index;
    final _animation = Tween(begin: 0.0, end: 1.6).animate(
      CurvedAnimation(
        parent: acNavMenu,
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
              onTap();
            },
            child: child,
          ),
        ),
      ),
    );
  }
}
