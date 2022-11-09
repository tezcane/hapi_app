import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/lang/lang_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/relic/al_asma/asma_ul_husna.dart';
import 'package:hapi/relic/al_asma/nabi.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';

/// An entire tab (tab and tile labels, relics, filters, etc.). Uses the
/// RelicSet object found in relic.dart.
// ignore: must_be_immutable
class RelicSetUI extends StatelessWidget {
  RelicSetUI(this.relicSet) {
    filters = relicSet.filterList; // needs init separately

    _updateFilter(RelicC.to.getFilterIdx(relicSet.et));
  }
  final RelicSet relicSet;

  late final List<RelicSetFilter> filters;
  late RelicSetFilter filter;
  int filterIdx = -1; // -1 forces update/rd/wr on next access (init)

  /// tpr (Tiles Per Row) valid range is RelicSetFilter.tprMin-RelicSetFilter.
  /// Variable is used to tell UI how many relic tiles to draw per row, thus
  /// controlling the size of the relic tiles on the screen.
  late int tpr;

  _updateFilter(int newIdx) {
    if (newIdx == filterIdx) return; // no need to do work, return
    filter = filters[newIdx];
    tpr = RelicC.to.getTilesPerRow(relicSet.et, newIdx);

    if (filter.isTreeFilter) {
      MenuC.to.pushSubPage(SubPage.Family_Tree, arguments: {
        'graph1': filter.treeGraph1,
        'graph2': filter.treeGraph2,
        'et': relicSet.et,
      });
      return;
    }

    if (filterIdx != -1) RelicC.to.setFilterIdx(relicSet.et, newIdx);
    filterIdx = newIdx;
  }

  @override
  Widget build(BuildContext context) {
    bool showTileText = RelicC.to.getShowTileText(relicSet.et);

    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tileHeader(context, showTileText),
          const SizedBox(height: 8),
          _tileListView(
            context,
            _getTileWidgets(context, filter.idxList, tpr, showTileText),
            showTileText,
          ),
          const SizedBox(height: 9),
        ],
      ),
    );
  }

  Widget _tileHeader(BuildContext context, bool showTileText) {
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
                      filter.tkLabel,
                      tsNB,
                      w: wText,
                      alignment: LangC.to.centerLeft,
                    ) // only one item, no drop menu needed
                  : _filterDropMenu(context), // to match big/small labels
            ),
            const SizedBox(width: 10),
          ]),
          Row(
            children: [
              if (filter.isResizeable) _growShrinkBtns(),
              InkWell(
                onTap: () {
                  showTileText = !showTileText;
                  RelicC.to.setShowTileText(relicSet.et, showTileText);
                },
                child: SizedBox(
                  width: 45,
                  height: 45,
                  child: Icon(
                    showTileText
                        ? Icons.expand_less_outlined
                        : Icons.expand_more_outlined,
                    size: 45,
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
      value: RelicC.to.getFilterIdx(relicSet.et),
      iconEnabledColor: Colors.white,
      iconSize: 25,
      style: AppThemes.textStyleBtn,
      dropdownColor: cf(context),
      //itemHeight: 55.0,
      menuMaxHeight: 700.0,
      borderRadius: BorderRadius.circular(AppThemes.cornerRadius),
      underline: Container(height: 0),
      onChanged: (int? newValue) => _updateFilter(newValue!),
      items: List<int>.generate(relicSet.filterList.length, (i) => i)
          .map<DropdownMenuItem<int>>(
        (int value) {
          return DropdownMenuItem<int>(
            value: value,
            child: T(
              relicSet.filterList[value].tkLabel,
              RelicC.to.getFilterIdx(relicSet.et) == value ? ts : tsN,
              alignment: LangC.to.centerLeft,
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _growShrinkBtns() {
    return Row(
      children: [
        InkWell(
          onTap: () {
            if (tpr < filter.tprMax) {
              tpr += 1;
              RelicC.to.setTilesPerRow(relicSet.et, filterIdx, tpr);
            }
          },
          child: SizedBox(
            width: 45,
            height: 45,
            child: Icon(
              Icons.remove,
              size: 35,
              color: tpr == filter.tprMax ? AppThemes.unselected : null,
            ),
          ),
        ),
        InkWell(
          onTap: () {
            if (tpr > filter.tprMin) {
              tpr -= 1;
              RelicC.to.setTilesPerRow(relicSet.et, filterIdx, tpr);
            }
          },
          child: SizedBox(
            width: 45,
            height: 45,
            child: Icon(
              Icons.add,
              size: 35,
              color: tpr == filter.tprMin ? AppThemes.unselected : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _tileListView(
    BuildContext context,
    List<Widget> tileWidgets,
    bool showTileText,
  ) {
    return Wrap(
      // direction: Axis.horizontal <-- TODO use this for landscape/portrait mode?
      alignment: WrapAlignment.center, // TY!, centers modules remainders
      spacing: 4, // NOTE: must subtract this from _relicTile() or overflows
      runSpacing: showTileText ? 6 : 2.5, // gap under a row of tiles
      children: tileWidgets,
    );
  }

  List<Widget> _getTileWidgets(
    BuildContext context,
    List<int> filterIdxList,
    int tprSize,
    bool showTileText,
  ) {
    final List<Widget> tileWidgets = []; // TODO can cache for UI speed up
    for (int index in filterIdxList) {
      tileWidgets.add(
        getRelicTile(
          context,
          relicSet.relics[index],
          tprSize,
          relicSet,
          filterIdx,
          showTileText,
        ),
      );
    }
    return tileWidgets;
  }

  /// Public method so all Relic UI's can share the same Relic Tile view.
  static Widget getRelicTile(
    BuildContext context,
    Relic relic,
    int tprSize,
    RelicSet relicSet,
    int filterIdx,
    bool showTileText,
  ) {
    FILTER_FIELD? filterField = relicSet.filterList[filterIdx].field;
    bool hasField = filterField != null;
    String field = '';
    if (hasField) {
      switch (filterField) {
        case FILTER_FIELD.QuranMentionCount:
          if (relic is Nabi) {
            field = cni(relic.quranMentionCount);
          } else if (relic is AsmaUlHusna) {
            field = cni(relic.quranMentionCount);
          }
          break;
        default:
          return l.E('${filterField.name} not implemented yet');
      }
    }

    final double wTile = w(context) / tprSize - 4; // -4 for Wrap.spacing!

    String tvRelicTitleLine1Or2 = relic.tvRelicTitleLine1;
    bool isRelicTextThick = relic.isRelicTextThick && tprSize > 1;
    if (relic.isRelicTextThick && !isRelicTextThick) {
      // if tprSize is maxed, we show tvRelicTitleLine1 and 2 on the same line
      tvRelicTitleLine1Or2 = relic.tvTitle;
    }

    // when tiles get tiny we force huge height to take up all width
    double hText = 35 - (tprSize.toDouble() * 3); // h size: 13-33
    if (hText < 4) hText = 4;

    final double hTile = wTile +
        (showTileText
            ? hText + // +hText for relic line1 label
                (hasField ? hText : 0) + // +hText for field text
                (isRelicTextThick ? hText : 0) // +hText for relic line2 label
            : 0);

    return InkWell(
      onTap: () {
        MenuC.to.pushSubPage(SubPage.Event_Details, arguments: {
          'et': relicSet.et,
          'eventMap': RelicC.to.getEventMap(relicSet.et, filterIdx),
          'saveTag': relic.saveTag,
        });
      },
      child: SizedBox(
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
                child: relic.asset.widget(false, null),
              ),
            ),
            if (showTileText)
              T(
                tvRelicTitleLine1Or2,
                tsN,
                w: wTile,
                h: hText,
                alignment: Alignment.topCenter,
              ),
            if (showTileText && isRelicTextThick)
              T(
                relic.tvRelicTitleLine2,
                tsN,
                w: wTile,
                h: hText,
                alignment: Alignment.topCenter,
              ),
            if (showTileText && hasField)
              T(
                field,
                tsN,
                w: wTile,
                h: hText,
                alignment: Alignment.topCenter,
              ),
          ],
        ),
      ),
    );
  }
}
