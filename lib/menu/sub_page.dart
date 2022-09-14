import 'package:flutter/material.dart';

enum SubPage {
  About,
  Settings,
  Update_Profile,
  Reset_Password,
  Tarikh_Timeline,
  Tarikh_Article,
  Active_Quest_Action,
  Family_Tree,
}

/// FAB (Floating Action Button) Sub Page, used to track animations for FAB.
class FabSubPage extends StatelessWidget {
  const FabSubPage({required this.subPage, required this.child});

  final SubPage subPage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: child, // <- SubPages go here
    );
  }
}
