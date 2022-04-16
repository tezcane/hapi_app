import 'package:flutter/material.dart';

/// Model class to hold settings option data (language and theme)
class SettingsOption {
  SettingsOption(this.key, this.value, {this.icon});

  final String key;
  final String value;
  final IconData? icon;
}
