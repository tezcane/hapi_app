import 'package:flutter/material.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/relic/category_section.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_controller.dart';
import 'package:vertical_scrollable_tabview/vertical_scrollable_tabview.dart';

class RelicSet<Relic> {
  RelicSet({
    required this.trKeyTitle,
    required this.relics,
    this.hasNotification = false,
  });
  final String trKeyTitle;
  final List<Relic> relics;
  bool hasNotification;
}

class RelicTabBar extends StatefulWidget {
  const RelicTabBar({
    required this.trKeyTitle,
    required this.relicTypes,
  });
  final String trKeyTitle;
  final List<RELIC_TYPE> relicTypes;

  @override
  _RelicTabBarState createState() => _RelicTabBarState();
}

class _RelicTabBarState extends State<RelicTabBar>
    with SingleTickerProviderStateMixin {
  // TabController More Information => https://api.flutter.dev/flutter/material/TabController-class.html
  late TabController tabController;
  final List<RelicSet> relicSets = [];

  @override
  void initState() {
    tabController =
        TabController(length: widget.relicTypes.length, vsync: this);
    for (RELIC_TYPE relicType in widget.relicTypes) {
      relicSets.add(RelicController.to.getRelicSet(relicType));
    }

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: VerticalScrollableTabView(
        tabController: tabController,
        listItemData: relicSets,
        verticalScrollPosition: VerticalScrollPosition.begin,
        eachItemChild: (object, index) =>
            CategorySection(relicSet: object as RelicSet),
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: true,
            backgroundColor: Theme.of(context).backgroundColor,
            expandedHeight: 0.0,
            // expandedHeight: 250.0,
            // flexibleSpace: FlexibleSpaceBar(
            //   title: T(widget.trKeyTitle, tsN),
            //   titlePadding: const EdgeInsets.only(bottom: 50),
            //   centerTitle: true,
            //   collapseMode: CollapseMode.pin,
            //   //background: FlutterLogo(), TODO
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
              onTap: (index) => VerticalScrollableTabBarStatus.setIndex(index),
            ),
          ),
        ],
      ),
    );
  }
}
