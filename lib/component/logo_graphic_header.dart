import 'package:flutter/material.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/theme_c.dart';

/// a graphic displayed in our ui.
class LogoGraphicHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String _imageLogo = 'assets/images/profileD.png';
    if (ThemeC.to.isDarkMode == false) {
      _imageLogo = 'assets/images/profileL.png';
    }

    return Hero(
      tag: 'App Logo',
      child: CircleAvatar(
          //foregroundColor: Colors.blue,
          backgroundColor: Colors.transparent,
          radius: 60.0,
          child: ClipOval(
            child: Image.asset(
              _imageLogo,
              fit: BoxFit.cover,
              width: 120.0,
              height: 120.0,
            ),
          )),
    );
  }
}
