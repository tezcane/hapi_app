import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/onboard/onboard_ui.dart';

/// Signature for creating widget to open/close Side Menu.
typedef SideMenuAnimationBuilder = Widget Function();

/// Enables swipe from left to right to display the menu, it's `false` by default.
const bool _enableEdgeDragGesture = true;

/// If `enableEdgeDragGesture` true, `edgeDragWidth` is the swipe detection width area.
const _kEdgeDragWidth = 20.0;

/// Menu width for the Side Menu.
const double kSideMenuWidth = 132.0;

/// [Curve] used for the animation
const Curve _kCurveAnimation = Curves.linear;

const Color _kButtonColorSelected = AppThemes.selected;
const Color _kButtonColorUnselected = Color(0xFF1D1E33);

/// The [MenuRight] controls the items from the lateral menu.
class MenuRight extends StatefulWidget {
  const MenuRight({
    required this.initNavPage,
    required this.settingsWidgets,
    required this.builder,
    required this.items,
  });

  /// NavPage to know what is selected in nav menu.
  final NavPage initNavPage;

  /// Settings columns, if null, no settings will be displayed.  If populated
  /// when  user clicks the nav icon, all nav icons animate/fold away and reveal
  /// the settings panel held in this list.
  final List<Widget?> settingsWidgets;

  /// `builder` builds a view/page based on the `selectedIndex`.
  final SideMenuAnimationBuilder builder;

  /// List of items that we want to display on the Side Menu.
  final List<Widget> items;

  @override
  _MenuRightState createState() => _MenuRightState();
}

class _MenuRightState extends State<MenuRight> {
  void _displayMenuDragGesture(DragEndDetails endDetails) {
    if (!MenuC.to.isMenuShowing) {
      MainC.to.showMainMenuFab();
      final velocity = endDetails.primaryVelocity!;
      if (velocity < 0) {
        MenuC.to.showMenu();
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
                // TODO use empty size boxes so we can dismiss on any part of foregroundWidget
                // top centers nav buttons, bottom allows tapping verticle bar
                padding: EdgeInsets.only(top: itemSize * sm, bottom: 88),
                child: AnimatedBuilder(
                  animation: MenuC.to.acNavMenu,
                  builder: (context, child) => Stack(
                    children: [
                      /// dismiss the Menu when user taps outside the widget.
                      if (MenuC.to.acNavMenu.value < 1 &&
                          MenuC.to.isMenuShowing &&
                          MenuC.to.isMenuShowingNav)
                        Align(
                          child: GestureDetector(
                            onTap: () => MenuC.to.hideMenu(),
                            onLongPress: () => MenuC.to.hideMenu(),
                          ),
                        ),

                      /// handle drag out of menu from right side of screen
                      if (_enableEdgeDragGesture &&
                          MenuC.to.acNavMenu.isCompleted)
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
                      for (NPV npv in MainC.to.isSignedIn
                          ? navPageValuesSignedIn
                          : navPageValuesSignedOut)
                        GetBuilder<NavPageC>(
                          builder: (c) {
                            return MenuItem(
                              index: npv.navPage.index,
                              length: NavPage.values.length,
                              width: kSideMenuWidth,
                              height: itemSize,
                              acNavMenu: MenuC.to.acNavMenu,
                              curve: _kCurveAnimation,
                              color: (npv.navPage == widget.initNavPage)
                                  ? _kButtonColorSelected
                                  : _kButtonColorUnselected,
                              onTap: () => handleNavPageTapped(npv, c),
                              child: widget.items[npv.navPage.index],
                            );
                          },
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

  handleNavPageTapped(NPV npv, NavPageC c) {
    if (npv.navPage == widget.initNavPage &&
        widget.settingsWidgets[c.getLastIdx(npv.navPage)] != null) {
      // same page selected and it has settings
      MenuC.to.hideMenuNav();

      if (widget.initNavPage == NavPage.Mithal) {
        OnboardUI.menuViewedSettingsTab = true;
        c.updateOnThread1Ms();
      }
    } else if (npv.navPage == widget.initNavPage) {
      // same page selected, just dispose the whole menu
      MenuC.to.hideMenu();
    } else {
      // selected new nav page
      if (widget.initNavPage == NavPage.Mithal) {
        // if we are in Onboard/Example/Tutorial mode
        OnboardUI.menuUsedToSwitchFeatures = true;
        c.updateOnThread1Ms();
      } else {
        // If in normal mode, navigate to the new NavPage
        MenuC.to.navigateToNavPageResetFAB(npv.navPage);
      }
    }
  }
}

/// A [MenuItem]/A button for the [MenuRight]
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

  /// [AnimationController] used in the [MenuRight]
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
