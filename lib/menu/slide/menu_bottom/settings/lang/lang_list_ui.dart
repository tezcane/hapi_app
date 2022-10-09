import 'package:flutter/material.dart';
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.language_rounded, size: iconSize),
            T('Language', tsN, w: w / 4, alignment: LangC.to.centerLeft),
          ],
        ),
        DropdownPicker(
          tvMenuOptions: languageOptions,
          selectedOption: LangC.to.currLangKey,
          onChanged: (langKey) => LangC.to.updateLanguage(langKey!),
          width: (w / 4) * 3 - 24,
        ),
      ],
    );
  }
}
