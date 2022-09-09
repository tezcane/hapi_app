import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/main_menu/thumbnail_detail_widget.dart';
import 'package:hapi/tarikh/tarikh_c.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// This widget is displayed when tapping on the Favorites button in [TarikhUI].
///
/// It displays the list of favorites kept by the [TarikhC], and moves into the timeline
/// when tapping on one of them.
///
/// To add any item as favorite, go to the [TarikhArticleUI] and tap on the heart button.
class TarikhFavoritesUI extends StatelessWidget {
  const TarikhFavoritesUI();

  /// This widget displays a [ListView] for all the elements in the favorites.
  @override
  Widget build(BuildContext context) {
    /// If no entry has been added to the favorites yet, a placeholder is shown with a
    /// a few lines of text and a [FlareActor] animation of a broken heart.
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GetBuilder<TarikhC>(builder: (c) {
          return c.eventFavorites.isEmpty
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
                              'assets/tarikh/flare/Broken Heart.flr',
                              animation: 'Heart Break',
                              shouldClip: false),
                        ),
                        Container(
                          padding: const EdgeInsets.only(bottom: 21),
                          width: 250,
                          child: Text(
                            'No favorites',
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
                  itemCount: c.eventFavorites.length,
                  itemBuilder: (BuildContext context, int idx) {
                    TimelineEntry entry = c.eventFavorites[idx];
                    return ThumbnailDetailWidget(
                      entry,
                      hasDivider: idx != 0,
                      tapSearchResult: (TimelineEntry entry) {
                        MenuItemData item = MenuItemData.fromEntry(entry);
                        MenuC.to.pushSubPage(
                          SubPage.Tarikh_Timeline,
                          arguments: {'focusItem': item, 'entry': entry},
                        );
                      },
                    );
                  },
                );
        }),
      ),
    );
  }
}
