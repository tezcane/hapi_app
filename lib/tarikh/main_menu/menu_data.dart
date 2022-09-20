import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_asset.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';

/// Data container loaded in [TarikhMenuInitHandler.loadFromBundle()].
class MenuSectionData {
  MenuSectionData(
    this.trKeyEndTagLabel,
    this.textColor,
    this.backgroundColor,
    this.assetId,
    this.items,
  );

  final String trKeyEndTagLabel;
  final Color textColor;
  final Color backgroundColor;
  final String assetId;
  final List<MenuItemData> items;
}

/// Data container for all the sub-elements of the [MenuSection].
class MenuItemData {
  MenuItemData(this.trKeyEndTagLabel, this.startMs, this.endMs);
  final String trKeyEndTagLabel;
  final double startMs;
  final double endMs;

  bool pad = false;
  double padTop = 0.0;
//double padBottom = 0.0; // not used, always 0

  String get trValTitle => Event.trValFromTrKeyEndTag(trKeyEndTagLabel);

  /// When initializing this object from a [Event], fill in the
  /// fields according to the [event] provided. The event in fact specifies
  /// a [trKeyEndTagLabel], a [startMs] and [endMs] times.
  /// Padding is built depending on the type of the [event] provided.
  static MenuItemData fromEvent(Event event) {
    // put in timer so btns updates after navigation
    Timer(const Duration(milliseconds: 500), () {
      TarikhC.to.updateEventBtn(TarikhC.to.timeBtnUp, event.previous);
      TarikhC.to.updateEventBtn(TarikhC.to.timeBtnDn, event.next);
    });

    /// Pad the edges of the screen.
    bool pad = true;
    EventAsset asset = event.asset;

    /// Extra padding for the top base don the asset size.
    double padTop = asset.height * Timeline.AssetScreenScale;
    if (asset is AnimatedEventAsset) padTop += asset.gap;

    double start = 0;
    double end = 0;
    if (event.type == EVENT_TYPE.Era) {
      start = event.startMs;
      end = event.endMs;
    } else {
      /// No need to pad here as we are centering on a single item.
      double rangeBefore = double.maxFinite;
      for (Event? prev = event.previous; prev != null; prev = prev.previous) {
        double diff = event.startMs - prev.startMs;
        if (diff > 0.0) {
          rangeBefore = diff;
          break;
        }
      }

      double rangeAfter = double.maxFinite;
      for (Event? next = event.next; next != null; next = next.next!) {
        double diff = next.startMs - event.startMs;
        if (diff > 0.0) {
          rangeAfter = diff;
          break;
        }
      }
      double range = min(rangeBefore, rangeAfter) / 2.0;
      start = event.startMs;
      end = event.endMs + range;
    }

    var menuItemData = MenuItemData(event.trKeyEndTagLabel, start, end);
    menuItemData.pad = pad;
    menuItemData.padTop = padTop;

    return menuItemData;
  }
}
