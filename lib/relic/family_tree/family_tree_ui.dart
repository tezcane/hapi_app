import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart';
import 'package:graphview/GraphView.dart' as graph_view;
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/relic/ummah/prophet.dart'; // TODO remove need for this?

/// Shows a Family Tree SubPage.
class FamilyTreeUI extends StatelessWidget {
  FamilyTreeUI() {
    graph = Get.arguments['graph'];
    relicType = Get.arguments['relicType'];
    relicSet = RelicC.to.getRelicSet(relicType);
    relics = relicSet.relics;
    maxRelicIdx = relics.length - 1;
  }
  late final Graph graph;
  late final RELIC_TYPE relicType;
  late final RelicSet relicSet;
  late final List<Relic> relics;
  late final int maxRelicIdx;

  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration()
    ..siblingSeparation = (10)
    ..levelSeparation = (40)
    ..subtreeSeparation = (10)
    ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

  @override
  Widget build(BuildContext context) {
    return FabSubPage(
      subPage: SubPage.Family_Tree,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: InteractiveViewer(
                constrained: false,
                boundaryMargin: const EdgeInsets.all(20),
                // minScale: 0.01,
                // maxScale: 5.6,
                child: GraphView(
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                    builder,
                    TreeEdgeRenderer(builder),
                  ),
                  paint: Paint()
                    ..color = Colors.green
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                  builder: (graph_view.Node node) {
                    int tpr = 5;
                    final double wTile =
                        w(context) / tpr - 4; // -4 for Wrap.spacing!
                    final double hText =
                        35 - (tpr.toDouble() * 2); // h size: 13-33
                    final double hTile = wTile + hText;

                    int relicIdx = node.key!.value;
                    return relicIdx > maxRelicIdx
                        ? rectangleWidget(
                            context,
                            relicIdx,
                            wTile,
                            hTile,
                            hText,
                          )
                        : _relicTileWithField(
                            context,
                            relics[relicIdx],
                            wTile,
                            hTile,
                            hText,
                          );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _relicTileWithField(
    BuildContext context,
    Relic relic,
    double wTile,
    double hTile,
    double hText,
  ) {
    return InkWell(
      onTap: () => print('TODO clicked 2'), // TODO
      child: SizedBox(
        width: wTile,
        height: hTile,
        child: Column(
          children: [
            Container(
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
            T(relic.trValTitle, tsN, w: wTile, h: hText),
          ],
        ),
      ),
    );
  }

  Widget rectangleWidget(
    BuildContext context,
    int relicIdx,
    double wTile,
    double hTile,
    double hText,
  ) {
    return InkWell(
      onTap: () => print('TODO clicked'), // TODO
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).scaffoldBackgroundColor,
              spreadRadius: 1,
            ),
          ],
        ),
//      child: T('$relicIdx ${PF.values[relicIdx].name}', tsN, w: wTile, h: hText),
        child: T(PF.values[relicIdx].name, tsN, w: wTile, h: hText),
      ),
    );
  }
}
