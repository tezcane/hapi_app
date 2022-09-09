library bottom_bar;

import 'package:flutter/material.dart';
import 'package:hapi/helper/keep_alive_page.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';

/// Display a bar with multiple icons and titles to hold different UIs
class BottomBar extends StatelessWidget {
  const BottomBar({
    required this.selectedIndex,
    required this.items,
    required this.height,
    required this.onTap,
    this.backgroundColor,
    this.showActiveBackgroundColor = false,
    this.curve = Curves.easeOutQuint,
    this.duration = const Duration(milliseconds: 750),
  });
  final int selectedIndex;
  final List<BottomBarItem> items;
  final double height;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;
  final bool showActiveBackgroundColor;
  final Curve curve;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final int itemCount = items.length;
    final double width = (w(context) - 80) / itemCount; // -80 for FAB space

    return Container(
      height: height,
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: LanguageC.to.axisStart,
        children: List<Widget>.generate(
          itemCount,
          (int index) {
            return _BottomBarItemWidget(
              itemCount: itemCount,
              bottomBarItem: items.elementAt(index),
              width: width,
              index: index,
              isSelected: index == selectedIndex,
              onTap: () => onTap(index),
              showActiveBackgroundColor: showActiveBackgroundColor,
              curve: curve,
              duration: duration,
            );
          },
        ),
      ),
    );
  }
}

class _BottomBarItemWidget extends StatelessWidget {
  const _BottomBarItemWidget({
    required this.itemCount,
    required this.bottomBarItem,
    required this.width,
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
  final double width;
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

    final bool rowMode = itemCount < 5; // false means column mode

    double iconSize = 30;
    final double w = width - iconSize;
    if (!rowMode && isSelected) iconSize = 40;

    Color selectedColor = bottomBarItem.selectedColor;
    Color selectedColorWithOpacity = selectedColor.withOpacity(0.1);

    return TweenAnimationBuilder<double>(
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
            message: bottomBarItem.trValTooltip,
            child: InkWell(
              onTap: onTap,
              customBorder: const StadiumBorder(),
              highlightColor: selectedColorWithOpacity,
              focusColor: selectedColorWithOpacity,
              splashColor: selectedColorWithOpacity,
              hoverColor: selectedColorWithOpacity,
              child: Row(
                children: [
                  if (index == 0)
                    SizedBox(width: rowMode ? w / 4 : w), // give space on left
                  if (!isSelected) SizedBox(width: w / 2.5),
                  rowMode
                      ? IconTheme(
                          data: IconThemeData(
                            color: Color.lerp(
                                _inactiveColor, selectedColor, value),
                            size: iconSize,
                          ),
                          child: bottomBarItem.iconData ==
                                  Icons.brightness_3_outlined
                              ? Transform.rotate(
                                  angle: 2.8, // Rotates crescent
                                  child: Icon(bottomBarItem.iconData,
                                      size: iconSize),
                                )
                              : Icon(bottomBarItem.iconData, size: iconSize),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconTheme(
                              data: IconThemeData(
                                color: Color.lerp(
                                    _inactiveColor, selectedColor, value),
                                size: iconSize,
                              ),
                              child: bottomBarItem.iconData ==
                                      Icons.brightness_3_outlined
                                  ? Transform.rotate(
                                      angle: 2.8, // Rotates crescent
                                      child: Icon(bottomBarItem.iconData,
                                          size: iconSize),
                                    )
                                  : Icon(bottomBarItem.iconData,
                                      size: iconSize),
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
                                  bottomBarItem.trValTitle,
                                  textStyle,
                                  w: w * 4,
                                  trVal: true,
                                ),
                              ),
                          ],
                        ),
                  if (!isSelected) SizedBox(width: w / 2.5),
                  if (isSelected && rowMode)
                    DefaultTextStyle(
                      style: textStyle.copyWith(
                        color: Color.lerp(
                          Colors.transparent,
                          selectedColor,
                          value,
                        ),
                      ),
                      child: T(
                        bottomBarItem.trValTitle,
                        textStyle,
                        w: w,
                        trVal: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BottomBarItem {
  const BottomBarItem(
    this.mainWidget,
    this.settingsWidget,
    this.trValTitle,
    this.trValTooltip,
    this.iconData,
    this.selectedColor, {
    this.onPressed,
  });
  final Widget mainWidget;
  final Widget? settingsWidget;
  final String trValTitle;
  final String trValTooltip;
  final IconData iconData;
  final Color selectedColor;
  final VoidCallback? onPressed;

  /// Keeps widget alive on UI, so when swiped doesn't lose settings
  Widget get aliveMainWidget => KeepAlivePage(child: mainWidget);
}
