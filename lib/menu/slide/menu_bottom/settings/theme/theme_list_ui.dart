import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/segmented_selector.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/settings_option.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/theme_c.dart';

class ThemeListUI extends StatelessWidget {
  const ThemeListUI(this.width);
  final double width;

  @override
  Widget build(BuildContext context) {
    double iconSize = 32;
    double separatorSize = 20;
    double w = width - iconSize - separatorSize;

    return GetBuilder<ThemeC>(
      builder: (c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Icon(Icons.palette_outlined, size: iconSize),
            T(
              'i.Theme',
              tsN,
              w: w / 4,
              alignment: LanguageC.to.centerLeft,
            ),
          ]),
          SizedBox(
            width: (w / 4) * 3, // needed
            child: SegmentedSelector(
              selectedOption: c.currentTheme,
              tvMenuOptions: [
                SettingsOption(
                  'light',
                  'i.Light'.tr,
                  icon: Icons.brightness_low,
                ),
                SettingsOption(
                  'dark',
                  'i.Dark'.tr,
                  icon: Icons.brightness_3,
                )
              ],
              onValueChanged: (value) => c.setThemeMode(value!),
              width: (w / 4) * 3,
            ),
          ),
        ],
      ),
    );
  }
}
