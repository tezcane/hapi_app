import 'package:flutter/material.dart';

/// Animation to show an alert to the user, grows and shrinks a widget
class GrowShrinkAlert extends StatefulWidget {
  const GrowShrinkAlert(
    this.child, {
    this.cycleMs = 2000,
    this.repeatCount = 3,
  });

  /// The Widget to apply the effect to.
  final Widget child;

  /// The duration to grow then shrink again (1 full cycle).
  final int cycleMs;

  /// Number of times to repeat the animation, 0 for infinity.
  final int repeatCount;

  @override
  State<StatefulWidget> createState() {
    return _GrowShrinkAlertState();
  }
}

class _GrowShrinkAlertState extends State<GrowShrinkAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _grow;

  int cycledCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.cycleMs ~/ 2),
    );

    _controller.addListener(() => setState(() {}));

    // grow from scale 1 to 1.5x:
    _grow = Tween(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.addStatusListener((AnimationStatus status) {
      switch (status) {
        case (AnimationStatus.completed): // animation is stopped at the end.
          _controller.reverse(); // grow done, now shrink
          break;
        case (AnimationStatus.dismissed): // animation stopped at the beginning.
          if (++cycledCount < widget.repeatCount) {
            _controller.forward(); // shrink done, now grow
          }
          break;
        default:
          break;
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(scale: _grow.value, child: widget.child);
  }
}
