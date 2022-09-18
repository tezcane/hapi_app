///
/// NOTE: This is not used, but really nice, from:
///          https://www.youtube.com/watch?v=pr_Go9I19SA
///
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
//
// /// Show/Hide something (e.g. bottom bar) based on scrolling a page up/down.
// class ScrollToHideWidget extends StatefulWidget {
//   const ScrollToHideWidget({
//     required this.controller,
//     required this.child,
//     required this.height,
//     this.duration = const Duration(milliseconds: 200),
//   });
//
//   final ScrollController controller;
//   final Widget child;
//   final double height;
//   final Duration duration;
//
//   @override
//   State<ScrollToHideWidget> createState() => _ScrollToHideWidgetState();
// }
//
// class _ScrollToHideWidgetState extends State<ScrollToHideWidget> {
//   bool _isVisible = true;
//
//   @override
//   void initState() {
//     super.initState();
//     widget.controller.addListener(listen);
//   }
//
//   @override
//   void dispose() {
//     widget.controller.removeListener(listen);
//     super.dispose();
//   }
//
//   void listen() {
//     final direction = widget.controller.position.userScrollDirection;
//
//     if (direction == ScrollDirection.forward) {
//       show();
//     } else if (direction == ScrollDirection.reverse) {
//       hide();
//     }
//
//     // show/hide based on number of pixels scrolled up/down
//     // if (widget.controller.position.pixels >= 200) {
//     //   show();
//     // } else {
//     //   hide();
//     // }
//   }
//
//   void show() {
//     if (!_isVisible) setState(() => _isVisible = true);
//   }
//
//   void hide() {
//     if (_isVisible) setState(() => _isVisible = false);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: widget.duration,
//       height: _isVisible ? widget.height : 0,
//       child: Wrap(children: [widget.child]),
//     );
//   }
// }
