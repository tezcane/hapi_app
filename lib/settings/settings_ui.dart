import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/dropdown_picker.dart';
import 'package:hapi/components/segmented_selector.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';
import 'package:hapi/settings/language/language_controller.dart';
import 'package:hapi/settings/settings_option_model.dart';
import 'package:hapi/settings/theme/theme_controller.dart';
import 'package:hapi/settings/update_profile_ui.dart';

/// contains the settings screen for setting the theme and language and some user settings.
class SettingsUI extends StatelessWidget {
  //final LanguageController languageController = LanguageController.to;
  //final ThemeController themeController = ThemeController.to;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings.title'.tr),
      ),
      body: _buildLayoutSection(context),
    );
  }

  Widget _buildLayoutSection(BuildContext context) {
    return ListView(
      children: <Widget>[
        languageListTile(context),
        themeListTile(context),
        ListTile(
            title: Text('settings.updateProfile'.tr),
            trailing: ElevatedButton(
              onPressed: () async {
                Get.to(() => UpdateProfileUI());
              },
              child: Text(
                'settings.updateProfile'.tr,
              ),
            )),
        ListTile(
          title: Text('settings.signOut'.tr),
          trailing: ElevatedButton(
            onPressed: () {
              AuthController.to.signOut();
            },
            child: Text(
              'settings.signOut'.tr,
            ),
          ),
        ),
      ],
    );
  }

  languageListTile(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (controller) => ListTile(
        title: Text('settings.language'.tr),
        trailing: DropdownPicker(
          menuOptions: languageOptions,
          selectedOption: controller.currentLanguage,
          onChanged: (value) async {
            await controller.updateLanguage(value!);
            Get.forceAppUpdate();
          },
        ),
      ),
    );
  }

  themeListTile(BuildContext context) {
    final List<SettingsOptionModel> themeOptions = [
      SettingsOptionModel(
          key: "system", value: 'settings.system'.tr, icon: Icons.brightness_4),
      SettingsOptionModel(
          key: "light", value: 'settings.light'.tr, icon: Icons.brightness_low),
      SettingsOptionModel(
          key: "dark", value: 'settings.dark'.tr, icon: Icons.brightness_3)
    ];
    return GetBuilder<ThemeController>(
      builder: (controller) => ListTile(
        title: Text('settings.theme'.tr),
        trailing: SegmentedSelector(
          selectedOption: controller.currentTheme,
          menuOptions: themeOptions,
          onValueChanged: (value) {
            controller.setThemeMode(value);
          },
        ),
      ),
    );
  }
}
