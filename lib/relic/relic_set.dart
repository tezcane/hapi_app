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

class RelicSetUI extends StatelessWidget {
  const RelicSetUI(this.relicSet);
  final RelicSet relicSet;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _relicTileHeader(context),
          const SizedBox(height: 10),
          _relicTileList(context),
          const SizedBox(height: 5),
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
                  int tpr = RelicController.to.getTilesPerRow(relicType);
                  if (tpr < 11) tpr += 1;
                  RelicController.to.setTilesPerRow(relicType, tpr);
                },
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.remove,
                    size: 25,
                    color: RelicController.to.getTilesPerRow(relicType) > 10
                        ? AppThemes.unselected
                        : null,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  int tpr = RelicController.to.getTilesPerRow(relicType);
                  if (tpr > 1) tpr -= 1;
                  RelicController.to.setTilesPerRow(relicType, tpr);
                },
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    Icons.add,
                    size: 25,
                    color: RelicController.to.getTilesPerRow(relicType) < 2
                        ? AppThemes.unselected
                        : null,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  RELIC_TYPE relicType = relicSet.relicType;
                  RelicController.to.toggleShowTileHeader(relicType);
                },
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    RelicController.to.getShowTileHeader(relicType)
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
      spacing: 4, // NOTE must subtract this from _relicTile() or overflows
      runSpacing: 6, // gap under a row of tiles
      children: List.generate(
        relicSet.relics.length,
        (index) {
          Relic relic = relicSet.relics[index];
          int tilesPerRow = RelicController.to.getTilesPerRow(relic.relicType);
          return _relicTile(
            context: context,
            relic: relic,
            tilesPerRow: tilesPerRow,
            //isLastIndex: index == relicSet.relics.length - 1,
          );
        },
      ),
    );
  }

  Widget _relicTile({
    required BuildContext context,
    required Relic relic,
    required int tilesPerRow,
    //required bool isLastIndex,
  }) {
    final bool showTileHeader =
        RelicController.to.getShowTileHeader(relic.relicType);

    final double wTile = w(context) / tilesPerRow - 4; //-4 for Wrap.spacing

    // when tiles get tiny we force huge height to take up all width
    final double hLabel = tilesPerRow > 6 ? wTile * .45 : wTile * .25;
    final double hTile = wTile + (showTileHeader ? hLabel : 0);

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
          if (showTileHeader)
            SizedBox(
              width: wTile,
              height: hLabel,
              child: T(
                relic.trValTitle,
                tsN,
                w: wTile,
                h: hLabel,
                alignment: Alignment.topCenter,
              ),
            ),
        ],
      ),
    );
  }
}
