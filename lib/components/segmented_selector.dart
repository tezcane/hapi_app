import 'package:flutter/cupertino.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_controller.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/settings_option.dart';

/// a control used to select the theme.
///
/// SegmentedSelector(
///                 menuOptions: list of dropdown options in key value pairs,
///                 selectedOption: menu option string value,
///                 onChanged: (value) => print('changed'),
///               ),
class SegmentedSelector extends StatelessWidget {
  const SegmentedSelector({
    required this.trValMenuOptions,
    required this.selectedOption,
    required this.onValueChanged,
    required this.width,
  });
  final List<SettingsOption> trValMenuOptions;
  final String selectedOption;
  final void Function(String?) onValueChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    double iconSize = 32;
    double w = width - (iconSize * trValMenuOptions.length) - 8;
    return CupertinoSlidingSegmentedControl(
      //thumbColor: AppThemes.selected,
      groupValue: selectedOption,
      children: {
        for (var option in trValMenuOptions)
          option.key: Row(
            children: [
              Icon(option.icon, size: iconSize),
              T(
                option.trVal,
                tsN,
                w: w / trValMenuOptions.length,
                alignment: LanguageController.to.centerLeft,
                trVal: true,
              ),
            ],
          )
      },
      onValueChanged: onValueChanged,
    );
  }
}
