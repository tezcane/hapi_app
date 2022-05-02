import 'package:flutter/material.dart';

/// shows a dropdown list.
///
/// DropdownPicker(
///              menuOptions: list of dropdown options in key value pairs,
///              selectedOption: menu option string value,
///              onChanged: (value) => print('changed'),
/// ),
class DropdownPicker extends StatelessWidget {
  const DropdownPicker({
    required this.trMenuOptions,
    required this.selectedOption,
    required this.onChanged,
  });

  /// Must use already translated text in here (e.g. uses GetX's .tr)
  final List<dynamic> trMenuOptions;
  final String selectedOption;
  final void Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        items: trMenuOptions
            .map((data) => DropdownMenuItem<String>(
                  child: Text(data.trVal), // tr ok
                  value: data.key,
                ))
            .toList(),
        value: selectedOption,
        onChanged: onChanged);
  }
}
