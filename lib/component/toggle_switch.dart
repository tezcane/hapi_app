import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';

typedef OnToggle = void Function(int index);

// ignore: must_be_immutable
class ToggleSwitch extends StatefulWidget {
  /// Active background color
  final Color? activeBgColor;

  /// Active foreground color
  final Color? activeFgColor;

  /// Inactive background color
  final Color? inactiveBgColor;

  /// Inactive foreground color
  final Color? inactiveFgColor;

  /// List of labels that are trVal labels (should come in already translated)
  final List<String> trValLabels;

  /// List of icons
  final List<IconData>? icons;

  /// List of active foreground colors
  final List<Color>? activeBgColors;

  /// Minimum switch width
  final double minWidth;

  /// Minimum switch height
  final double minHeight;

  /// Widget's corner radius
  final double cornerRadius;

  /// Font size
  final double fontSize;

  /// Font weight
  final FontWeight fontWeight;

  /// Icon size
  final double iconSize;

  /// OnToggle function
  final OnToggle? onToggle;

  // Change selection on tap
  final bool changeOnTap;

  /// Initial label index
  int initialLabelIndex;

  ToggleSwitch({
    Key? key,
    required this.trValLabels,
    this.activeBgColor,
    this.activeFgColor,
    this.inactiveBgColor,
    this.inactiveFgColor,
    this.onToggle,
    this.cornerRadius = 8.0,
    this.initialLabelIndex = 0,
    this.minWidth = 72.0,
    this.minHeight = 40.0,
    this.changeOnTap = true,
    this.icons,
    this.activeBgColors,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.bold,
    this.iconSize = 17.0,
  }) : super(key: key);

  @override
  _ToggleSwitchState createState() => _ToggleSwitchState();
}

class _ToggleSwitchState extends State<ToggleSwitch>
    with AutomaticKeepAliveClientMixin<ToggleSwitch> {
  /// Active background color
  Color? activeBgColor;

  /// Active foreground color
  Color? activeFgColor;

  /// Inactive background color
  Color? inactiveBgColor;

  /// Inctive foreground color
  Color? inactiveFgColor;

  /// Maintain selection state.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// Assigns active background color to default primary theme color if it's null/not provided.
    activeBgColor = widget.activeBgColor ?? Theme.of(context).primaryColor;

    /// Assigns active foreground color to default accent text theme color if it's null/not provided.
    activeFgColor = widget.activeFgColor ??
        Theme.of(context).accentTextTheme.bodyText1!.color;

    /// Assigns inactive background color to default disabled theme color if it's null/not provided.
    inactiveBgColor = widget.inactiveBgColor ?? Theme.of(context).disabledColor;

    /// Assigns inactive foreground color to default text theme color if it's null/not provided.
    inactiveFgColor =
        widget.inactiveFgColor ?? Theme.of(context).textTheme.bodyText1!.color;

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.cornerRadius),
      child: Container(
        height: widget.minHeight,
        color: inactiveBgColor,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.trValLabels.length * 2 - 1, (index) {
            /// Active if index matches current
            final active = index ~/ 2 == widget.initialLabelIndex;

            /// Assigns foreground color based on active status.
            ///
            /// Sets active foreground color if current index is active.
            /// Sets inactive foreground color if current index is inactive.
            final fgColor = active ? activeFgColor : inactiveFgColor;

            /// Default background color
            Color? bgColor = Colors.transparent;

            /// Changes background color if current index is active.
            ///
            /// Sets same active background color for all items if active background colors list is empty.
            /// Sets different active background color for current item by matching index if active background colors list is not empty
            if (active) {
              bgColor = widget.activeBgColors == null
                  ? activeBgColor
                  : widget.activeBgColors![index ~/ 2];
            }

            if (index % 2 == 1) {
              final activeDivider =
                  active || index ~/ 2 == widget.initialLabelIndex - 1;

              /// Returns item divider
              return Container(
                width: 1,
                color: activeDivider ? bgColor : Colors.white30,
                margin: EdgeInsets.symmetric(vertical: activeDivider ? 0 : 8),
              );
            } else {
              /// Returns switch item
              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleOnTap(index ~/ 2),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    constraints: BoxConstraints(
                        maxWidth: _calculateWidth(widget.minWidth)),
                    alignment: Alignment.center,
                    color: bgColor,
                    child: widget.icons == null
                        ? T(
                            widget.trValLabels[index ~/ 2],
                            TextStyle(
                              color: fgColor,
                              fontSize: widget.fontSize,
                              fontWeight: widget.fontWeight,
                            ),
                            h: 16,
                            trVal: true,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                widget.icons![index ~/ 2],
                                color: fgColor,
                                size: widget.iconSize >
                                        (_calculateWidth(widget.minWidth) / 3)
                                    ? (_calculateWidth(widget.minWidth)) / 3
                                    : widget.iconSize,
                              ),
                              Flexible(
                                child: Container(
                                  //TODO RTL ok?
                                  padding: const EdgeInsets.only(left: 5),
                                  child: T(
                                    widget.trValLabels[index ~/ 2],
                                    TextStyle(
                                      color: fgColor,
                                      fontSize: widget.fontSize,
                                      fontWeight: widget.fontWeight,
                                    ),
                                    h: 16,
                                    trVal: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }
          }),
        ),
      ),
    );
  }

  /// Handles selection
  void _handleOnTap(int index) async {
    if (widget.changeOnTap) {
      setState(() => widget.initialLabelIndex = index);
    }
    if (widget.onToggle != null) {
      widget.onToggle!(index);
    }
  }

  /// Calculates width to prevent overflow by taking screen width into account.
  double _calculateWidth(double minWidth) {
    /// Total number of labels/switches
    int totalLabels = widget.trValLabels.length;

    /// Extra width to prevent overflow and add padding
    double extraWidth = 0.10 * totalLabels;

    /// Max screen width
    double screenWidth = MediaQuery.of(context).size.width;

    /// Returns width per label
    ///
    /// Returns passed minWidth per label if total requested width plus extra width is less than max screen width.
    /// Returns calculated width to fit within the max screen width if total requested width plus extra width is more than max screen width.
    return (totalLabels + extraWidth) * widget.minWidth < screenWidth
        ? widget.minWidth
        : screenWidth / (totalLabels + extraWidth);
  }
}
