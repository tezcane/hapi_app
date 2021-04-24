import 'package:flutter/material.dart';
import 'package:hapi/constants/app_themes.dart';

class Menu extends StatefulWidget {
  final double scaleWidth;
  final double scaleHeight;
  final Widget foregroundWidget;
  final Widget columnWidget;
  final Widget bottomWidget;
  final Duration buttonAnimationDuration;
  final Duration slideAnimationDuration;
  final Curve openAnimationCurve;
  final Curve closeAnimationCurve;
  final IconData buttonIcon;
  final bool animateButton;

  const Menu({
    Key? key,
    this.scaleWidth = 60,
    this.scaleHeight = 60,
    required this.columnWidget,
    required this.bottomWidget,
    required this.foregroundWidget,
    this.slideAnimationDuration = const Duration(milliseconds: 800),
    this.buttonAnimationDuration = const Duration(milliseconds: 240),
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
    this.buttonIcon = Icons.add,
    this.animateButton = true,
  })  : assert(scaleHeight >= 40),
        super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> with SingleTickerProviderStateMixin {
  bool opened = false;
  AnimationController? _animationController;

  @override
  void dispose() {
    super.dispose();
    _animationController!.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 450));
  }

  void _handleOnPressed() {
    setState(() {
      opened = !opened;
      opened
          ? _animationController!.forward()
          : _animationController!.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double _width = MediaQuery.of(context).size.width;
    final double _height = MediaQuery.of(context).size.height;
    final double _fabPosition = 16;
    final double _fabSize = 56;

    final double _xScale =
        (widget.scaleWidth + _fabPosition * 2) * 100 / _width;
    final double _yScale =
        (widget.scaleHeight + _fabPosition * 2) * 100 / _height;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _handleOnPressed(),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                // iconSize: 50,
                icon: AnimatedIcon(
                  icon: AnimatedIcons.menu_close,
                  progress: _animationController!,
                ),
                onPressed: null,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            color: AppThemes.logoBackground,
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: _fabSize + _fabPosition * 4,
                  right: _fabPosition,
                  // width is used as max width to prevent overlap
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: widget.scaleWidth),
                    child: widget.columnWidget,
                  ),
                ),
                Positioned(
                  right: widget.scaleWidth + _fabPosition * 2,
                  bottom: _fabPosition * 1.5,
                  // height is used as max height to prevent overlap
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: widget.scaleHeight - _fabPosition,
                    ),
                    child: widget.bottomWidget,
                  ),
                ),
              ],
            ),
          ),
          SlideAnimation(
            opened: opened,
            xScale: _xScale,
            yScale: _yScale,
            duration: widget.slideAnimationDuration,
            child: widget.foregroundWidget,
          ),
        ],
      ),
    );
  }
}

/// [opened] is a flag for forwarding or reversing the animation.
/// you can change the animation curves as you like, but you might need to
/// pay a close attention to [xScale] and [yScale], as they're setting
/// the end values of the animation tween.
class SlideAnimation extends StatefulWidget {
  final Widget child;
  final bool opened;
  final double xScale;
  final double yScale;
  final Duration duration;
  final Curve openAnimationCurve;
  final Curve closeAnimationCurve;

  const SlideAnimation({
    Key? key,
    required this.child,
    this.opened = false,
    required this.xScale,
    required this.yScale,
    required this.duration,
    this.openAnimationCurve = const ElasticOutCurve(0.9),
    this.closeAnimationCurve = const ElasticInCurve(0.9),
  }) : super(key: key);

  @override
  _SlideState createState() => _SlideState();
}

class _SlideState extends State<SlideAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> offset;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    offset = Tween<Offset>(
      begin: Offset(0.0, 0.0),
      end: Offset(-widget.xScale * 0.01, -widget.yScale * 0.01),
    ).animate(
      CurvedAnimation(
        curve: Interval(
          0,
          1,
          curve: widget.openAnimationCurve,
        ),
        reverseCurve: Interval(
          0,
          1,
          curve: widget.closeAnimationCurve,
        ),
        parent: _animationController,
      ),
    );

    super.initState();
  }

  @override
  void didUpdateWidget(SlideAnimation oldWidget) {
    widget.opened
        ? _animationController.forward()
        : _animationController.reverse();

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: offset,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

// /// Used to rotate the [FAB], it will not be called when [animateButton] is false
// /// [opened] is a flag for forwarding or reversing the animation.
// class RotateAnimation extends StatefulWidget {
//   final Widget child;
//   final bool opened;
//   final Duration duration;
//
//   const RotateAnimation({
//     Key? key,
//     required this.child,
//     this.opened = false,
//     required this.duration,
//   }) : super(key: key);
//
//   // @override
//   // _RotateState createState() => _RotateState();
// }

// class _RotateState extends State<RotateAnimation>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> rotate;
//
//   @override
//   void initState() {
//     _animationController = AnimationController(
//       vsync: this,
//       duration: widget.duration,
//     );
//
//     rotate = Tween(
//       begin: 0.0,
//       end: 0.12,
//     ).animate(
//       CurvedAnimation(
//         curve: Interval(
//           0,
//           1,
//           curve: Curves.easeIn,
//         ),
//         reverseCurve: Interval(
//           0,
//           1,
//           curve: Curves.easeIn.flipped,
//         ),
//         parent: _animationController,
//       ),
//     );
//
//     super.initState();
//   }
//
//   @override
//   void didUpdateWidget(RotateAnimation oldWidget) {
//     widget.opened
//         ? _animationController.forward()
//         : _animationController.reverse();
//
//     super.didUpdateWidget(oldWidget);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return RotationTransition(
//       turns: rotate,
//       child: widget.child,
//     );
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
// }

// List<Widget> _getMenuViews() {
//   return [
//     Container(),
//     Text('hi')
//   ]; //[YourCustomViews1Here(), YourCustomViews2Here()];
// }
//
// List<Widget> _getMenuItems() {
//   return [
//     Container(),
//     Text('hi2')
//   ]; //[MyCustomItem1Here(), MyCustomItem2Here()]
// }
// }
//
// class MenuValues {
//   const MenuValues({required this.icon, this.title, this.items, this.color});
//   final IconData icon;
//   final String? title;
//   final Color? color;
//   final List<MenuValues>? items;
// }
//
// const myMenuValue = const [
//   MenuValues(icon: Icons.close),
//   MenuValues(
//     icon: Icons.music_note_rounded,
//     title: 'Music',
//     items: const [
//       MenuValues(
//           icon: Icons.music_note, title: 'Songs', color: Color(0xFF5863F8)),
//       MenuValues(
//           icon: Icons.play_arrow,
//           title: 'Now Playing',
//           color: Color(0xFFFF3366)),
//       MenuValues(icon: Icons.album, title: 'Albums', color: Color(0xFFFFE433)),
//     ],
//   ),
//   MenuValues(
//     icon: Icons.phone_bluetooth_speaker_rounded,
//     title: 'Calls',
//     items: const [
//       MenuValues(
//           icon: Icons.phone_callback_rounded,
//           title: 'Incoming',
//           color: Color(0xFF2CDA9D)),
//       MenuValues(
//           icon: Icons.phone_missed_rounded,
//           title: 'Missing',
//           color: Color(0xFF7678ED)),
//       MenuValues(
//           icon: Icons.phone_disabled_rounded,
//           title: 'Outgoing ',
//           color: Color(0xFF446DF6)),
//     ],
//   ),
//   MenuValues(
//     icon: Icons.cloud,
//     title: 'Cloud',
//     items: const [
//       MenuValues(
//           icon: Icons.download_rounded,
//           title: 'Downloading',
//           color: Color(0xFFFF4669)),
//       MenuValues(
//           icon: Icons.upload_file, title: 'Done', color: Color(0xFFFF69EB)),
//       MenuValues(
//           icon: Icons.cloud_upload, title: 'Upload', color: Color(0xFF2CDA9D)),
//     ],
//   ),
//   MenuValues(
//     icon: Icons.wifi,
//     title: 'Wifi',
//     items: const [
//       MenuValues(
//           icon: Icons.wifi_off_rounded, title: 'Off', color: Color(0xFF5AD2F4)),
//       MenuValues(
//           icon: Icons.signal_wifi_4_bar_lock_sharp,
//           title: 'Lock',
//           color: Color(0xFFFF3366)),
//       MenuValues(
//           icon: Icons.perm_scan_wifi_rounded,
//           title: 'Limit',
//           color: Color(0xFFFFC07F)),
//     ],
//   ),
//   MenuValues(
//     icon: Icons.favorite,
//     title: 'Favorites',
//     items: const [
//       MenuValues(
//           icon: Icons.favorite, title: 'Favorite', color: Color(0xFF5863F8)),
//       MenuValues(
//           icon: Icons.favorite_border,
//           title: 'Not Favorite',
//           color: Color(0xFFF7C548)),
//       MenuValues(
//           icon: Icons.volunteer_activism,
//           title: 'Activism',
//           color: Color(0xFF00A878)),
//     ],
//   ),
//   MenuValues(
//     icon: Icons.network_cell,
//     title: 'Networks',
//     items: const [
//       MenuValues(icon: Icons.wifi, title: 'Wifi', color: Color(0xFF96858F)),
//       MenuValues(
//           icon: Icons.network_cell, title: 'Network', color: Color(0xFF6D7993)),
//       MenuValues(
//           icon: Icons.bluetooth, title: 'Bluetooth', color: Color(0xFF9099A2)),
//     ],
//   ),
// ];
