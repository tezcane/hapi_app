import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/component/separator.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/tarikh/main_menu/main_menu_section.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/timeline/tarikh_timeline_ui.dart';

/// The Main Menu Page of the Tarikh Section of the App.
///
/// This Widget lays out the search and favorite FAB at the bottom of the page,
/// then the menu card-sections for accessing the main events on the Timeline.
class TarikhMenuUI extends StatelessWidget {
  const TarikhMenuUI();

  /// Helper function which sets the [MenuItemData] for the [TarikhTimelineUI].
  /// This will trigger a transition from the current menu to the Timeline,
  /// thus the push on the [MenuC.pushSubPage], and by providing the
  /// [item] as a parameter to the [TarikhTimelineUI] constructor, this widget
  /// will know where to scroll to.
  navigateToTimeline(MenuItemData item) {
    TarikhC.to.isActiveTarikhMenu = false;

    MenuC.to.pushSubPage(
      SubPage.Tarikh_Timeline,
      arguments: {'focusItem': item, 'event': null}, // null= up/dn btns not set
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
            GetBuilder<TarikhC>(builder: (c) {
              return ListView.builder(
                shrinkWrap: true, // needed or app pukes
                physics: const ScrollPhysics(), // needed to drag up/down
                itemCount: c.tarikhMenuData.length,
                itemBuilder: (_, index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    child: GetBuilder<TarikhC>(builder: (c) {
                      return MenuSection(
                        c.tarikhMenuData[index].trKeyTitle,
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
