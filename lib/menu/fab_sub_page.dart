import 'package:flutter/material.dart';
import 'package:hapi/menu/menu_controller.dart';

class FabSubPage extends StatelessWidget {
  const FabSubPage({Key? key, required this.subPage, required this.child})
      : super(key: key);

  final SubPage subPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          tooltip: 'Go back to the previous page',
          onPressed: () => cMenu.handleBackButtonHit(),
          heroTag: subPage,
          child: Icon(Icons.arrow_back),
        ),
      ),
      body: child, // <- SubPages go here
    );
  }
}
