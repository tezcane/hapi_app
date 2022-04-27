import 'package:flutter/material.dart';
import 'package:hapi/main_controller.dart';

/// one type of button in ui.
///
/// LabelButton(
///                 labelText: 'Some Text',
///                 onPressed: () => print('implement me'),
///               ),
class LabelButton extends StatelessWidget {
  const LabelButton({required this.trKey, required this.onPressed});
  final String trKey;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: T(trKey, null, w: wm(context)),
      onPressed: onPressed,
    );
  }
}
