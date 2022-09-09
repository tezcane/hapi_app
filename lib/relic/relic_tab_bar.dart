import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/vertical_scrollable_tabview/scroll_to_index/scroll_to_index.dart';
import 'package:hapi/component/vertical_scrollable_tabview/vertical_scrollable_tabview.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/relic/relic_set.dart';
import 'package:hapi/relic/relics_ui.dart';

class RelicTabBar extends StatefulWidget {
  const RelicTabBar({
    required this.relicTab,
    required this.trKeyTitle,
    required this.relicTypes,
  });
  final RELIC_TAB relicTab;
  final String trKeyTitle;
  final List<RELIC_TYPE> relicTypes;

  @override
  _RelicTabBarState createState() => _RelicTabBarState();
}

class _RelicTabBarState extends State<RelicTabBar>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late AutoScrollController scrollController;
  late VerticalScrollableTabView verticalScrollableTabView;
  final List<RelicSet> relicSets = [];

  bool initNeeded = true;
  int lastSelectedTabIdx = -1;

  @override
  void initState() {
    tabController = TabController(
      initialIndex: RelicC.to.getSelectedTab(widget.relicTab),
      length: widget.relicTypes.length,
      vsync: this,
    );

    scrollController = AutoScrollController();

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RelicC>(builder: (c) {
      if (RelicC.to.initNeeded) {
        return const Center(child: T('بِسْمِ ٱللَّٰهِ', tsN, trVal: true));
      }

      if (initNeeded) {
        for (RELIC_TYPE relicType in widget.relicTypes) {
          relicSets.add(RelicC.to.getRelicSet(relicType));
        }

        // Needed to scroll down to last selected tab at init:
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => animateAndScrollTo(
            RelicC.to.getSelectedTab(widget.relicTab),
          ),
        );

        initNeeded = false;
      }

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: VerticalScrollableTabView(
          relicTab: widget.relicTab,
          tabController: tabController,
          scrollController: scrollController,
          listItemData: relicSets,
          eachItemChild: (object, index) => RelicSetUI(object as RelicSet),
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: true,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: 0.0,
              // TODO get this working with pics of all RelicSets?
              // expandedHeight: 250.0,
              // flexibleSpace: FlexibleSpaceBar(
              //   title: T(widget.trKeyTitle, tsN),
              //   titlePadding: const EdgeInsets.only(bottom: 50),
              //   centerTitle: true,
              //   collapseMode: CollapseMode.pin,
              //   //background: FlutterLogo(),
              // ),
              bottom: TabBar(
                isScrollable: true,
                controller: tabController,
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                indicatorColor: AppThemes.selected,
                labelColor: AppThemes.selected,
                unselectedLabelColor: AppThemes.ldTextColor,
                indicatorWeight: 3.0,
                tabs: relicSets
                    .map((relicSet) => Tab(text: relicSet.trValTitle))
                    .toList(),
                onTap: (index) {
                  animateAndScrollTo(index);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  /// This is called at init and also when user taps a tab on the tab bar
  void animateAndScrollTo(int newIdx) async {
    tabController.animateTo(newIdx);
    scrollController.scrollToIndex(newIdx,
        preferPosition: AutoScrollPosition.begin);

    if (lastSelectedTabIdx != newIdx) {
      lastSelectedTabIdx = newIdx;
      RelicC.to.setLastSelectedTab(widget.relicTab, newIdx);
    }
  }
}
