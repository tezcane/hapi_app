import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart';
import 'package:graphview/GraphView.dart' as graph_view;
import 'package:hapi/event/et.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/relic/al_asma/nabi.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/relic/relic_set_ui.dart';

/// Shows a Family Tree SubPage.
// ignore: must_be_immutable
class FamilyTreeUI extends StatelessWidget {
  FamilyTreeUI() {
    graph1 = Get.arguments['graph1']; // full
    graph2 = Get.arguments['graph2']; // OPTIONAL: condensed version of graph1
    et = Get.arguments['et'];
    relicSet = RelicC.to.getRelicSet(et);
    relics = relicSet.relics;
    maxRelicIdx = relics.length - 1;
    filterIdx = relicSet.filterList.length - 1; // Tree is at the last idx
  }
  late final Graph graph1;
  late final Graph? graph2;
  late final ET et;
  late final RelicSet relicSet;
  late final List<Relic> relics;
  late final int maxRelicIdx;
  late final int filterIdx;

  final BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration()
    ..siblingSeparation = (10)
    ..levelSeparation = (40)
    ..subtreeSeparation = (10)
    ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);

  bool showGraph1 = true;

  Widget getLegend(BuildContext context) {
    const double legendW = 310;
    const double textW = legendW - 30 - 10 - 20;
    return Directionality(
      textDirection: LangC.to.textDirection,
      child: Row(
        // mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: legendW,
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 30),
                    const T(
                      '|',
                      TextStyle(
                        // dummy to align title
                        color: Colors.transparent,
                        fontWeight: FontWeight.bold,
                      ),
                      w: 10,
                    ),
                    const SizedBox(width: 20),
                    T(
                      'p.LEGEND',
                      tsNB,
                      alignment: LangC.to.centerLeft,
                      w: textW,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const SizedBox(width: 30),
                    const T(
                      '|',
                      TextStyle(
                        color: AppThemes.COLOR_DIRECT_DESCENDANT,
                        fontWeight: FontWeight.bold,
                      ),
                      w: 10,
                    ),
                    const SizedBox(width: 20),
                    T(
                      'p.Direct Descendants',
                      tsN,
                      alignment: LangC.to.centerLeft,
                      w: textW,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const SizedBox(width: 30),
                    const T(
                      '|',
                      TextStyle(
                        color: AppThemes.COLOR_GENERATION_GAP,
                        fontWeight: FontWeight.normal,
                      ),
                      w: 10,
                    ),
                    const SizedBox(width: 20),
                    T(
                      'p.Generation Gap',
                      tsN,
                      alignment: LangC.to.centerLeft,
                      w: textW,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (graph2 != null) // don't show condense button if graph2 is null
            GestureDetector(
              onTap: () {
                showGraph1 = !showGraph1;
                RelicC.to.update();
              },
              child: SizedBox(
                width: 80,
                height: 50,
                child: Icon(
                  showGraph1
                      ? Icons.expand_less_outlined
                      : Icons.expand_more_outlined,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FabSubPage(
      subPage: SubPage.Family_Tree,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: .01,
                  maxScale: 3.5,
                  child: GetBuilder<RelicC>(
                    builder: (c) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        getLegend(context),
                        const SizedBox(height: 30),
                        GraphView(
                          graph: showGraph1 ? graph1 : graph2!,
                          algorithm: BuchheimWalkerAlgorithm(
                            builder,
                            TreeEdgeRenderer(builder),
                          ),
                          paint: Paint()
                            ..color = AppThemes.COLOR_DIRECT_DESCENDANT
                            ..strokeWidth = 3
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
                                : RelicSetUI.getRelicTile(
                                    context,
                                    relics[relicIdx],
                                    tpr,
                                    relicSet,
                                    filterIdx,
                                    true,
                                  );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        // TODO remove AS dependency:
        child: T(AS.values[relicIdx].name, tsN, w: wTile, h: hText),
      ),
    );
  }
}
