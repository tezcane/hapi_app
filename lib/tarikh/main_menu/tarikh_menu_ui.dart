import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/separator.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/tarikh/main_menu/main_menu_section.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';

/// The Main Menu Page of the Tarikh Section of the App.
///
/// This Widget lays out the search and favorite FAB at the bottom of the page,
/// then the menu card-sections for accessing the main events on the Timeline.
class TarikhMenuUI extends StatelessWidget {
  const TarikhMenuUI();

  /// Helper function which sets the [MenuItemData] for the [TarikhTimelineUI].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [MenuController.pushSubPage], and by providing the
  /// [item] as a parameter to the [TarikhTimelineUI] constructor, this widget
  /// will know where to scroll to.
  navigateToTimeline(MenuItemData item) {
    TarikhController.to.isActiveTarikhMenu = false;

    MenuController.to.pushSubPage(
      SubPage.Tarikh_Timeline,
      arguments: {'focusItem': item, 'entry': null}, // null= up/dn btns not set
    );
  }

  @override
  Widget build(BuildContext context) {
    /// A [SingleChildScrollView] is used to create a scrollable view for the main menu.
    return Container(
      // Set height since shrinkwrap exposed the hapi logo/menu
      height: MediaQuery.of(context).size.height,
      color: Theme.of(context).backgroundColor, // covers hapi logo/menu
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.only(top: 20.0, left: 20, right: 20, bottom: 20),
        child: Column(
          children: [
            GetBuilder<TarikhController>(builder: (c) {
              return ListView.builder(
                shrinkWrap: true, // needed or app pukes
                physics: const ScrollPhysics(), // needed to drag up/down
                itemCount: c.tarikhMenuData.length,
                itemBuilder: (_, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: GetBuilder<TarikhController>(builder: (c) {
                      return MenuSection(
                        c.tarikhMenuData[index].trKeyEndTagLabel,
                        c.tarikhMenuData[index].backgroundColor,
                        c.tarikhMenuData[index].textColor,
                        c.tarikhMenuData[index].items,
                        navigateToTimeline,
                        c.isActiveTarikhMenu,
                        assetId: c.tarikhMenuData[index].assetId,
                      );
                    }),
                  );
                },
              );
            }),

            /// this is the little line that shows under the vignettes
            const Separator(43, 22, 2),
          ],
        ),
      ),
    );
  }
}
