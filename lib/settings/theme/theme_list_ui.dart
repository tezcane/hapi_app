import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/segmented_selector.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/settings/settings_option.dart';
import 'package:hapi/settings/theme/theme_controller.dart';

class ThemeListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          T(
            'settings.theme',
            null,
            w: wm(context) / 4,
            alignment: Alignment.center,
          ),
          SegmentedSelector(
            selectedOption: c.currentTheme,
            trMenuOptions: [
              SettingsOption(
                'light',
                'settings.light'.tr, // tr ok
                icon: Icons.brightness_low,
              ),
              SettingsOption(
                'dark',
                'settings.dark'.tr, // tr ok
                icon: Icons.brightness_3,
              )
            ],
            onValueChanged: (value) => c.setThemeMode(value),
          ),
        ],
      ),
    );
  }
}
