import 'package:flutter/material.dart';

/// Model class to hold settings option data (language and theme)
class SettingsOption {
  final String key;
  final String value;
  final IconData? icon;

  SettingsOption({required this.key, required this.value, this.icon});
}
