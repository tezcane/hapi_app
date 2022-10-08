import 'package:flutter/material.dart';

/// Animation to show an alert to the user, bounces a widget
class BounceAlert extends StatefulWidget {
  const BounceAlert(this.child, {this.cycleMs = 1500, this.repeatCount = 5});

  /// The Widget to apply the effect to.
  final Widget child;

  /// The duration to bounce (1 full cycle).
  final int cycleMs;

  /// Number of times to repeat the animation, 0 for infinity.
  final int repeatCount;

  @override
  State<StatefulWidget> createState() {
    return _BounceAlertState();
  }
}

class _BounceAlertState extends State<BounceAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;

  int cycledCount = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.cycleMs ~/ 2),
    );

    _controller.addListener(() => setState(() {}));

    // grow from scale 1 to 1.3x:
    _animation = Tween(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceIn),
    );

    _controller.addStatusListener((AnimationStatus status) {
      switch (status) {
        case AnimationStatus.completed: // animation is stopped at the end.
          _controller.reverse(); // grow done, now shrink
          break;
        case AnimationStatus.dismissed: // animation stopped at the beginning.
          if (++cycledCount < widget.repeatCount) {
            _controller.forward(); // shrink done, now grow
          } else if (widget.repeatCount == 0) {
            _controller.forward(); // infinity, go forever
          }
          break;
        case AnimationStatus.reverse:
        case AnimationStatus.forward:
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
    return Transform.scale(scale: _animation.value, child: widget.child);
  }
}
