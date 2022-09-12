import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/relic/ummah/prophet.dart';

/// An entire tab (tab and tile labels, relics, filters, etc.). Uses the
/// RelicSet object found in relic.dart.
// ignore: must_be_immutable
class RelicSetUI extends StatelessWidget {
  RelicSetUI(this.relicSet) {
    filters = relicSet.filterList; // needs init separately

    _updateFilter(RelicC.to.getFilterIdx(relicSet.relicType));
  }
  final RelicSet relicSet;

  late final List<RelicSetFilter> filters;
  late RelicSetFilter filter;
  late int filterIdx = -1; // -1 forces update/rd/wr on next access (init)

  /// tpr (Tiles Per Row) valid range is 1-11, within this range it can be set
  /// to lower values to prevent tiles from changing too big/small in
  /// conjunction with tprMin/tprMax values.
  late int tpr;

  late bool showTileText;

  _updateFilter(int newIdx) {
    if (newIdx == filterIdx) return; // no need to do work, return
    filter = filters[newIdx];
    tpr = RelicC.to.getTilesPerRow(relicSet.relicType, newIdx);

    showTileText = RelicC.to.getShowTileText(relicSet.relicType);

    if (filterIdx != -1) RelicC.to.setFilterIdx(relicSet.relicType, newIdx);
    filterIdx = newIdx;
  }

  @override
  Widget build(BuildContext context) {
    late List<Widget> tileWidgetList;
    switch (filter.type) {
      case (FILTER_TYPE.Default):
        tileWidgetList = _getTileListDefault(context);
        break;
      case (FILTER_TYPE.IdxList):
        tileWidgetList = _getTileIdxList(context);
        break;
      case (FILTER_TYPE.Tree):
        break;
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tileHeader(context),
          const SizedBox(height: 8),
          filter.type == FILTER_TYPE.Tree
              ? SizedBox(
                  width: w(context),
                  height: h(context),
                  child: TreeViewPage(),
                )
              : _tileList(context, tileWidgetList),
          const SizedBox(height: 9),
        ],
      ),
    );
  }

  Widget _tileHeader(BuildContext context) {
    // width of extra spaces between 65-155: 65 (10+10+45) + 90 (45+45)
    final double wText = w(context) - 65 - (filter.isResizeable ? 90 : 0);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            const SizedBox(width: 10),
            SizedBox(
              width: wText,
              child: filters.length == 1
                  ? T(
                      filter.trValLabel,
                      tsNB,
                      w: wText,
                      trVal: true,
                      alignment: LanguageC.to.centerLeft,
                    ) // only one item, no drop menu needed
                  : _filterDropMenu(context), // to match big/small labels
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

  Widget _filterDropMenu(BuildContext context) {
    return DropdownButton<int>(
      isExpanded: true,
      isDense: false,
      value: RelicC.to.getFilterIdx(relicSet.relicType),
      iconEnabledColor: Colors.white,
      iconSize: 25,
      style: AppThemes.textStyleBtn,
      dropdownColor: cf(context),
      //itemHeight: 55.0,
      menuMaxHeight: 700.0,
      borderRadius: BorderRadius.circular(AppThemes.cornerRadius),
      underline: Container(height: 0),
      onChanged: (int? newValue) {
        _updateFilter(newValue!);

        // updateOnThread1Ms() after RelicC.setFilterIdx() is OK, so don't need:
        //   Needed to reflect dropdown menu selection on UI:
        //   WidgetsBinding.instance.addPostFrameCallback((_) => RelicC.to.update());
      },
      items: List<int>.generate(relicSet.filterList.length, (i) => i)
          .map<DropdownMenuItem<int>>(
        (int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: T(
              relicSet.filterList[value].trValLabel,
              RelicC.to.getFilterIdx(relicSet.relicType) == value ? ts : tsN,
              alignment: LanguageC.to.centerLeft,
            ),
          );
        },
      ).toList(),
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

  List<Widget> _getTileListDefault(BuildContext context) {
    final List<Widget> tileWidgets = []; // TODO can cache for UI speed up
    for (Relic relic in relicSet.relics) {
      tileWidgets.add(_relicTile(context, relic));
    }
    // Acts same as above:
    /* List.generate(
        relicSet.relics.length,
        (index) {
          return _relicTile(context, relicSet.relics[index]);
        },
      ) */
    return tileWidgets;
  }

  List<Widget> _getTileIdxList(BuildContext context) {
    final List<Widget> tileWidgets = []; // TODO can cache for UI speed up
    for (int index in filter.idxList!) {
      tileWidgets.add(_relicTileWithField(context, relicSet.relics[index]));
    }
    return tileWidgets;
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

  Widget _relicTileWithField(BuildContext context, Relic relic) {
    bool hasField = filter.field != null;
    String field = '';
    if (hasField) {
      switch (filter.field) {
        case (FILTER_FIELD.Prophet_quranMentionCount):
          field = cni((relic as Prophet).quranMentionCount);
          break;
        default:
          return l.E('filter.field ${filter.field!.name} not implemented yet');
      }
    }

    final double wTile = w(context) / tpr - 4; // -4 for Wrap.spacing!

    // when tiles get tiny we force huge height to take up all width
    final double hText = 35 - (tpr.toDouble() * 2); // h size: 13-33
    final double hTile = wTile + (showTileText ? (hText * 2) : 0);

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
                  image: AssetImage(relic.asset.filename), fit: BoxFit.fill),
            ),
          ),
          if (showTileText && hasField) T(field, tsN, w: wTile, h: hText),
          if (showTileText) T(relic.trValTitle, tsN, w: wTile, h: hText),
        ],
      ),
    );
  }

  Widget _tileList(BuildContext context, List<Widget> tileWidgets) {
    return Wrap(
      // direction: Axis.horizontal <-- TODO use this for landscape/portrait mode?
      alignment: WrapAlignment.center, // TY!, centers modules remainders
      spacing: 4, // NOTE: must subtract this from _relicTile() or overflows
      runSpacing: showTileText ? 6 : 2.5, // gap under a row of tiles
      children: tileWidgets,
    );
  }
}

class TreeViewPage extends StatefulWidget {
  @override
  _TreeViewPageState createState() => _TreeViewPageState();
}

class _TreeViewPageState extends State<TreeViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(),
        body: Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Wrap(
        //   children: [
        //     Container(
        //       width: 100,
        //       child: TextFormField(
        //         initialValue: builder.siblingSeparation.toString(),
        //         decoration: InputDecoration(labelText: 'Sibling Separation'),
        //         onChanged: (text) {
        //           builder.siblingSeparation = int.tryParse(text) ?? 10;
        //           this.setState(() {});
        //         },
        //       ),
        //     ),
        //     Container(
        //       width: 100,
        //       child: TextFormField(
        //         initialValue: builder.levelSeparation.toString(),
        //         decoration: InputDecoration(labelText: 'Level Separation'),
        //         onChanged: (text) {
        //           builder.levelSeparation = int.tryParse(text) ?? 40;
        //           this.setState(() {});
        //         },
        //       ),
        //     ),
        //     Container(
        //       width: 100,
        //       child: TextFormField(
        //         initialValue: builder.subtreeSeparation.toString(),
        //         decoration: InputDecoration(labelText: 'Subtree separation'),
        //         onChanged: (text) {
        //           builder.subtreeSeparation = int.tryParse(text) ?? 10;
        //           this.setState(() {});
        //         },
        //       ),
        //     ),
        //     Container(
        //       width: 100,
        //       child: TextFormField(
        //         initialValue: builder.orientation.toString(),
        //         decoration: InputDecoration(labelText: 'Orientation'),
        //         onChanged: (text) {
        //           builder.orientation = int.tryParse(text) ?? 100;
        //           this.setState(() {});
        //         },
        //       ),
        //     ),
        //     ElevatedButton(
        //       onPressed: () {
        //         final node12 = Node.Id(r.nextInt(100));
        //         var edge =
        //             graph.getNodeAtPosition(r.nextInt(graph.nodeCount()));
        //         print(edge);
        //         graph.addEdge(edge, node12);
        //         setState(() {});
        //       },
        //       child: Text('Add'),
        //     )
        //   ],
        // ),
        Expanded(
          child: InteractiveViewer(
              constrained: false,
              boundaryMargin: EdgeInsets.all(100),
              minScale: 0.01,
              maxScale: 5.6,
              child: GraphView(
                graph: graph,
                algorithm:
                    BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                paint: Paint()
                  ..color = Colors.green
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  // I can decide what widget should be shown here based on the id
                  var a = node.key!.value as int?;
                  return rectangleWidget(a);
                },
              )),
        ),
      ],
    ));
  }

  Random r = Random();

  Widget rectangleWidget(int? a) {
    return InkWell(
      onTap: () {
        print('clicked');
      },
      child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(color: Colors.blue[100]!, spreadRadius: 1),
            ],
          ),
          child: Text('$a ${PROPHET.values[a!].name}')),
    );
  }

  final Graph graph = Graph()..isTree = true;
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

  @override
  void initState() {
    final Adam = Node.Id(0);
    final Idris = Node.Id(1);
    final Nuh = Node.Id(2);
    final Hud = Node.Id(3);
    final Salih = Node.Id(4);
    final Ibrahim = Node.Id(5);
    final Lut = Node.Id(6);
    final Ismail = Node.Id(7);
    final Ishaq = Node.Id(8);
    final Yaqub = Node.Id(9);
    final Yusuf = Node.Id(10);
    final Ayyub = Node.Id(11);
    final Shuayb = Node.Id(12);
    final Musa = Node.Id(13);
    final Harun = Node.Id(14);
    final DhulKifl = Node.Id(15);
    final Dawud = Node.Id(16);
    final Suleyman = Node.Id(17);
    final Ilyas = Node.Id(18);
    final Alyasa = Node.Id(19);
    final Yunus = Node.Id(20);
    final Zakariya = Node.Id(21);
    final Yahya = Node.Id(22);
    final Isa = Node.Id(23);
    final Muhammad = Node.Id(24);

    graph.addEdge(Adam, Idris);
    graph.addEdge(Idris, Nuh);
    graph.addEdge(Nuh, Hud);
    graph.addEdge(Nuh, Salih);

    // final node1 = Node.Id(1);
    // final node2 = Node.Id(2);
    // final node3 = Node.Id(3);
    // final node4 = Node.Id(4);
    // final node5 = Node.Id(5);
    // final node6 = Node.Id(6);
    // final node8 = Node.Id(7);
    // final node7 = Node.Id(8);
    // final node9 = Node.Id(9);
    // final node10 = Node.Id(10);
    // final node11 = Node.Id(11);
    // final node12 = Node.Id(12);
    // graph.addEdge(node1, node2);
    // graph.addEdge(node1, node3, paint: Paint()..color = Colors.red);
    // graph.addEdge(node1, node4, paint: Paint()..color = Colors.blue);
    // graph.addEdge(node2, node5);
    // graph.addEdge(node2, node6);
    // graph.addEdge(node6, node7, paint: Paint()..color = Colors.red);
    // graph.addEdge(node6, node8, paint: Paint()..color = Colors.red);
    // graph.addEdge(node4, node9);
    // graph.addEdge(node4, node10, paint: Paint()..color = Colors.black);
    // graph.addEdge(node4, node11, paint: Paint()..color = Colors.red);
    // graph.addEdge(node11, node12);

    builder
      ..siblingSeparation = (10)
      ..levelSeparation = (40)
      ..subtreeSeparation = (10)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }
}
