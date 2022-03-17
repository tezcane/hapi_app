import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// Data container loaded in [TarikhMenuInitHandler.loadFromBundle()].
class MenuSectionData {
  MenuSectionData(
    this.label,
    this.textColor,
    this.backgroundColor,
    this.assetId,
    this.items,
  );

  final String label;
  final Color textColor;
  final Color backgroundColor;
  final String assetId;
  final List<MenuItemData> items;
}

/// Data container for all the sub-elements of the [MenuSection].
class MenuItemData {
  MenuItemData(this.label, this.startMs, this.endMs);

  final String label;
  final double startMs;
  final double endMs;

  bool pad = false;
  double padTop = 0.0;
//double padBottom = 0.0; // not used, always 0

  /// When initializing this object from a [TimelineEntry], fill in the
  /// fields according to the [entry] provided. The entry in fact specifies
  /// a [label], a [startMs] and [endMs] times.
  /// Padding is built depending on the type of the [entry] provided.
  static MenuItemData fromEntry(TimelineEntry entry) {
    // put in timer so btns updates after navigation
    Timer(const Duration(milliseconds: 500), () {
      TarikhController c = TarikhController.to;
      c.updateTimeBtnEntry(c.timeBtnUp, entry.previous);
      c.updateTimeBtnEntry(c.timeBtnDn, entry.next);
    });

    String label = entry.label;

    /// Pad the edges of the screen.
    bool pad = true;
    TimelineAsset asset = entry.asset;

    /// Extra padding for the top base don the asset size.
    double padTop = asset.height * Timeline.AssetScreenScale;
    if (asset is TimelineAnimatedAsset) {
      padTop += asset.gap;
    }

    double start = 0;
    double end = 0;
    if (entry.type == TimelineEntryType.Era) {
      start = entry.startMs;
      end = entry.endMs;
    } else {
      /// No need to pad here as we are centering on a single item.
      double rangeBefore = double.maxFinite;
      for (TimelineEntry? prev = entry.previous;
          prev != null;
          prev = prev.previous) {
        double diff = entry.startMs - prev.startMs;
        if (diff > 0.0) {
          rangeBefore = diff;
          break;
        }
      }

      double rangeAfter = double.maxFinite;
      for (TimelineEntry? next = entry.next; next != null; next = next.next!) {
        double diff = next.startMs - entry.startMs;
        if (diff > 0.0) {
          rangeAfter = diff;
          break;
        }
      }
      double range = min(rangeBefore, rangeAfter) / 2.0;
      start = entry.startMs;
      end = entry.endMs + range;
    }

    var menuItemData = MenuItemData(label, start, end);
    menuItemData.pad = pad;
    menuItemData.padTop = padTop;

    return menuItemData;
  }
}
