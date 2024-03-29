import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';

/// shows a dropdown list with icons.
///
/// DropdownPickerWithIcon(
///                 menuOptions: list of dropdown options in key value pairs,
///                 selectedOption: menu option string value,
///                 onChanged: (value) => print('changed'),
///               ),
///
class DropdownPickerWithIcon extends StatelessWidget {
  const DropdownPickerWithIcon(
      {required this.menuOptions,
      required this.selectedOption,
      this.onChanged});

  final List<dynamic> menuOptions;
  final String selectedOption;
  final void Function(String?)? onChanged;

  @override
  Widget build(BuildContext context) {
    //if (Platform.isIOS) {}
    return DropdownButton<String>(
        items: menuOptions
            .map((data) => DropdownMenuItem<String>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Icon(data.icon),
                      const SizedBox(width: 10),
                      T(data.tv, AppThemes.tsTitle), // tr ok
                    ],
                  ),
                  value: data.key,
                ))
            .toList(),
        value: selectedOption,
        onChanged: onChanged);
  }
}
