import 'package:flutter/material.dart';

// Model class to hold settings option data (language and theme)
class SettingsOptionModel {
  final String key;
  final String value;
  final IconData? icon;

  SettingsOptionModel({required this.key, required this.value, this.icon});
}
