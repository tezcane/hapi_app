import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hapi/menu/menu_controller.dart';

class FabSubPage extends StatelessWidget {
  FabSubPage({Key? key, required this.subPage, required this.child})
      : super(key: key) {
    SystemChrome.setEnabledSystemUIOverlays([]);
  }

  final SubPage subPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: background,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Go back to the previous page',
        onPressed: null,
        heroTag: subPage,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                // iconSize: 50,
                icon: Icon(Icons.arrow_back),
                onPressed: () => cMenu.handleBackButtonHit(),
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
