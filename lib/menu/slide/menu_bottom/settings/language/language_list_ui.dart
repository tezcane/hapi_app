import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/dropdown_picker.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';

class LanguageListUI extends StatelessWidget {
  const LanguageListUI(this.width);
  final double width;

  @override
  Widget build(BuildContext context) {
    double iconSize = 32;
    double separatorSize = 20;
    double w = width - iconSize - separatorSize;
    return GetBuilder<LanguageC>(
      builder: (c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.language_rounded, size: iconSize),
              T(
                'Language',
                tsN,
                w: w / 4,
                alignment: LanguageC.to.centerLeft,
              ),
            ],
          ),
          DropdownPicker(
            tvMenuOptions: languageOptions,
            selectedOption: c.currLangKey,
            onChanged: (langKey) => c.updateLanguage(langKey!),
            width: (w / 4) * 3 - 24,
          ),
        ],
      ),
    );
  }
}
