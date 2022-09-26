import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/relic/relic.dart';
import 'package:hapi/relic/relic_c.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_c.dart';
import 'package:hapi/tarikh/event/thumbnail_widget.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';

/// This widget lays out nicely the [event] provided.
///
/// It shows the [ThumbnailWidget] for that event on the left, and the event's
/// label and date of the event on its immediate right.
///
/// This widget is used while displaying the search results in the [MainMenuWidget], and in the
/// [FavoritesPage] widget.
class ThumbnailDetailWidget extends StatelessWidget {
  const ThumbnailDetailWidget(
    this.navPage,
    this.event, {
    this.hasDivider = true,
  });
  final NavPage navPage;
  final Event event;

  /// Whether to show a divider line on the bottom of this widget. Defaults to `true`.
  final bool hasDivider;

  /// Use [Material] & [InkWell] to show a Material Design ripple effect on the row.
  /// [InkWell] provides also a callback for custom onTap behavior.
  ///
  /// The widget is laid out with a [Column] that lays out the contents of the event, and the divider,
  /// and a [Row], which contains the [ThumbnailWidget], and the event information.
  @override
  Widget build(BuildContext context) {
    // TODO was return Material(color: Colors.transparent, child:
    return Column(
      children: <Widget>[
        if (hasDivider)
          Container(height: 1, color: Theme.of(context).dividerColor),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: InkWell(
            onTap: () => _onTapThumbnailAndText(),
            onLongPress: () => _onLongPressThumbnailAndText(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ThumbnailWidget(event),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 17, right: 17), // RTL
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        T(
                          event.tvEventTitleLine1,
                          ts,
                          h: 27,
                          alignment: LanguageC.to.centerLeft,
                          trVal: true,
                        ),
                        if (event.tvEventTitleLine2 != '')
                          T(
                            event.tvEventTitleLine2,
                            ts,
                            h: 27,
                            alignment: LanguageC.to.centerLeft,
                            trVal: true,
                          ),
                        const SizedBox(height: 5),
                        T(
                          event.trValYearsAgo(),
                          ts,
                          alignment: LanguageC.to.centerLeft,
                          h: 17,
                          trVal: true,
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  _goToTimeline() {
    MenuItemData item = MenuItemData.fromEvent(event);
    MenuC.to.pushSubPage(
      SubPage.Tarikh_Timeline,
      arguments: {'focusItem': item, 'event': event},
    );
  }

  _onTapThumbnailAndText() {
    if (navPage == NavPage.Tarikh) {
      _goToTimeline();
    } else if (navPage == NavPage.Relics) {
      if (event.isTimeLineEvent) {
        _goToTimeline();
      } else {
        _goToEventDetailsOfRelics(); // doesn't have a time, just go to details
      }
    } else {
      l.E('onTapThumbnailAndText: navPage=${navPage.name} not implemented yet');
    }
  }

  _goToEventDetailsOfTarikh() {
    MenuC.to.pushSubPage(SubPage.Event_Details, arguments: {
      'eventType': EVENT_TYPE.Incident,
      'eventMap': EventC.to.getEventMap(EVENT_TYPE.Incident),
      'trKeyTitleAtInit': event.trKeyTitle,
    });
  }

  _goToEventDetailsOfRelics() {
    MenuC.to.pushSubPage(SubPage.Event_Details, arguments: {
      'eventType': EVENT_TYPE.Relic,
      'eventMap': RelicC.to.getEventMap(
        (event as Relic).relicType,
        FILTER_TYPE.Default,
        null,
      ),
      'trKeyTitleAtInit': event.trKeyTitle,
    });
  }

  _onLongPressThumbnailAndText() {
    if (navPage == NavPage.Tarikh) {
      _goToEventDetailsOfTarikh();
    } else if (navPage == NavPage.Relics) {
      _goToEventDetailsOfRelics();
    } else {
      l.E('onTapThumbnailAndText: navPage=${navPage.name} not implemented yet');
    }
  }
}
