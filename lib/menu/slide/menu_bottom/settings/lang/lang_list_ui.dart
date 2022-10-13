import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/dropdown_picker.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';

class LangListUI extends StatelessWidget {
  const LangListUI(this.width, this.forceLaterLastNavPageRefresh);
  final double width;
  final bool forceLaterLastNavPageRefresh;

  @override
  Widget build(BuildContext context) {
    double iconSize = 32;
    double separatorSize = 20;
    double w = width - iconSize - separatorSize;
    // LangC needed or UI will not work properly after new lang selection
    return GetBuilder<LangC>(
      builder: (c) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.public_outlined, size: iconSize),
              T('Language', ts, w: w / 4, alignment: c.centerLeft),
            ],
          ),
          DropdownPicker(
            tvMenuOptions: languageOptions,
            selectedOption: c.currLangKey,
            onChanged: (langKey) {
              c.updateLanguage(langKey!);
              if (forceLaterLastNavPageRefresh) {
                MenuC.to.setPendingLangChangeFlag();
              }
            },
            width: (w / 4) * 3 - 24,
          ),
        ],
      ),
    );
  }
}
