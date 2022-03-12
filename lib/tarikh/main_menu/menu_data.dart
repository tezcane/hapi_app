import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import "package:flutter/services.dart" show rootBundle;
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// Data container for the Section loaded in [MenuData.loadFromBundle()].
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
  MenuItemData(this.label, this.start, this.end);

  final String label;
  final double start;
  final double end;

  bool pad = false;
  double padTop = 0.0;
//double padBottom = 0.0; // not used, always 0

  /// When initializing this object from a [TimelineEntry], fill in the
  /// fields according to the [entry] provided. The entry in fact specifies
  /// a [label], a [start] and [end] times.
  /// Padding is built depending on the type of the [entry] provided.
  static MenuItemData fromEntry(TimelineEntry entry) {
    // put in timer so btns updates after navigation
    Timer(const Duration(milliseconds: 500), () {
      TarikhController.to
          .setTBtnUp(TarikhController.to.getTimeBtn(entry.previous, 1.0));
      TarikhController.to
          .setTBtnDn(TarikhController.to.getTimeBtn(entry.next, 1.0));
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

/// This class has the sole purpose of loading the resources from storage and
/// de-serializing the JSON file appropriately.
///
/// `menu.json` contains an array of objects, each with:
/// * label - the title for the section
/// * background - the color on the section background
/// * color - the accent color for the menu section
/// * asset - the background Flare/Nima asset id that will play the section background
/// * items - an array of elements providing each the start and end times for that link
/// as well as the label to display in the [MenuSection].
class MenuData {
  final List<MenuSectionData> _menuSectionList = [];

  get menuSectionDataList => _menuSectionList;

  Future<bool> loadFromBundle(String filename) async {
    String jsonData = await rootBundle.loadString(filename);
    List jsonEntries = json.decode(jsonData);

    List<MenuItemData> menuItemList;
    for (Map map in jsonEntries) {
      menuItemList = [];

      var label = map["label"] as String;
      var textColor = Color(
          int.parse((map["color"] as String).substring(1, 7), radix: 16) +
              0xFF000000);
      var backgroundColor = Color(
          int.parse((map["background"] as String).substring(1, 7), radix: 16) +
              0xFF000000);
      var assetId = map["asset"] as String;

      for (Map itemMap in map["items"]) {
        var label = itemMap["label"] as String;

        dynamic startVal = itemMap["start"];
        double start = startVal is int ? startVal.toDouble() : startVal;

        dynamic endVal = itemMap["end"];
        double end = endVal is int ? endVal.toDouble() : endVal;

        menuItemList.add(MenuItemData(label, start, end));
      }

      menuSectionDataList.add(MenuSectionData(
          label, textColor, backgroundColor, assetId, menuItemList));
    }

    return true;
  }
}
