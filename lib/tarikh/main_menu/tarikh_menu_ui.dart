import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/main_menu/main_menu_section.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';

/// The Main Menu Page of the Tarikh Section of the App.
///
/// This Widget lays out the search and favorite FAB at the bottom of the page,
/// then the menu card-sections for accessing the main events on the Timeline.
class TarikhMenuUI extends StatelessWidget {
  /// Helper function which sets the [MenuItemData] for the [TarikhTimelineUI].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [MenuController.pushSubPage], and by providing the
  /// [item] as a parameter to the [TarikhTimelineUI] constructor, this widget
  /// will know where to scroll to.
  navigateToTimeline(MenuItemData item) {
    TarikhController.to.pauseMenuSection();

    MenuController.to.pushSubPage(
      SubPage.Tarikh_Timeline,
      arguments: {'focusItem': item, 'entry': null}, // null= up/dn btns not set
    );
  }

  @override
  Widget build(BuildContext context) {
    /// A [SingleChildScrollView] is used to create a scrollable view for the main menu.
    return Scaffold(
      floatingActionButton: GetBuilder<MenuController>(
        builder: (c) => Visibility(
          visible: !c.isMenuShowing(),
          //maintainAnimation: true,
          child: Padding(
            padding: const EdgeInsets.only(right: 75.0),
            child: FloatingActionButton(
              tooltip: 'View your favorites',
              heroTag: SubPage.Tarikh_Favorite,
              onPressed: () {
                TarikhController.to.pauseMenuSection();
                MenuController.to.pushSubPage(SubPage.Tarikh_Favorite);
              },
              materialTapTargetSize: MaterialTapTargetSize.padded,
              child: const Icon(Icons.favorite_border_outlined, size: 36.0),
            ),
          ),
        ),
      ),
      body: Scaffold(
        floatingActionButton: GetBuilder<MenuController>(
          builder: (c) => Visibility(
            visible: !c.isMenuShowing(),
            child: Padding(
              padding: const EdgeInsets.only(right: 150.0),
              child: FloatingActionButton(
                tooltip: 'Search history',
                heroTag: SubPage.Tarikh_Search,
                onPressed: () {
                  TarikhController.to.pauseMenuSection();
                  MenuController.to.pushSubPage(SubPage.Tarikh_Search);
                },
                materialTapTargetSize: MaterialTapTargetSize.padded,
                child: const Icon(Icons.search_outlined, size: 36.0),
              ),
            ),
          ),
        ),
        body: FabNavPage(
          navPage: NavPage.Tarikh,
          settingsWidget: null,
          bottomWidget: HapiShareUI(),
          foregroundPage: Container(
            // Set height since shrinkwrap exposed the hapi logo/menu
            height: MediaQuery.of(context).size.height,
            color: Theme.of(context).backgroundColor, // covers hapi logo/menu
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 20.0, left: 20, right: 20, bottom: 20),
              child: Column(
                children: [
                  GetBuilder<TarikhController>(builder: (c) {
                    return ListView.builder(
                      shrinkWrap: true, // needed or app pukes
                      physics: const ScrollPhysics(), // needed to drag up/down
                      itemCount: c.menuSectionDataList.length,
                      itemBuilder: (_, index) {
                        return Container(
                          margin: const EdgeInsets.only(top: 20.0),
                          child: GetBuilder<TarikhController>(builder: (c) {
                            return MenuSection(
                              c.menuSectionDataList[index].label,
                              c.menuSectionDataList[index].backgroundColor,
                              c.menuSectionDataList[index].textColor,
                              c.menuSectionDataList[index].items,
                              navigateToTimeline,
                              c.isSectionActive,
                              assetId: c.menuSectionDataList[index].assetId,
                            );
                          }),
                        );
                      },
                    );
                  }),

                  /// this is the little line that shows under the vignettes
                  Container(
                    margin: const EdgeInsets.only(top: 43.0),
                    height: 2.0,
                    color: const Color.fromRGBO(151, 151, 151, 0.29),
                  ),

                  /// this is the little line that shows under the vignettes
                  Container(
                    margin: const EdgeInsets.only(bottom: 22),
                    height: 2.0,
                    color: const Color.fromRGBO(239, 227, 227, 0.29),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
