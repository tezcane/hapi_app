import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/segmented_selector.dart';
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
          Text('settings.theme'.tr),
          SegmentedSelector(
            selectedOption: c.currentTheme,
            menuOptions: [
              SettingsOption(
                key: 'light',
                value: 'settings.light'.tr,
                icon: Icons.brightness_low,
              ),
              SettingsOption(
                key: 'dark',
                value: 'settings.dark'.tr,
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
