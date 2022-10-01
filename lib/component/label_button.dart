import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';

/// one type of button in ui.
///
/// LabelButton(
///                 labelText: 'Some Text',
///                 onPressed: () => print('implement me'),
///               ),
class LabelButton extends StatelessWidget {
  const LabelButton({required this.tk, required this.onPressed});
  final String tk;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: T(tk, null, w: wm(context)),
      onPressed: onPressed,
    );
  }
}
