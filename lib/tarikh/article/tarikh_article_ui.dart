import 'package:flare_flutter/flare_actor.dart' show FlareActor;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/language/language_controller.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/tarikh/article/timeline_entry_widget.dart';
import 'package:hapi/tarikh/tarikh_controller.dart';
import 'package:hapi/tarikh/timeline/timeline_entry.dart';

/// This widget will paint the article page.
/// It stores a reference to the [TimelineEntry] that contains the relevant information.
class TarikhArticleUI extends StatefulWidget {
  late final TimelineEntry article;

  TarikhArticleUI() {
    article = Get.arguments['article'];
  }

  @override
  _TarikhArticleUIState createState() => _TarikhArticleUIState();
}

/// The [State] for the [TarikhArticleUI] will change based on the [article]
/// parameter that's used to build it.
/// It is stateful because we rely on some information like the title, subtitle, and the article
/// contents to change when a new article is displayed. Moreover the [FlareWidget]s that are used
/// on this page (i.e. the top [TimelineEntryWidget] the favorite button) rely on life-cycle parameters.
class _TarikhArticleUIState extends State<TarikhArticleUI> {
  /// The information for the current page.
  String _labelLowerCase = '';
  String _trValTitle = '';
  String _trValSubTitle = '';
  String _trValArticleMarkdown = '';

  /// This page uses the `flutter_markdown` package, and thus needs its styles to be defined
  /// with a custom objects. This is created in [initState()].
  late MarkdownStyleSheet _markdownStyleSheet;

  /// Whether the [FlareActor] favorite button is active or not.
  /// Triggers a Flare animation upon change.
  bool _isFavorite = false;

  /// This parameter helps control the Newton animations.
  /// Test it out yourself! =)
  Offset? _interactOffset;

  /// Set up the markdown style and the local field variables for this page.
  @override
  initState() {
    super.initState();

    _labelLowerCase = widget.article.label.toLowerCase();

    TextStyle h1 = Get.theme.textTheme.headline4!
        .copyWith(fontSize: 32.0, height: 1.625, fontWeight: FontWeight.bold);
    TextStyle h2 = Get.theme.textTheme.headline5!
        .copyWith(fontSize: 24.0, height: 2, fontWeight: FontWeight.bold);
    TextStyle style =
        Get.theme.textTheme.headline6!.copyWith(fontSize: 17.0, height: 1.5);
    TextStyle strong = Get.theme.textTheme.headline6!
        .copyWith(fontSize: 17.0, height: 1.5, fontWeight: FontWeight.bold);
    TextStyle em = Get.theme.textTheme.headline6!
        .copyWith(fontSize: 17.0, height: 1.5, fontStyle: FontStyle.italic);
    _markdownStyleSheet = MarkdownStyleSheet(
      a: style,
      p: style,
      code: style,
      h1: h1,
      h2: h2,
      h3: style,
      h4: style,
      h5: style,
      h6: style,
      em: em,
      strong: strong,
      blockquote: style,
      img: style,
      blockSpacing: 20.0,
      listIndent: 20.0,
      blockquotePadding: const EdgeInsets.all(20.0),
    );
    loadMarkdown();
    setState(() {
      _trValTitle = widget.article.trValTitle;
      _trValSubTitle = widget.article.trValYearsAgo();
    });
  }

  /// Load the markdown file from the assets and set the contents of the page to its value.
  void loadMarkdown() async {
    String trValArticleMarkdown =
        await LanguageController.to.trValTarikhArticle(widget.article.label);
    setState(() {
      _trValArticleMarkdown = trValArticleMarkdown;
    });
  }

  /// This widget is wrapped in a [Scaffold] to have the classic Material Design visual layout structure.
  /// It uses the [BlocProvider] to find out if this element is part of the favorites, to have the icon properly set up.
  /// A [SingleChildScrollView] contains a [Column] that lays out the [TimelineEntryWidget] on top, and the [MarkdownBody]
  /// right below it.
  /// A [GestureDetector] is used to control the [TimelineEntryWidget], if it allows it (...try Newton!)
  @override
  Widget build(BuildContext context) {
    EdgeInsets devicePadding = MediaQuery.of(context).padding;
    List<TimelineEntry> favs = TarikhController.to.eventFavorites;
    bool isFav =
        favs.any((TimelineEntry e) => e.label.toLowerCase() == _labelLowerCase);
    return FabSubPage(
      subPage: SubPage.Tarikh_Article,
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(height: devicePadding.top),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      GestureDetector(
                          onPanStart: (DragStartDetails details) {
                            setState(() {
                              _interactOffset = details.globalPosition;
                            });
                          },
                          onPanUpdate: (DragUpdateDetails details) {
                            setState(() {
                              _interactOffset = details.globalPosition;
                            });
                          },
                          onPanEnd: (DragEndDetails details) {
                            setState(() {
                              _interactOffset = null;
                            });
                          },
                          child: SizedBox(
                              height: 280,
                              child: TimelineEntryWidget(
                                  isActive: true,
                                  timelineEntry: widget.article,
                                  interactOffset: _interactOffset))),
                      Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _trValTitle,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 25.0,
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    _trValSubTitle,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      fontSize: 17.0,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              child: Transform.translate(
                                offset: const Offset(15.0, 0.0),
                                child: Container(
                                  height: 60.0,
                                  width: 60.0,
                                  padding: const EdgeInsets.all(15.0),

                                  /// Check out the widget at:
                                  /// https://www.2dimensions.com/a/pollux/files/flare/heart-simple/preview
                                  child: FlareActor(
                                    'assets/tarikh/flare/Favorite.flr',
                                    animation:
                                        isFav ? 'Favorite' : 'Unfavorite',
                                    shouldClip: false,
                                    color: Colors.pinkAccent,
                                    // color: isFav
                                    //     ? Colors.pinkAccent
                                    //     : Theme.of(context)
                                    //         .textTheme
                                    //         .headline6!
                                    //         .color,
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                                if (_isFavorite) {
                                  TarikhController.to
                                      .addFavorite(widget.article);
                                } else {
                                  TarikhController.to
                                      .removeFavorite(widget.article);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20, bottom: 20),
                        height: 1,
                        color: Theme.of(context).dividerColor,
                      ),
                      MarkdownBody(
                        data: _trValArticleMarkdown,
                        styleSheet: _markdownStyleSheet,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
