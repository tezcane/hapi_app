import 'package:flutter/material.dart';

// TODO cleaner way:
class AppThemes {
  AppThemes._();

  // TODO find where not used
  static const Color logoBackground = Color.fromRGBO(0x14, 0x1A, 0x42, 1);
  static const Color logoText = Color.fromRGBO(0xE3, 0x0A, 0x17, 1);

  static const Color ajr0Missed = Color.fromRGBO(0xE3, 0x0A, 0x17, 1);
  static const Color ajr1Common = Colors.grey;
  static const Color ajr2Uncommon = Colors.green;
  static const Color ajr3Rare = Colors.blue;
  static const Color ajr4Epic = Colors.purple;
  static const Color ajr5Legendary = Colors.yellowAccent;
  static const Color ajr6Mythic = Color(0xFFF1AC44);
  static const Color ajr7TimeNotInYet = Colors.transparent;
  static const List ajrColorsByIdx = [
    ajr0Missed,
    ajr1Common,
    ajr2Uncommon,
    ajr3Rare,
    ajr4Epic,
    ajr5Legendary,
    ajr6Mythic,
    ajr7TimeNotInYet,
  ];

  /// shared light and dark (ld) text color
  static const Color ldTextColor = Color(0xFF7F8B88);

  static const Color selected = logoText;
  static const Color unselected = Color(0xFF757575); // Grey 700

  static const Color hyperlink = Color.fromRGBO(0x10, 0x57, 0xE3, 1);

  static const Color colorDarkText = Color.fromRGBO(0, 0, 0, 0.87);
  static const Color eventsGutterAccent = Color.fromRGBO(229, 55, 108, 1.0);

  static const Color addIcon = Colors.green;
  static const Color checkComplete = Colors.green;

  static const Color _lBackground1 = Color.fromRGBO(225, 228, 229, 1);
  static const Color _lBackground2 = Color.fromRGBO(255, 242, 239, 1.0);

  static const Color _dBackground1 = Color.fromRGBO(0x0A, 0x0E, 0x21, 1);
  static const Color _dBackground2 = logoBackground;

  static const floatingActionButtonTheme = FloatingActionButtonThemeData(
      backgroundColor: logoText, foregroundColor: Colors.white);
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          primary: logoText,
          side: const BorderSide(color: Colors.grey, width: 1.5)));

  static final lightTheme = ThemeData.light().copyWith(
    floatingActionButtonTheme: floatingActionButtonTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    backgroundColor: _lBackground1,
    scaffoldBackgroundColor: _lBackground2,
    primaryTextTheme: Typography.blackMountainView,
    textTheme: Typography.blackMountainView,
    unselectedWidgetColor: selected, // set un-checked checkbox
  );

  static final darkTheme = ThemeData.dark().copyWith(
    floatingActionButtonTheme: floatingActionButtonTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    backgroundColor: _dBackground1,
    scaffoldBackgroundColor: _dBackground2,
    primaryTextTheme: Typography.whiteMountainView,
    textTheme: Typography.whiteMountainView,
    unselectedWidgetColor: selected, // set un-checked checkbox
  );
}
/*
/// contains info related to our light and dark themes.
class AppThemes2 {
  AppThemes2._();

  // TODO
  static const Color logoBackground = Color.fromRGBO(0x0A, 0x0E, 0x21, 1);
  static const Color logoText = Color.fromRGBO(0xE3, 0x0A, 0x17, 1);
//static const Color dodgerBlue = Color.fromRGBO(0x1D, 0x1E, 0x33, 1);

  static const Color dodgerBlue = Color.fromRGBO(29, 161, 242, 1);
  static const Color whiteLilac = Color.fromRGBO(248, 250, 252, 1);
  static const Color blackPearl = Color.fromRGBO(30, 31, 43, 1);
  static const Color brinkPink = Color.fromRGBO(255, 97, 136, 1);
  static const Color juneBud = Color.fromRGBO(186, 215, 97, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color nevada = Color.fromRGBO(105, 109, 119, 1);
  static const Color ebonyClay = Color.fromRGBO(40, 42, 58, 1);

  static const String font1 = "ProductSans";
  static const String font2 = "Roboto";
  //constants color range for light theme
  //main color
  static const Color _lightPrimaryColor = dodgerBlue;

  //Background Colors
  static const Color _lightBackgroundColor = whiteLilac;
  static const Color _lightBackgroundAppBarColor = _lightPrimaryColor;
  static const Color _lightBackgroundSecondaryColor = white;
  static const Color _lightBackgroundAlertColor = blackPearl;
  static const Color _lightBackgroundActionTextColor = white;
//static const Color _lightBackgroundErrorColor = brinkPink;
//static const Color _lightBackgroundSuccessColor = juneBud;

  //Text Colors
  static const Color _lightTextColor = Colors.black;
//static const Color _lightAlertTextColor = Colors.black;
//static const Color _lightTextSecondaryColor = Colors.black;

  //Border Color
  static const Color _lightBorderColor = nevada;

  //Icon Color
  static const Color _lightIconColor = nevada;

  //form input colors
//static const Color _lightInputFillColor = _lightBackgroundSecondaryColor;
  static const Color _lightBorderActiveColor = _lightPrimaryColor;
  static const Color _lightBorderErrorColor = brinkPink;

  //constants color range for dark theme
  static const Color _darkPrimaryColor = dodgerBlue;

  //Background Colors
  static const Color _darkBackgroundColor = ebonyClay;
  static const Color _darkBackgroundAppBarColor = _darkPrimaryColor;
  static const Color _darkBackgroundSecondaryColor =
      Color.fromRGBO(0, 0, 0, .6);
  static const Color _darkBackgroundAlertColor = blackPearl;
  static const Color _darkBackgroundActionTextColor = white;

//static const Color _darkBackgroundErrorColor =
//    Color.fromRGBO(255, 97, 136, 1);
//static const Color _darkBackgroundSuccessColor =
//    Color.fromRGBO(186, 215, 97, 1);

  //Text Colors
  static const Color _darkTextColor = Colors.white;
//static const Color _darkAlertTextColor = Colors.black;
//static const Color _darkTextSecondaryColor = Colors.black;

  //Border Color
  static const Color _darkBorderColor = nevada;

  //Icon Color
  static const Color _darkIconColor = nevada;

  static const Color _darkInputFillColor = _darkBackgroundSecondaryColor;
  static const Color _darkBorderActiveColor = _darkPrimaryColor;
  static const Color _darkBorderErrorColor = brinkPink;

  //text theme for light theme
  static const TextTheme _lightTextTheme = TextTheme(
    headline1: TextStyle(fontSize: 20.0, color: _lightTextColor),
    bodyText1: TextStyle(fontSize: 16.0, color: _lightTextColor),
    bodyText2: TextStyle(fontSize: 14.0, color: Colors.grey),
    button: TextStyle(
        fontSize: 15.0, color: _lightTextColor, fontWeight: FontWeight.w600),
    headline6: TextStyle(fontSize: 16.0, color: _lightTextColor),
    subtitle1: TextStyle(fontSize: 16.0, color: _lightTextColor),
    caption: TextStyle(fontSize: 12.0, color: _lightBackgroundAppBarColor),
  );

  //the light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    fontFamily: font1,
    scaffoldBackgroundColor: _lightBackgroundColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightPrimaryColor,
    ),
    appBarTheme: const AppBarTheme(
      color: _lightBackgroundAppBarColor,
      iconTheme: IconThemeData(color: _lightTextColor),
      textTheme: _lightTextTheme,
    ),
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryVariant: _lightBackgroundColor,
      // secondary: _lightSecondaryColor,
    ),
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: _lightBackgroundAlertColor,
        actionTextColor: _lightBackgroundActionTextColor),
    iconTheme: const IconThemeData(
      color: _lightIconColor,
    ),
    popupMenuTheme:
        const PopupMenuThemeData(color: _lightBackgroundAppBarColor),
    textTheme: _lightTextTheme,
    buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        buttonColor: _lightPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _lightPrimaryColor,
    inputDecorationTheme: const InputDecorationTheme(
      //prefixStyle: TextStyle(color: _lightIconColor),
      border: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          )),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBorderColor, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBorderActiveColor),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBorderErrorColor),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _lightBorderErrorColor),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      fillColor: _lightBackgroundSecondaryColor,
      //focusColor: _lightBorderActiveColor,
    ),
  );

//text theme for dark theme
  /*static final TextStyle _darkScreenHeadingTextStyle =
      _lightScreenHeadingTextStyle.copyWith(color: _darkTextColor);
  static final TextStyle _darkScreenQuestNameTextStyle =
      _lightScreenQuestNameTextStyle.copyWith(color: _darkTextColor);
  static final TextStyle _darkScreenQuestDurationTextStyle =
      _lightScreenQuestDurationTextStyle;
  static final TextStyle _darkScreenButtonTextStyle = TextStyle(
      fontSize: 14.0, color: _darkTextColor, fontWeight: FontWeight.w500);
  static final TextStyle _darkScreenCaptionTextStyle = TextStyle(
      fontSize: 12.0,
      color: _darkBackgroundAppBarColor,
      fontWeight: FontWeight.w100);*/

  static const TextTheme _darkTextTheme = TextTheme(
    headline1: TextStyle(fontSize: 20.0, color: _darkTextColor),
    bodyText1: TextStyle(fontSize: 16.0, color: _darkTextColor),
    bodyText2: TextStyle(fontSize: 14.0, color: Colors.grey),
    button: TextStyle(
        fontSize: 15.0, color: _darkTextColor, fontWeight: FontWeight.w600),
    headline6: TextStyle(fontSize: 16.0, color: _darkTextColor),
    subtitle1: TextStyle(fontSize: 16.0, color: _darkTextColor),
    caption: TextStyle(fontSize: 12.0, color: _darkBackgroundAppBarColor),
  );

  //the dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    //primarySwatch: _darkPrimaryColor, //cant be Color on MaterialColor so it can compute different shades.
    accentColor: _darkPrimaryColor, //prefix icon color form input on focus

    fontFamily: font1,
    scaffoldBackgroundColor: _darkBackgroundColor,
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
    ),
    appBarTheme: const AppBarTheme(
      color: _darkBackgroundAppBarColor,
      iconTheme: IconThemeData(color: _darkTextColor),
      textTheme: _darkTextTheme,
    ),
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      primaryVariant: _darkBackgroundColor,

      // secondary: _darkSecondaryColor,
    ),
    snackBarTheme: const SnackBarThemeData(
        contentTextStyle: TextStyle(color: Colors.white),
        backgroundColor: _darkBackgroundAlertColor,
        actionTextColor: _darkBackgroundActionTextColor),
    iconTheme: const IconThemeData(
      color: _darkIconColor, //_darkIconColor,
    ),
    popupMenuTheme: const PopupMenuThemeData(color: _darkBackgroundAppBarColor),
    textTheme: _darkTextTheme,
    buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        buttonColor: _darkPrimaryColor,
        textTheme: ButtonTextTheme.primary),
    unselectedWidgetColor: _darkPrimaryColor,
    inputDecorationTheme: const InputDecorationTheme(
      prefixStyle: TextStyle(color: _darkIconColor),
      //labelStyle: TextStyle(color: nevada),
      border: OutlineInputBorder(
          borderSide: BorderSide(width: 1.0),
          borderRadius: BorderRadius.all(
            Radius.circular(8.0),
          )),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkBorderColor, width: 1.0),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkBorderActiveColor),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkBorderErrorColor),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: _darkBorderErrorColor),
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      fillColor: _darkInputFillColor,
      //focusColor: _darkBorderActiveColor,
    ),
  );
}
*/
