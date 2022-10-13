library bottom_bar;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/helper/keep_alive_page.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';

/// Display a bar with multiple icons and titles to hold different UIs
class BottomBar extends StatelessWidget {
  const BottomBar({
    required this.selectedIndex,
    required this.items,
    required this.tabHeight,
    required this.onTap,
    this.backgroundColor,
    this.showActiveBackgroundColor = false,
    this.curve = Curves.easeOutQuint,
    this.duration = const Duration(milliseconds: 750),
  });
  final int selectedIndex;
  final List<BottomBarItem> items;
  final double tabHeight;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final bool showActiveBackgroundColor;
  final Curve curve;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final int itemCount = items.length;
    final double tabWidth = (w(context) - 90) / itemCount; // -80 FAB, -10 pad

    return Container(
      height: tabHeight,
      color: backgroundColor,
      // LangC needed for tab switch on Onboard Example page lang switch
      child: GetBuilder<LangC>(
        builder: (lc) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: LangC.to.isLTR ? 10 : 80),
            ...List<Widget>.generate(
              itemCount,
              (int index) => _BottomBarItemWidget(
                itemCount: itemCount,
                bottomBarItem: items.elementAt(index),
                tabWidth: tabWidth,
                tabHeight: tabHeight,
                index: index,
                isSelected: index == selectedIndex,
                onTap: () => onTap(index),
                showActiveBackgroundColor: showActiveBackgroundColor,
                curve: curve,
                duration: duration,
              ),
            ),
            SizedBox(width: LangC.to.isLTR ? 80 : 10),
          ],
        ),
      ),
    );
  }
}

class _BottomBarItemWidget extends StatelessWidget {
  const _BottomBarItemWidget({
    required this.itemCount,
    required this.bottomBarItem,
    required this.tabWidth,
    required this.tabHeight,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.showActiveBackgroundColor,
    required this.curve,
    required this.duration,
    this.useHapiLogoFont = true,
  });
  final int itemCount;
  final BottomBarItem bottomBarItem;
  final double tabWidth;
  final double tabHeight;
  final int index;
  final bool isSelected;
  final Function() onTap; // callback to update `selectedIndex`
  final bool showActiveBackgroundColor;
  final Curve curve;
  final Duration duration;
  final bool useHapiLogoFont;

  @override
  Widget build(BuildContext context) {
    final _inactiveColor = Theme.of(context).brightness == Brightness.light
        ? const Color(0xFF404040)
        : const Color(0xF2FFFFFF);

    final TextStyle textStyle = useHapiLogoFont
        ? const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Lobster')
        : tsB;

    double iconSize = isSelected ? 45 : 35;
    double textHeight = tabHeight - iconSize - 4; // - 4 for some padding

    Color selectedColor = bottomBarItem.selectedColor;
    Color selectedColorWithOpacity = selectedColor.withOpacity(0.1);

    return SizedBox(
      width: tabWidth,
      height: tabHeight,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: isSelected ? 1 : 0),
        curve: curve,
        duration: duration,
        builder: (BuildContext context, double value, Widget? child) {
          return Material(
            color: showActiveBackgroundColor
                ? Color.lerp(
                    selectedColor.withOpacity(0),
                    selectedColorWithOpacity,
                    value,
                  )
                : Colors.transparent,
            shape: const RoundedRectangleBorder(),
            child: Tooltip(
              message: a(bottomBarItem.tkTooltip),
              child: InkWell(
                onTap: onTap,
                customBorder: const StadiumBorder(),
                highlightColor: selectedColorWithOpacity,
                focusColor: selectedColorWithOpacity,
                splashColor: selectedColorWithOpacity,
                hoverColor: selectedColorWithOpacity,
                child: Hero(
                  tag: bottomBarItem.iconData,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          color: Color.lerp(
                            _inactiveColor,
                            selectedColor,
                            value,
                          ),
                          size: iconSize,
                        ),
                        child: bottomBarItem.iconData ==
                                Icons.brightness_3_outlined
                            ? Transform.rotate(
                                angle: 2.8, // Rotates crescent
                                child: Icon(
                                  bottomBarItem.iconData,
                                  size: iconSize,
                                ),
                              )
                            : Icon(bottomBarItem.iconData, size: iconSize),
                      ),
                      if (isSelected)
                        DefaultTextStyle(
                          style: textStyle.copyWith(
                            color: Color.lerp(
                              Colors.transparent,
                              selectedColor,
                              value,
                            ),
                          ),
                          child: T(
                            bottomBarItem.tkTitle,
                            textStyle,
                            w: tabWidth,
                            h: textHeight,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class BottomBarItem {
  const BottomBarItem(
    this.mainWidget,
    this.settingsWidget,
    this.tkTitle,
    this.tkTooltip,
    this.iconData, {
    this.selectedColor = AppThemes.selected,
    this.onPressed,
  });
  final Widget mainWidget;
  final Widget? settingsWidget;
  final String tkTitle;
  final String tkTooltip;
  final IconData iconData;
  final Color selectedColor;
  final VoidCallback? onPressed;

  /// Keeps widget alive on UI, so when swiped doesn't lose settings
  Widget get aliveMainWidget => KeepAlivePage(child: mainWidget);
}
