import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';

/// another button in the ui.
///
/// PrimaryButton(
///                 labelText: 'UPDATE',
///                 onPressed: () => print('Submit'),
///               ),
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.tk,
    required this.onPressed,
    this.buttonStyle,
  });

  final String tk;
  final void Function() onPressed;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: T(
        tk,
        const TextStyle(fontWeight: FontWeight.bold),
        w: wm(context),
      ),
    );
  }
}
