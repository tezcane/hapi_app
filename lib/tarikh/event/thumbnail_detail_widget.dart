import 'package:flutter/material.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_c.dart';
import 'package:hapi/tarikh/event/event.dart';
import 'package:hapi/tarikh/event/thumbnail_widget.dart';

/// This callback allows an [event] to display on the [TarikhTimelineUI] and
/// position it to the right start/end time for the [event].
typedef TapSearchResultCallback = Function(Event event);

/// This widget lays out nicely the [event] provided.
///
/// It shows the [ThumbnailWidget] for that event on the left, and the event's
/// label and date of the event on its immediate right.
///
/// This widget is used while displaying the search results in the [MainMenuWidget], and in the
/// [FavoritesPage] widget.
class ThumbnailDetailWidget extends StatelessWidget {
  const ThumbnailDetailWidget(
    this.event, {
    this.hasDivider = true,
    this.tapSearchResult,
  });
  final Event event;

  /// Whether to show a divider line on the bottom of this widget. Defaults to `true`.
  final bool hasDivider;

  /// Callback to navigate to the timeline (see [MainMenuWidget._tapSearchResult()]).
  final TapSearchResultCallback? tapSearchResult;

  /// Use [Material] & [InkWell] to show a Material Design ripple effect on the row.
  /// [InkWell] provides also a callback for custom onTap behavior.
  ///
  /// The widget is laid out with a [Column] that lays out the contents of the event, and the divider,
  /// and a [Row], which contains the [ThumbnailWidget], and the event information.
  @override
  Widget build(BuildContext context) {
    String trValLine1 = a(event.trKeyTitle);
    String? trValLine2;
    if (event.titleLineCount > 1) {
      List<String> lines = trValLine1.split('\n');
      trValLine1 = lines[0];
      trValLine2 = lines[1];
    }

    // TODO was return Material(color: Colors.transparent, child:
    return InkWell(
      onTap: () => tapSearchResult != null ? tapSearchResult!(event) : null,
      child: Column(
        children: <Widget>[
          if (hasDivider)
            Container(height: 1, color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ThumbnailWidget(event),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 17.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        T(
                          trValLine1,
                          ts,
                          h: 27,
                          alignment: LanguageC.to.centerLeft,
                          trVal: true,
                        ),
                        if (trValLine2 != null)
                          T(
                            trValLine2,
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
        ],
      ),
    );
  }
}
