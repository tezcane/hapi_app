import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/settings_option.dart';

/// shows a dropdown list.
///
/// DropdownPicker(
///              menuOptions: list of dropdown options in key value pairs,
///              selectedOption: menu option string value,
///              onChanged: (value) => print('changed'),
/// ),
class DropdownPicker extends StatelessWidget {
  const DropdownPicker({
    required this.tvMenuOptions,
    required this.selectedOption,
    required this.onChanged,
    required this.width,
  });

  /// Must use already translated text in here (e.g. uses GetX's .tr)
  final List<SettingsOption> tvMenuOptions;
  final String selectedOption;
  final void Function(String?) onChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      items: tvMenuOptions
          .map(
            (data) => DropdownMenuItem<String>(
              child: T(
                data.tv,
                data.key == selectedOption ? ts : tsN, // select active key
                w: width,
                alignment: LangC.to.centerRight,
                tv: true,
              ),
              value: data.key,
            ),
          )
          .toList(),
      value: selectedOption,
      onChanged: onChanged,
    );
  }
}
