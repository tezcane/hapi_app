import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/auto_scroll_tab_view/auto_scroll_controller/auto_scroll_controller.dart';
import 'package:hapi/component/auto_scroll_tab_view/auto_scroll_tab_view.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/relic/relic_set_ui.dart';
import 'package:hapi/relic/relics_ui.dart';

/// A single RELIC_TAB bar which holds one or more RelicSets that are accessible
/// via an AutoScrollTabView, meaning when the user scrolls vertically the
/// Tab Bar's selection of the current RelicSet in view gets highlighted.
class RelicTabBar extends StatefulWidget {
  const RelicTabBar({required this.relicTab, required this.relicTypes});
  final RELIC_TAB relicTab;
  final List<RELIC_TYPE> relicTypes;

  @override
  _RelicTabBarState createState() => _RelicTabBarState();
}

class _RelicTabBarState extends State<RelicTabBar>
    with SingleTickerProviderStateMixin {
  final List<RelicSet> relicSets = [];
  final List<Tab> tabs = [];
  late final TabController tabController;
  late final AutoScrollController autoScrollController;

  bool initNeeded = true;
  int tabIdx = -1; // -1 forces update/rd/wr on next access (init)

  @override
  void initState() {
    tabController = TabController(
      initialIndex: RelicC.to.getSelectedTabIdx(widget.relicTab),
      length: widget.relicTypes.length,
      vsync: this,
    );

    autoScrollController = AutoScrollController();

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    autoScrollController.dispose();
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
          RelicSet relicSet = RelicC.to.getRelicSet(relicType);

          relicSets.add(relicSet);
          tabs.add(Tab(text: a(relicSet.tkTitle)));
        }

        // Needed to scroll down to last selected tab at init:
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => animateAndScrollTo(
            RelicC.to.getSelectedTabIdx(widget.relicTab),
          ),
        );

        initNeeded = false;
      }

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: AutoScrollTabView(
          relicTab: widget.relicTab,
          tabController: tabController,
          autoScrollController: autoScrollController,
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
              //   title: T(widget.tkTitle, tsN),
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
                tabs: tabs,
                onTap: (index) => animateAndScrollTo(index),
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
    autoScrollController.scrollToIndex(
      newIdx,
      preferPosition: AutoScrollPosition.begin,
    );

    if (tabIdx != newIdx) {
      if (tabIdx != -1) {
        RelicC.to.setLastSelectedTabIdx(widget.relicTab, newIdx);
      }
      tabIdx = newIdx;
    }
  }
}
