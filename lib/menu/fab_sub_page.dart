import 'package:flutter/material.dart';
import 'package:hapi/menu/menu_controller.dart';

class FabSubPage extends StatelessWidget {
  final Widget child;
  const FabSubPage({Key? key, required this.child}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: null,
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
