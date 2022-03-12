import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/main_menu/thumbnail_detail_widget.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// This widget is displayed when tapping on the Favorites button in [TarikhMenuUI].
///
/// It displays the list of favorites kept by the [TarikhController], and moves into the timeline
/// when tapping on one of them.
///
/// To add any item as favorite, go to the [TarikhArticleUI] and tap on the heart button.
class TarikhFavoritesUI extends StatelessWidget {
  /// This widget displays a [ListView] for all the elements in the favorites.
  @override
  Widget build(BuildContext context) {
    /// By pressing the back arrow, [Navigator.pop()] smoothly closes this view and returns
    /// the app back to the [TarikhMenuUI].
    /// If no entry has been added to the favorites yet, a placeholder is shown with a
    /// a few lines of text and a [FlareActor] animation of a broken heart.
    return FabSubPage(
      subPage: SubPage.Tarikh_Favorite,
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: GetBuilder<TarikhController>(
            builder: (c) {
              return c.favorites.isEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              width: 128.0,
                              height: 114.0,
                              margin: const EdgeInsets.only(bottom: 30),
                              child: const FlareActor(
                                  "assets/tarikh/Broken Heart.flr",
                                  animation: "Heart Break",
                                  shouldClip: false),
                            ),
                            Container(
                              padding: const EdgeInsets.only(bottom: 21),
                              width: 250,
                              child: Text(
                                "No favorites",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                            // TODO fix from cutting text when too long (different lang support)
                            Container(
                              //width: 270,
                              margin: const EdgeInsets.only(bottom: 114),
                              child: Text(
                                'Add favorites in history articles',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                          ],
                        )
                      ],
                    )
                  : ListView.builder(
                      itemCount: c.favorites.length,
                      itemBuilder: (BuildContext context, int idx) {
                        TimelineEntry entry = c.favorites[idx];
                        return ThumbnailDetailWidget(
                          entry,
                          hasDivider: idx != 0,
                          tapSearchResult: (TimelineEntry entry) {
                            MenuItemData item = MenuItemData.fromEntry(entry);
                            MenuController.to.pushSubPage(
                              SubPage.Tarikh_Timeline,
                              arguments: {'focusItem': item, 'entry': entry},
                            );
                          },
                        );
                      },
                    );
            },
          ),
        ),
      ),
    );
  }
}
