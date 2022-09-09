// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';

/// An entire tab (tab and tile labels, relics, filters, etc.). Uses the
/// RelicSet object found in relic.dart.
// ignore: must_be_immutable
class RelicSetUI extends StatelessWidget {
  RelicSetUI(this.relicSet) {
    relicSetFilters = relicSet.filterList; // needs init separately

    updateRelicSetFilter(RelicC.to.getRelicSetFilterIdx(relicSet.relicType));
  }
  final RelicSet relicSet;

  late final List<RelicSetFilter> relicSetFilters;

  late RelicSetFilter filter;
  int filterIdx = -1; // -1 forces update/rd/wr on next access (init)

  // We need RelicSetFilter info to populate tpr (Tiles Per Row) variable.
  // tpr values can only be 1-11 and are used for several calculations and to
  // size the relic tiles/images appropriately based on filter needs. We call it
  // tpr instead of tilesPerRow because it is more than tilesPerRow so we make
  // it ambiguously as it is more of concept of two things. There are two other
  // tpr values found here too: RelicSetFilter.tprMin()/tprMax().
  late int tpr;
  late bool showTileText;

  updateRelicSetFilter(int newIdx) {
    if (newIdx == filterIdx) return; // no need to do work, return
    filterIdx = newIdx;

    filter = relicSetFilters[filterIdx];
    tpr = RelicC.to.getTilesPerRow(relicSet.relicType, filterIdx);

    showTileText = RelicC.to.getShowTileText(relicSet.relicType);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filter.type == FILTER_TYPE.Default) _tileHeaderDefault(context),
          const SizedBox(height: 8),
          if (filter.type == FILTER_TYPE.Default) _tileListDefault(context),
          const SizedBox(height: 9),
        ],
      ),
    );
  }

  Widget _tileHeaderDefault(BuildContext context) {
    // width of extra spaces between 65-155: 65 (10+10+45) + 90 (45+45)
    final double wText = w(context) - 65 - (filter.isResizeable ? 90 : 0);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const SizedBox(width: 10),
            T(
              filter.trValLabel,
              tsNB,
              w: wText,
              trVal: true,
              alignment: LanguageC.to.centerLeft, // to match big/small labels
            ),
            const SizedBox(width: 10),
          ]),
          Row(
            children: [
              if (filter.isResizeable) _btnGroupRemoveAdd(),
              InkWell(
                onTap: () {
                  showTileText = !showTileText;
                  RelicC.to.setShowTileText(relicSet.relicType, showTileText);
                },
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    showTileText
                        ? Icons.expand_less_outlined
                        : Icons.expand_more_outlined,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _btnGroupRemoveAdd() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (tpr < filter.tprMax) {
              tpr += 1;
              RelicC.to.setTilesPerRow(relicSet.relicType, filterIdx, tpr);
            }
          },
          child: SizedBox(
            width: 45,
            height: 45,
            child: Icon(
              Icons.remove,
              size: 25,
              color: tpr == filter.tprMax ? AppThemes.unselected : null,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (tpr > filter.tprMin) {
              tpr -= 1;
              RelicC.to.setTilesPerRow(relicSet.relicType, filterIdx, tpr);
            }
          },
          child: SizedBox(
            width: 45,
            height: 45,
            child: Icon(
              Icons.add,
              size: 25,
              color: tpr == filter.tprMin ? AppThemes.unselected : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tileListDefault(BuildContext context) {
    return Wrap(
      // direction: Axis.horizontal <-- TODO use this for landscape/portrait mode?
      alignment: WrapAlignment.center, // TY!, centers modules remainders
      spacing: 4, // NOTE: must subtract this from _relicTile() or overflows
      runSpacing: showTileText ? 6 : 2.5, // gap under a row of tiles
      children: List.generate(
        relicSet.relics.length,
        (index) {
          return _relicTile(context, relicSet.relics[index]);
        },
      ),
    );
  }

  Widget _relicTile(BuildContext context, Relic relic) {
    final double wTile = w(context) / tpr - 4; // -4 for Wrap.spacing!

    // when tiles get tiny we force huge height to take up all width
    final double hText = 35 - (tpr.toDouble() * 2); // h size: 13-33
    final double hTile = wTile + (showTileText ? hText : 0);

    return SizedBox(
      width: wTile,
      height: hTile,
      child: Column(
        children: [
          Container(
            // color: AppThemes.ajrColorsByIdx[Random().nextInt(7)],
            color: AppThemes.ajrColorsByIdx[relic.ajrLevel],
            child: SizedBox(
              width: wTile,
              height: wTile,
              child: Image(
                image: AssetImage(relic.asset.filename),
                fit: BoxFit.fill,
              ),
            ),
          ),
          if (showTileText) T(relic.trValTitle, tsN, w: wTile, h: hText),
        ],
      ),
    );
  }
}
