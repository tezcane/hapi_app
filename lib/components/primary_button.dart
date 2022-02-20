import 'package:flutter/material.dart';

/// another button in the ui.
///
/// PrimaryButton(
///                 labelText: 'UPDATE',
///                 onPressed: () => print('Submit'),
///               ),
class PrimaryButton extends StatelessWidget {
  PrimaryButton({required this.labelText, required this.onPressed});

  final String labelText;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        labelText.toUpperCase(),
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
