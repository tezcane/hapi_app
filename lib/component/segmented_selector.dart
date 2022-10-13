import 'package:flutter/cupertino.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/settings_option.dart';

/// Component to select things like a dark/light theme, more than 2 options
class SegmentedSelector extends StatelessWidget {
  const SegmentedSelector({
    required this.tvMenuOptions, // list of dropdown options in key value pairs
    required this.selectedOption, // menu option string value
    required this.onValueChanged,
    required this.width,
  });
  final List<SettingsOption> tvMenuOptions;
  final String selectedOption;
  final void Function(String?) onValueChanged;
  final double width;

  @override
  Widget build(BuildContext context) {
    double iconSize = 32;
    double w = width - (iconSize * tvMenuOptions.length) - 8;
    return CupertinoSlidingSegmentedControl(
      //thumbColor: AppThemes.selected,
      groupValue: selectedOption,
      children: {
        for (var option in tvMenuOptions)
          option.key: Row(
            children: [
              Icon(option.icon, size: iconSize),
              T(
                option.tv,
                ts,
                w: w / tvMenuOptions.length,
                alignment: LangC.to.centerLeft,
                tv: true,
              ),
            ],
          )
      },
      onValueChanged: onValueChanged,
    );
  }
}
