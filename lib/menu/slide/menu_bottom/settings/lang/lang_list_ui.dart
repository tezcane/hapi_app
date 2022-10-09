import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/dropdown_picker.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';

class LangListUI extends StatelessWidget {
  const LangListUI(this.width);
  final double width;

  @override
  Widget build(BuildContext context) {
    double iconSize = 32;
    double separatorSize = 20;
    double w = width - iconSize - separatorSize;
    // LangC needed or UI will not work properly after new lang selection
    return GetBuilder<LangC>(builder: (c) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.language_rounded, size: iconSize),
              T('Language', tsN, w: w / 4, alignment: c.centerLeft),
            ],
          ),
          DropdownPicker(
            tvMenuOptions: languageOptions,
            selectedOption: c.currLangKey,
            onChanged: (langKey) => c.updateLanguage(langKey!),
            width: (w / 4) * 3 - 24,
          ),
        ],
      );
    });
  }
}
