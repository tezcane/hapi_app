import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/segmented_selector.dart';
import 'package:hapi/settings/settings_option_model.dart';
import 'package:hapi/settings/theme/theme_controller.dart';

class ThemeListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<SettingsOptionModel> themeOptions = [
      // SettingsOptionModel(
      //     key: "system", value: 'settings.system'.tr, icon: Icons.brightness_4),
      SettingsOptionModel(
          key: "light", value: 'settings.light'.tr, icon: Icons.brightness_low),
      SettingsOptionModel(
          key: "dark", value: 'settings.dark'.tr, icon: Icons.brightness_3)
    ];

    return GetBuilder<ThemeController>(
      builder: (c) => ListTile(
        title: Text('settings.theme'.tr),
        trailing: SegmentedSelector(
          selectedOption: c.currentTheme,
          menuOptions: themeOptions,
          onValueChanged: (value) => c.setThemeMode(value),
        ),
      ),
    );
  }
}
