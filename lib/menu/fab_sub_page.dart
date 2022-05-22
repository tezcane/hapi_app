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
      backgroundColor: Theme.of(context).backgroundColor,

      // // used only for the hero movements and hide keyboard on text search bars
      // floatingActionButton: FloatingActionButton(
      //   tooltip: 'Hide keyboard',
      //   onPressed: () =>
      //       SystemChannels.textInput.invokeMethod('TextInput.hide'),
      //   heroTag: subPage,
      //   child: const Icon(Icons.arrow_back_outlined, size: 30),
      // ),
      body: child, // <- SubPages go here
    );
  }
}
