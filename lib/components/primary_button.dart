import 'package:flutter/material.dart';

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
      child: Text(
        labelText.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
