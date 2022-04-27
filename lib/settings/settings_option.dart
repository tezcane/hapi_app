import 'package:flutter/material.dart';

/// Model class to hold settings option data (language and theme)
class SettingsOption {
  SettingsOption(this.key, this.trValue, {this.icon});

  final String key;

  /// Must pass in a value already translated (e.g. uses GetX's tr).
  final String trValue;
  final IconData? icon;
}
