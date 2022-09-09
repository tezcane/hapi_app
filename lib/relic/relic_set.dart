// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_controller.dart';

class RelicSet<Relic> {
  const RelicSet({
    required this.relicType,
    required this.trKeyTitle,
    required this.trValSubtitle,
    required this.relics,
  });
  final RELIC_TYPE relicType;
  final String trKeyTitle;
  final String trValSubtitle;
  final List<Relic> relics;
}

// ignore: must_be_immutable
class RelicSetUI extends StatelessWidget {
  RelicSetUI(this.relicSet) {
    tilesPerRow = RelicController.to.getTilesPerRow(relicSet.relicType);
    showTileText = RelicController.to.getShowTileText(relicSet.relicType);
  }
  final RelicSet relicSet;

  int tilesPerRow = 5; // value can only be 1-11, used for several calculations
  bool showTileText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _relicTileHeader(context),
          const SizedBox(height: 8),
          _relicTileList(context),
          const SizedBox(height: 9),
        ],
      ),
    );
  }

  Widget _relicTileHeader(BuildContext context) {
    double wText = w(context) - 155; // 155 = 10 + 10 + 45 + 45 + 45
    RELIC_TYPE relicType = relicSet.relicType;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const SizedBox(width: 10),
            T(relicSet.trValSubtitle, tsNB, w: wText, trVal: true),
            const SizedBox(width: 10),
          ]),
          Row(
            children: [
              InkWell(
                onTap: () {
                  RELIC_TYPE relicType = relicSet.relicType;
                  if (tilesPerRow < 11) {
                    tilesPerRow += 1;
                    RelicController.to.setTilesPerRow(relicType, tilesPerRow);
                  }
                },
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.remove,
                    size: 25,
                    color: tilesPerRow > 10 ? AppThemes.unselected : null,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (tilesPerRow > 1) {
                    tilesPerRow -= 1;
                    RelicController.to.setTilesPerRow(relicType, tilesPerRow);
                  }
                },
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.add,
                    size: 25,
                    color: tilesPerRow < 2 ? AppThemes.unselected : null,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  RELIC_TYPE relicType = relicSet.relicType;
                  showTileText = !showTileText;
                  RelicController.to.setShowTileText(relicType, showTileText);
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

  Widget _relicTileList(BuildContext context) {
    return Wrap(
      // direction: Axis.horizontal <-- TODO use this for landscape/portrait mode?
      alignment: WrapAlignment.center, // TY!, centers modules remainders
      spacing: 4, // NOTE: must subtract this from _relicTile() or overflows
      runSpacing: showTileText ? 6 : 2.5, // gap under a row of tiles
      children: List.generate(
        relicSet.relics.length,
        (index) {
          Relic relic = relicSet.relics[index];
          return _relicTile(context: context, relic: relic);
        },
      ),
    );
  }

  Widget _relicTile({required BuildContext context, required Relic relic}) {
    final double wTile = w(context) / tilesPerRow - 4; // -4 for Wrap.spacing!

    // when tiles get tiny we force huge height to take up all width
    final double hText = 35 - (tilesPerRow.toDouble() * 2); // h size: 13-33
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
