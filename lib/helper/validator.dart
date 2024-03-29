import 'package:get/get.dart';

/// contains some validation functions for our form fields.
/// matching various patterns for kinds of data
class Validator {
  Validator();

  String? email(String? value) {
    String pattern = r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Must be a valid email address'.tr; // tr ok
    } else {
      return null;
    }
  }

  String? password(String? value) {
    String pattern = r'^.{6,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Password must be at least 6 characters'.tr; // tr ok
    } else {
      return null;
    }
  }

  String? name(String? value) {
    String pattern = r"^[a-zA-Z]+(([',. -][a-zA-Z ])?[a-zA-Z]*)*$";
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'Must be a name'.tr; // tr ok
    } else {
      return null;
    }
  }

  // String? number(String? value) {
  //   String pattern = r'^\D?(\d{3})\D?\D?(\d{3})\D?(\d{4})$';
  //   RegExp regex = RegExp(pattern);
  //   if (!regex.hasMatch(value!)) {
  //     return 'Must be a number'.tr; // tr ok
  //   } else {
  //     return null;
  //   }
  // }

  // validator.amount =
  //   Please enter a number, i.e. "250" - no dollar symbol and no cents
  // String? amount(String? value) {
  //   String pattern = r'^\d+$';
  //   RegExp regex = RegExp(pattern);
  //   if (!regex.hasMatch(value!)) {
  //     return 'validator.amount'.tr; // tr ok
  //   } else {
  //     return null;
  //   }
  // }

  String? notEmpty(String? value) {
    String pattern = r'^\S+$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value!)) {
      return 'This is required'.tr; // tr ok
    } else {
      return null;
    }
  }
}
