import 'package:flutter/material.dart';

/// Use this widget to get a widget`s rectangle information in real-time .
/// It has 2 constructors, pass a GlobalKey or use default key, and then
/// you can use the key or object itself to get info.

class RectGetter extends StatefulWidget {
  // ignore: annotate_overrides, overridden_fields
  final GlobalKey<RectGetterState> key;
  final Widget child;

  /// Use this static method to get child`s rectangle information when had a custom GlobalKey
  static Rect? getRectFromKey(GlobalKey<RectGetterState> globalKey) {
    var object = globalKey.currentContext?.findRenderObject();
    var translation = object?.getTransformTo(null).getTranslation();
    var size = object?.semanticBounds.size;

    if (translation != null && size != null) {
      return Rect.fromLTWH(
          translation.x, translation.y, size.width, size.height);
    } else {
      return null;
    }
  }

  /// create a custom GlobalKey , use this way to avoid type exception in dart2 .
  static GlobalKey<RectGetterState> createGlobalKey() {
    return GlobalKey<RectGetterState>();
  }

  /// constructor with key passed, and then you can get child`s rect by using RectGetter.getRectFromKey(key)
  const RectGetter({required this.key, required this.child}) : super(key: key);

  /// Use defaultKey to build RectGetter, and then use object itself`s getRect() method to get child`s rect
  factory RectGetter.defaultKey({required Widget child}) {
    return RectGetter(key: GlobalKey(), child: child);
  }

  Rect? getRect() => getRectFromKey(key);

  /// make a clone with different GlobalKey
  RectGetter clone() {
    return RectGetter.defaultKey(child: child);
  }

  @override
  RectGetterState createState() => RectGetterState();
}

class RectGetterState extends State<RectGetter> {
  @override
  Widget build(BuildContext context) => widget.child;
}
