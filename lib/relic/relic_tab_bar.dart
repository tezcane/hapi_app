import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/vertical_scrollable_tabview/vertical_scrollable_tabview.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_controller.dart';
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
  // TabController More Information => https://api.flutter.dev/flutter/material/TabController-class.html
  late TabController tabController;
  late VerticalScrollableTabView verticalScrollableTabView;
  final List<RelicSet> relicSets = [];

  bool initNeeded = true;

  @override
  void initState() {
    int selectedTab = RelicController.to.getSelectedTab(widget.relicTab);
    VerticalScrollableTabBarStatus.setIndex(selectedTab);

    tabController = TabController(
      initialIndex: selectedTab,
      length: widget.relicTypes.length,
      vsync: this,
    );
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RelicController>(builder: (c) {
      if (RelicController.to.initNeeded) {
        return const Center(child: T('بِسْمِ ٱللَّٰهِ', tsN, trVal: true));
      }

      if (initNeeded) {
        for (RELIC_TYPE relicType in widget.relicTypes) {
          relicSets.add(RelicController.to.getRelicSet(relicType));
        }
        initNeeded = false;
      }

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: VerticalScrollableTabView(
          tabController: tabController,
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
                    .map((relicSet) => Tab(text: relicSet.trKeyTitle))
                    .toList(),
                onTap: (index) {
                  VerticalScrollableTabBarStatus.setIndex(index);
                  RelicController.to.setLastSelectedTab(widget.relicTab, index);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
