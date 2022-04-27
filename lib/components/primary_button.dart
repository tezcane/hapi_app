import 'package:flutter/material.dart';
import 'package:hapi/main_controller.dart';

/// another button in the ui.
///
/// PrimaryButton(
///                 labelText: 'UPDATE',
///                 onPressed: () => print('Submit'),
///               ),
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.labelText,
    required this.onPressed,
    this.buttonStyle,
  });

  final String labelText;
  final void Function() onPressed;
  final ButtonStyle? buttonStyle;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: T(
        labelText,
        const TextStyle(fontWeight: FontWeight.bold),
        w: w(context) - 40,
      ),
    );
  }
}
