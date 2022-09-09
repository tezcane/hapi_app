import 'package:flutter/material.dart';

/// Class keeps a page alive, as long as it is not taken off the navigator. So
/// for example you can keep states of menu sub pages when using a PageView to
/// swipe between them.
class KeepAlivePage extends StatefulWidget {
  const KeepAlivePage({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _KeepAlivePageState createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context); // Don't forget this

    return widget.child;
  }

  @override
  bool get wantKeepAlive => true; // TODO: implement wantKeepAlive features
}
