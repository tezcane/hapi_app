import 'package:flutter/cupertino.dart';
//import 'package:hapi/components/sliding_segmented_control.dart';

/// a control used to select the theme.
///
/// SegmentedSelector(
///                 menuOptions: list of dropdown options in key value pairs,
///                 selectedOption: menu option string value,
///                 onChanged: (value) => print('changed'),
///               ),
class SegmentedSelector extends StatelessWidget {
  const SegmentedSelector(
      {required this.menuOptions,
      required this.selectedOption,
      required this.onValueChanged});

  final List<dynamic> menuOptions;
  final String selectedOption;
  final void Function(dynamic) onValueChanged;

  @override
  Widget build(BuildContext context) {
    //if (Platform.isIOS) {}

    return CupertinoSlidingSegmentedControl(
        //thumbColor: Get.theme.primaryColor,
        groupValue: selectedOption,
        children: {
          for (var option in menuOptions)
            option.key: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(option.icon),
                const SizedBox(width: 6),
                Text(option.value),
              ],
            )
        },
        onValueChanged: onValueChanged);
  }
}
