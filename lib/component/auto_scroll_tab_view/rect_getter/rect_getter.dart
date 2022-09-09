import 'package:flutter/material.dart';

/// Get a widget's real-time rectangle information from inside a UI list.
class RectGetter extends StatefulWidget {
  /// Constructor with key passed to get child rect by using getRectFromKey()
  const RectGetter({required this.key, required this.child}) : super(key: key);
  // ignore: annotate_overrides, overridden_fields
  final GlobalKey<RectGetterState> key;
  final Widget child;

  /// Static method to get child's rectangle information from custom GlobalKey
  static Rect? getRectFromKey(GlobalKey<RectGetterState> globalKey) {
    RenderObject? object = globalKey.currentContext?.findRenderObject();
    var vector3 = object?.getTransformTo(null).getTranslation();
    Size? size = object?.semanticBounds.size;

    if (vector3 != null && size != null) {
      return Rect.fromLTWH(vector3.x, vector3.y, size.width, size.height);
    } else {
      return null;
    }
  }

  /// Constructor that uses object itself's getRect() method to get child rect
  factory RectGetter.defaultKey({required Widget child}) =>
      RectGetter(key: GlobalKey(), child: child);

  /// Get RectGetter.defaultKey() constructor style Rect back.
  Rect? getRect() => getRectFromKey(key);

  /// Creates a custom GlobalKey, use to avoid type exception in dart2.
  static GlobalKey<RectGetterState> createGlobalKey() =>
      GlobalKey<RectGetterState>();

  @override
  RectGetterState createState() => RectGetterState();
}

class RectGetterState extends State<RectGetter> {
  @override
  Widget build(BuildContext context) => widget.child;
}
