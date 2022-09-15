import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphview/GraphView.dart';
import 'package:graphview/GraphView.dart' as graph_view;
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/relic/ummah/prophet.dart';

/// Shows a Family Tree SubPage.
class FamilyTreeUI extends StatelessWidget {
  FamilyTreeUI() {
    graph = Get.arguments['graph'];
  }
  late final Graph graph;

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
                    // I can decide what widget should be shown here based on the id
                    var a = node.key!.value as int?;
                    return rectangleWidget(a, context);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rectangleWidget(int? a, context) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).scaffoldBackgroundColor,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Text('$a ${PF.values[a!].name}'),
      ),
    );
  }
}
