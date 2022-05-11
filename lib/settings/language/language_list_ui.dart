import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/dropdown_picker.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/settings/language/language_controller.dart';

class LanguageListUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<LanguageController>(
      builder: (c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          T(
            'i.Language',
            null,
            w: wm(context) / 4,
            alignment: LanguageController.to.centerLeft,
          ),
          DropdownPicker(
            trMenuOptions: languageOptions,
            selectedOption: c.currLangKey,
            onChanged: (langKey) => c.updateLanguage(langKey!),
          ),
        ],
      ),
    );
  }
}
