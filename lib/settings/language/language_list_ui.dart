import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/dropdown_picker.dart';
import 'package:hapi/settings/language/language_controller.dart';

class LanguageListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (c) => ListTile(
        title: Text('settings.language'.tr),
        trailing: DropdownPicker(
          menuOptions: languageOptions,
          selectedOption: c.currentLanguage,
          onChanged: (value) async {
            await c.updateLanguage(value!);
            Get.forceAppUpdate();
          },
        ),
      ),
    );
  }
}
