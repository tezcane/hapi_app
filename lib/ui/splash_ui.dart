import 'package:flutter/material.dart';

import '../constants/app_themes.dart';

class SplashUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemes.logoBackground,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Image.asset(
              'assets/images/logo/logo.png',
              width: 250,
              height: 250,
            ),
          ),
          //CircularProgressIndicator(),
        ],
      ),
    );
  }
}
