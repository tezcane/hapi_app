import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/event_c.dart';
import 'package:hapi/tarikh/event/thumbnail_detail_widget.dart';
import 'package:hapi/tarikh/main_menu/menu_data.dart';

/// It displays the list of favorites kept by the [EventC], and moves into the
/// timeline when tapping on one of them if event type is Tarikh, otherwise it
/// shows the relic view.
class EventFavoriteUI extends StatelessWidget {
  const EventFavoriteUI(this.eventType, this.navPage);
  final EVENT_TYPE eventType;
  final NavPage navPage;

  @override
  Widget build(BuildContext context) {
    List<Event> eventListFav = EventC.to.getEventListFav(eventType);

    /// If no event has been added to the favorites yet, a placeholder is shown
    /// with a [FlareActor] animation of a broken heart and two lines of text.
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: GetBuilder<EventC>(
          builder: (c) => eventListFav.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 128.0,
                      height: 114.0,
                      margin: const EdgeInsets.only(bottom: 30),
                      child: const FlareActor(
                        'assets/tarikh/flare/Broken Heart.flr',
                        animation: 'Heart Break',
                        shouldClip: false,
                      ),
                    ),
                    T('i.No Favorites', ts, h: 40),
                    const SizedBox(height: 20),
                    T(
                      at(
                        'at.Add favorites in {0} detail pages',
                        [navPage.trKey],
                      ),
                      ts,
                      h: 25,
                      trVal: true,
                    ),
                  ],
                )
              : ListView.builder(
                  itemCount: eventListFav.length,
                  itemBuilder: (BuildContext context, int idx) {
                    Event event = eventListFav[idx];
                    return ThumbnailDetailWidget(
                      event,
                      hasDivider: idx != 0,
                      tapSearchResult: (Event event) {
                        switch (eventType) {
                          case EVENT_TYPE.Incident:
                          case EVENT_TYPE.Era:
                            MenuItemData item = MenuItemData.fromEvent(event);
                            MenuC.to.pushSubPage(
                              SubPage.Tarikh_Timeline,
                              arguments: {'focusItem': item, 'event': event},
                            );
                            break;
                          case EVENT_TYPE.Relic:
                            break;
                        }
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}