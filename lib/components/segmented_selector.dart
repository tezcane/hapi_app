import 'package:flutter/cupertino.dart';

/// a control used to select the theme.
///
/// SegmentedSelector(
///                 menuOptions: list of dropdown options in key value pairs,
///                 selectedOption: menu option string value,
///                 onChanged: (value) => print('changed'),
///               ),
class SegmentedSelector extends StatelessWidget {
  const SegmentedSelector({
    required this.trMenuOptions,
    required this.selectedOption,
    required this.onValueChanged,
  });

  /// must have
  final List<dynamic> trMenuOptions;
  final String selectedOption;
  final void Function(dynamic) onValueChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoSlidingSegmentedControl(
        //thumbColor: Theme.of(context).primaryColor,
        groupValue: selectedOption,
        children: {
          for (var option in trMenuOptions)
            option.key: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(option.icon),
                const SizedBox(width: 6),
                Text(option.trValue), // tr ok
              ],
            )
        },
        onValueChanged: onValueChanged);
  }
}
