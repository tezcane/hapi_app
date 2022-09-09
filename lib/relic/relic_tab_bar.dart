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
    required this.trKeyTitle,
    required this.relicTab,
    required this.relicTypes,
  });
  final String trKeyTitle;
  final RELIC_TAB relicTab;
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

  bool notInitialized = true;
  bool notInitializedLastSelectedTab = true;

  @override
  void initState() {
    int lastSelectedTab =
        RelicController.to.getLastSelectedTab(widget.relicTab);
    VerticalScrollableTabBarStatus.setIndex(lastSelectedTab);

    tabController = TabController(
      initialIndex: lastSelectedTab,
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
      if (RelicController.to.isNotInitialized) {
        return const Center(child: T('بِسْمِ ٱللَّٰهِ', tsN, trVal: true));
      }

      if (notInitialized) {
        for (RELIC_TYPE relicType in widget.relicTypes) {
          relicSets.add(RelicController.to.getRelicSet(relicType));
        }
        notInitialized = false;
      }

      // if (notInitializedLastSelectedTab) {
      //   WidgetsBinding.instance.addPostFrameCallback(_setLastSelectedTab);
      // }

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: VerticalScrollableTabView(
          tabController: tabController,
          listItemData: relicSets,
          verticalScrollPosition: VerticalScrollPosition.begin,
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

  // void _setLastSelectedTab(_) {
  //   // if (!notInitializedLastSelectedTab) return;
  //
  //   int lastSelectedTab =
  //       RelicController.to.getLastSelectedTab(widget.relicTab);
  //   debugPrint('asdf=$lastSelectedTab');
  //   //tabController.animateTo(lastSelectedTab);
  //   VerticalScrollableTabBarStatus.setIndex(lastSelectedTab);
  //   notInitializedLastSelectedTab = false;
  //   //verticalScrollableTabView.animateAndScrollTo(lastSelectedTab);
  //
  //   // RelicController.to.updateOnThread1Ms();
  // }
}
