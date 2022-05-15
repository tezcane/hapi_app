library bottom_bar;

import 'package:flutter/material.dart';
import 'package:hapi/helpers/keep_alive_page.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/settings/language/language_controller.dart';

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
    double width = w(context) / (items.length + 1);

    return Container(
      height: height,
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: LanguageController.to.axisStart,
        children: List<Widget>.generate(
          items.length,
          (int index) {
            return _BottomBarItemWidget(
              index: index,
              title: items.elementAt(index).title,
              iconData: items.elementAt(index).iconData,
              tooltip: items.elementAt(index).tooltip,
              width: width,
              isSelected: index == selectedIndex,
              selectedColor: items[index].selectedColor,
              selectedColorWithOpacity:
                  items[index].selectedColor.withOpacity(0.1),
              onTap: () => onTap(index),
              showActiveBackgroundColor: showActiveBackgroundColor,
              curve: curve,
              duration: duration,
            );
          },
        ),
      ),
      //),
    );
  }
}

class _BottomBarItemWidget extends StatelessWidget {
  /// Creates a Widget that displays the contents of a `BottomBarItem`
  const _BottomBarItemWidget({
    required this.index,
    required this.title,
    required this.iconData,
    required this.tooltip,
    required this.width,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedColorWithOpacity,
    required this.onTap,
    required this.showActiveBackgroundColor,
    required this.curve,
    required this.duration,
    this.useHapiLogoFont = true,
  });
  final int index;
  final String title;
  final IconData iconData;
  final String tooltip;
  final double width;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedColorWithOpacity;
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

    const double iconSize = 30;
    double w = width - iconSize;

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
            message: tooltip,
            child: InkWell(
              onTap: onTap,
              customBorder: const StadiumBorder(),
              highlightColor: selectedColorWithOpacity,
              focusColor: selectedColorWithOpacity,
              splashColor: selectedColorWithOpacity,
              hoverColor: selectedColorWithOpacity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (!isSelected) SizedBox(width: w / 2),
                  IconTheme(
                    data: IconThemeData(
                      color: Color.lerp(_inactiveColor, selectedColor, value),
                      size: iconSize,
                    ),
                    child: iconData == Icons.brightness_3_outlined // crescent
                        ? Transform.rotate(
                            angle: 2.8, // Rotates crescent
                            child: Icon(iconData, size: iconSize),
                          )
                        : Icon(iconData, size: iconSize),
                  ),
                  if (!isSelected) SizedBox(width: w / 2),
                  if (isSelected)
                    DefaultTextStyle(
                      style: textStyle.copyWith(
                        color: Color.lerp(
                          Colors.transparent,
                          selectedColor,
                          value,
                        ),
                      ),
                      child: T(title, textStyle, w: w),
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
  BottomBarItem(
    this.mainWidget,
    this.settingsWidget,
    this.title,
    this.iconData,
    this.tooltip,
    this.selectedColor,
  );
  final Widget mainWidget; // used by bottom_bar_menu
  final Widget? settingsWidget; // used by bottom_bar_menu
  final String title;
  final IconData iconData;
  final String tooltip;
  final Color selectedColor;

  /// Keeps widget alive on UI, so when swiped doesn't lose settings
  Widget get aliveMainWidget => KeepAlivePage(child: mainWidget);
}
