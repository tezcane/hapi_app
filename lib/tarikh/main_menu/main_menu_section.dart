import 'package:flare_flutter/flare_actor.dart' as flare;
import 'package:flutter/material.dart';
import 'package:hapi/event/event.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/main_menu/menu_vignette.dart';

typedef NavigateTo = Function(MenuItemData item);

/// This widget displays the single menu section of the [MainMenuWidget].
///
/// There are three main sections, as loaded from the menu.json file in the
/// assets folder.
/// Each section has a backgroundColor, an accentColor, a background Flare asset,
/// and a list of elements it needs to display when expanded.
///
/// Since this widget expands and contracts when tapped, it needs to maintain a [State].
class MenuSection extends StatefulWidget {
  const MenuSection(
    this.tkTitle,
    this.backgroundColor,
    this.accentColor,
    this.menuItems,
    this.navigateTo,
    this.isActive,
    this.event,
  );
  final String tkTitle;
  final Color backgroundColor;
  final Color accentColor;
  final List<MenuItemData> menuItems;
  final NavigateTo navigateTo;
  final bool isActive;
  final Event event;

  @override
  State<StatefulWidget> createState() => _SectionState();
}

/// This [State] uses the [SingleTickerProviderStateMixin] to add [vsync] to it.
/// This allows the animation to run smoothly and avoids consuming unnecessary resources.
class _SectionState extends State<MenuSection>
    with SingleTickerProviderStateMixin {
  /// The [AnimationController] is a Flutter Animation object that generates a new value
  /// whenever the hardware is ready to draw a new frame.
  AnimationController? _controller;

  /// Since the above object interpolates only between 0 and 1, but we'd rather apply a curve to the current
  /// animation, we're providing a custom [Tween] that allows to build more advanced animations, as seen in [initState()].
  static final Animatable<double> _sizeTween = Tween<double>(
    begin: 0.0,
    end: 1.0,
  );

  /// The [Animation] object itself, which is required by the [SizeTransition] widget in the [build()] method.
  Animation<double>? _sizeAnimation;

  /// Detects which state the widget is currently in, and triggers the animation upon change.
  bool _isExpanded = false;

  /// Here we initialize the fields described above, and set up the widget to its initial state.
  @override
  initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    /// This curve is controlled by [_controller].
    final CurvedAnimation curve =
        CurvedAnimation(parent: _controller!, curve: Curves.fastOutSlowIn);

    /// [_sizeAnimation] will interpolate using this curve - [Curves.fastOutSlowIn].
    _sizeAnimation = _sizeTween.animate(curve);
    _controller!.addListener(() => setState(() {}));
  }

  @override
  dispose() {
    _controller!.dispose();
    super.dispose();
  }

  /// Whenever a tap is detected, toggle a change in the state and move the animation forward
  /// or backwards depending on the initial status.
  _toggleExpand() {
    setState(() => _isExpanded = !_isExpanded);
    switch (_sizeAnimation!.status) {
      case AnimationStatus.completed:
        _controller!.reverse();
        break;
      case AnimationStatus.dismissed:
        _controller!.forward();
        break;
      case AnimationStatus.reverse:
      case AnimationStatus.forward:
        break;
    }
  }

  /// This method wraps the whole widget in a [GestureDetector] to handle taps appropriately.
  ///
  /// A custom [BoxDecoration] is used to render the rounded rectangle on the screen, and a
  /// [MenuVignette] is used as a background decoration for the whole widget.
  ///
  /// The [SizeTransition] opens up the section and displays the list underneath the section title.
  ///
  /// Each section sub-element is wrapped into a [GestureDetector] too so that the Timeline can be displayed
  /// when that element is tapped.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpand,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: widget.backgroundColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                left: 0,
                top: 0,
                child: MenuVignette(
                  needsRepaint: true,
                  gradientColor: widget.backgroundColor,
                  isActive: widget.isActive,
                  event: widget.event,
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    height: 150.0, // TODO tune height of each vignette
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 21.0,
                          width: 21.0,
                          margin: const EdgeInsets.all(18.0),

                          /// Another [FlareActor] widget that
                          /// you can experiment with here: https://www.2dimensions.com/a/pollux/files/flare/expandcollapse/preview
                          child: flare.FlareActor(
                            'assets/tarikh/flare/ExpandCollapse.flr',
                            color: widget.accentColor,
                            animation: _isExpanded ? 'Collapse' : 'Expand',
                          ),
                        ),
                        Text(
                          a(widget.tkTitle),
                          style: TextStyle(
                            fontSize: 20.0,
                            // TODO fix arabic font size
                            // fontFamily: 'Kitab',
                            fontFamily: 'RobotoMedium',
                            color: widget.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizeTransition(
                    axisAlignment: 0.0,
                    axis: Axis.vertical,
                    sizeFactor: _sizeAnimation!,
                    child: Padding(
                      //TODO RTL ok?
                      padding: const EdgeInsets.only(
                          left: 56.0, right: 20.0, top: 10.0),
                      child: Column(
                        children: widget.menuItems.map((item) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => widget.navigateTo(item),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 20.0),
                                    child: Text(
                                      a(item.tkTitle),
                                      style: TextStyle(
                                        color: widget.accentColor,
                                        fontSize: 20.0,
                                        // TODO fix arabic font size
                                        // fontFamily: 'Kitab',
                                        fontFamily: 'RobotoMedium',
                                      ),
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  color: widget.accentColor,
                                  size: 20,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
