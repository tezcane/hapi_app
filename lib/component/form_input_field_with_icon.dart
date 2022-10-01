import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// handles our form field elements but has an icon too.
/// FormInputFieldWithIcon(
///                 controller: _email,
///                 iconPrefix: Icons.link,
///                 labelText: 'Post URL',
///                 validator: Validator.notEmpty,
///                 keyboardType: TextInputType.multiline,
///                 minLines: 3,
///                 onChanged: (value) => print('changed'),
///                 onSaved: (value) => print('implement me'),
///               ),
class FormInputFieldWithIcon extends StatelessWidget {
  const FormInputFieldWithIcon(
      {required this.controller,
      required this.iconPrefix,
      required this.tk,
      required this.validator,
      this.keyboardType = TextInputType.text,
      this.obscureText = false,
      this.minLines = 1,
      this.maxLines,
      required this.onChanged,
      required this.onSaved});

  final TextEditingController controller;
  final IconData iconPrefix;
  final String tk;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool obscureText;
  final int minLines;
  final int? maxLines;
  final void Function(String) onChanged;
  final void Function(String?)? onSaved;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        filled: true,
        prefixIcon: Icon(iconPrefix),
        labelText: tk.tr,
      ),
      controller: controller,
      onSaved: onSaved,
      onChanged: onChanged,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
    );
  }
}
