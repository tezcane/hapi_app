import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/relic/ummah/prophet.dart';
import 'package:hapi/tarikh/event/event.dart';

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

  /// tpr (Tiles Per Row) valid range is RelicSetFilter.tprMin-RelicSetFilter.
  /// Variable is used to tell UI how many relic tiles to draw per row, thus
  /// controlling the size of the relic tiles on the screen.
  late int tpr;

  late bool showTileText;

  _updateFilter(int newIdx) {
    if (newIdx == filterIdx) return; // no need to do work, return
    filter = filters[newIdx];
    tpr = RelicC.to.getTilesPerRow(relicSet.relicType, newIdx);

    showTileText = RelicC.to.getShowTileText(relicSet.relicType);

    if (filter.type == FILTER_TYPE.Tree) {
      MenuC.to.pushSubPage(SubPage.Family_Tree, arguments: {
        'graph1': filter.treeGraph1,
        'graph2': filter.treeGraph2,
        'relicType': relicSet.relicType,
      });
      return;
    }

    if (filterIdx != -1) RelicC.to.setFilterIdx(relicSet.relicType, newIdx);
    filterIdx = newIdx;
  }

  @override
  Widget build(BuildContext context) {
    Widget tileView;
    switch (filter.type) {
      case FILTER_TYPE.Default:
        tileView = _tileList(context, _getTileListDefault(context));
        break;
      case FILTER_TYPE.IdxList:
        tileView = _tileList(context, _getTileIdxList(context));
        break;
      case FILTER_TYPE.Tree:
        l.e('FILTER_TYPE.${FILTER_TYPE.Tree.name} has its on UI');
        return Container();
    }

    return Container(
      color: Theme.of(context).backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tileHeader(context),
          const SizedBox(height: 8),
          tileView,
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
              size: 35,
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
              size: 35,
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

    return InkWell(
      onTap: () {
        MenuC.to.pushSubPage(SubPage.Event_Details, arguments: {
          'eventType': EVENT_TYPE.Relic,
          'eventMap': getEventMap(),
          'trKeyTitleAtInit': relic.trKeyTitle,
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
                child: Image(
                  image: AssetImage(relic.asset.filename),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            if (showTileText) T(relic.trKeyTitle, tsN, w: wTile, h: hText),
          ],
        ),
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

    return InkWell(
      onTap: () {
        MenuC.to.pushSubPage(SubPage.Event_Details, arguments: {
          'eventType': EVENT_TYPE.Relic,
          'eventMap': getEventMap(),
          'trKeyTitleAtInit': relic.trKeyTitle,
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
                child: Image(
                  image: AssetImage(relic.asset.filename),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            if (showTileText && hasField) T(field, tsN, w: wTile, h: hText),
            if (showTileText) T(relic.trKeyTitle, tsN, w: wTile, h: hText),
          ],
        ),
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

  /// To get the EventUI() UI working, with least amount of pain, we turn our
  /// relic structures into a Map<String, String> that Tarikh code are already
  /// using. This way we can reuse lots of logic and maps are efficient anyway.
  Map<String, Event> getEventMap() {
    List<int> idxList = [];
    switch (filter.type) {
      case FILTER_TYPE.Default:
      case FILTER_TYPE.Tree:
        for (Relic relic in relicSet.relics) {
          idxList.add(relic.relicId);
        }
        break;
      case FILTER_TYPE.IdxList:
        idxList = filter.idxList!;
        break;
    }

    // Create the map to be used for up/dn buttons
    Map<String, Event> eventMap = {};
    Event? prevEvent; // start null, parent/first event has no previous event
    for (int idx = 0; idx < idxList.length; idx++) {
      Event event = relicSet.relics[idxList[idx]];
      event.previous = prevEvent;

      if (idx == idxList.length - 1) {
        event.next = null; // last idx
      } else {
        event.next = relicSet.relics[idxList[idx + 1]];
      }

      prevEvent = event; // prev event is this current event
      eventMap[event.trKeyTitle] = event;
    }

    return eventMap;
  }
}
