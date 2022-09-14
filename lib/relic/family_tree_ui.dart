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
        // Note: Can't use Get.theme here, doesn't switch background color
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: InteractiveViewer(
                constrained: false, // TODO optimize
                boundaryMargin: EdgeInsets.all(100),
                minScale: 0.01,
                maxScale: 5.6,
                child: GraphView(
                  graph: graph,
                  algorithm: BuchheimWalkerAlgorithm(
                      builder, TreeEdgeRenderer(builder)),
                  paint: Paint()
                    ..color = Colors.green
                    ..strokeWidth = 1
                    ..style = PaintingStyle.stroke,
                  builder: (graph_view.Node node) {
                    // I can decide what widget should be shown here based on the id
                    var a = node.key!.value as int?;
                    return rectangleWidget(a);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rectangleWidget(int? a) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(color: Colors.red, spreadRadius: 1),
          ],
        ),
        child: Text('$a ${PF.values[a!].name}'),
      ),
    );
  }
}
