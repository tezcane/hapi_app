import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/tarikh/blocs/bloc_provider.dart';
import 'package:hapi/tarikh/colors.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';
import 'package:hapi/tarikh/main_menu/thumbnail_detail_widget.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// This widget is displayed when tapping on the Favorites button in the [MainMenuWidget].
///
/// It displays the list of favorites kept by the [BlocProvider], and moves into the timeline
/// when tapping on one of them.
///
/// To add any item as favorite, go to the [ArticleWidget] and tap on the heart button.
class TarikhFavoritesUI extends StatelessWidget {
  /// This widget displays a [ListView] for all the elements in the favorites.
  @override
  Widget build(BuildContext context) {
    List<Widget> favorites = [];

    /// Access the favorites list from the [BlocProvider], which is available as a root
    /// element of the app.
    List<TimelineEntry> entries = BlocProvider.favorites(context).favorites;

    /// Add all the elements into a [List<Widget>] so that we can pass it to the [ListView] in the [Scaffold] body.
    for (int i = 0; i < entries.length; i++) {
      TimelineEntry entry = entries[i];
      favorites.add(
        ThumbnailDetailWidget(
          entry,
          hasDivider: i != 0,
          tapSearchResult: (TimelineEntry entry) {
            MenuItemData item = MenuItemData.fromEntry(entry);

            cMenu.pushSubPage(
              SubPage.TARIKH_TIMELINE,
              arguments: {
                'focusItem': item,
                'timeline': BlocProvider.getTimeline(context),
              },
            );
          },
        ),
      );
    }

    /// Use the same style for the top bar, with the usual colors and the correct icons.
    /// By pressing the back arrow, [Navigator.pop()] smoothly closes this view and returns
    /// the app back to the [MainMenuWidget].
    /// If no entry has been added to the favorites yet, a placeholder [Column] is shown with a
    /// a few lines of text and a [FlareActor] animation of a broken heart.
    /// Check it out at: https://www.2dimensions.com/a/pollux/files/flare/broken-heart/preview
    return FabSubPage(
      subPage: SubPage.TARIKH_FAVORITE,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: favorites.isEmpty
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
                          margin: EdgeInsets.only(bottom: 30),
                          child: FlareActor("assets/tarikh/Broken Heart.flr",
                              animation: "Heart Break", shouldClip: false),
                        ),
                        Container(
                          padding: EdgeInsets.only(bottom: 21),
                          width: 250,
                          child: Text("No favorites yet",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "RobotoMedium",
                                fontSize: 25,
                                color: darkText
                                    .withOpacity(darkText.opacity * 0.75),
                                height: 1.2,
                              )),
                        ),
                        Container(
                          width: 270,
                          margin: EdgeInsets.only(bottom: 114),
                          child: Text(
                            "To save favorites, tap on the heart inside timeline events",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 17,
                              height: 1.5,
                              color: Colors.black.withOpacity(0.75),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )
              // TODO bug here if add to fav on article and back button to here no show:
              : ListView(children: favorites),
        ),
      ),
    );
  }
}
