import 'package:flutter/material.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/relic/ummah/category_section.dart';
import 'package:hapi/relic/ummah/example_data.dart';
import 'package:vertical_scrollable_tabview/vertical_scrollable_tabview.dart';

class UmmahUI extends StatefulWidget {
  const UmmahUI({required this.trKeyTitle});
  final String trKeyTitle;

  @override
  _UmmahUIState createState() => _UmmahUIState();
}

class _UmmahUIState extends State<UmmahUI> with SingleTickerProviderStateMixin {
  final List<Category> data = ExampleData.data;

  // TabController More Information => https://api.flutter.dev/flutter/material/TabController-class.html
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: data.length, vsync: this);
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
        listItemData: data,
        verticalScrollPosition: VerticalScrollPosition.begin,
        eachItemChild: (object, index) =>
            CategorySection(category: object as Category),
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
              tabs: data.map((e) => Tab(text: e.title)).toList(),
              onTap: (index) => VerticalScrollableTabBarStatus.setIndex(index),
            ),
          ),
        ],
      ),
    );
  }
}
