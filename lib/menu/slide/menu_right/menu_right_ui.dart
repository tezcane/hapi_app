import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controller/nav_page_c.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/menu_bottom.dart';
import 'package:hapi/menu/slide/menu_bottom/menu_bottom_ui.dart';
import 'package:hapi/menu/slide/menu_right/menu_right.dart';
import 'package:hapi/menu/slide/menu_right/nav_page.dart';

class MenuRightUI extends StatelessWidget {
  const MenuRightUI({
    Key? key,
    required this.navPage,
    required this.foregroundPage,
    required this.settingsWidgets,
  }) : super(key: key);

  final NavPage navPage;
  final Widget foregroundPage;
  final List<Widget?> settingsWidgets;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MenuC>(
      builder: (c) => IgnorePointer(
        ignoring: c.isScreenDisabled,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          body: MenuRight(
            initNavPage: navPage,
            settingsWidgets: settingsWidgets,
            builder: () {
              return MenuBottom(
                navPage: navPage,
                foregroundPage: Stack(
                  children: [
                    IgnorePointer(
                      // disable UI when menu showing:
                      ignoring: c.isMenuShowing,
                      child: foregroundPage, // Main page
                    ),
                    Align(
                      // TODO asdf move the confetti away from here
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: MenuC.to.confettiController(),
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        numberOfParticles: 5,
                        maximumSize: const Size(50, 50),
                        minimumSize: const Size(20, 20),
                        colors: const [
                          Colors.red,
                          Colors.pink,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.indigo,
                          Colors.purple,
                        ], // manually specify the colors to be used
                        createParticlePath: MenuC.to.drawStar,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: MenuC.to.confettiController(),
                        blastDirectionality: BlastDirectionality.explosive,
                        shouldLoop: false,
                        numberOfParticles: 5,
                        maximumSize: const Size(10, 10),
                        minimumSize: const Size(3, 3),
                        colors: const [
                          Colors.red,
                          Colors.pink,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.indigo,
                          Colors.purple,
                        ], // manually specify the colors to be used
                        //createParticlePath: MenuController.to.drawStar,
                      ),
                    ),
                  ],
                ),
                bottomWidget: MenuBottomUI(), // preferably Row
                settingsWidgets: settingsWidgets, // preferably Column
              );
            },
            items: (MainC.to.isSignedIn
                    ? navPageValuesSignedIn
                    : navPageValuesSignedOut) // TODO clean up?
                .map(
                  // Allows menu tile to scroll in landscape or keyboard modes
                  (nav) => SingleChildScrollView(
                    child: Tooltip(
                      message: nav.navPage.tvTooltip,
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    Transform.rotate(
                                      angle: nav.navPage == NavPage.Alathar
                                          ? 2.8
                                          : 0,
                                      child: Icon(
                                        nav.icon,
                                        color: Colors.white,
                                        size: 40,
                                      ),
                                    ),
                                    if (c.getShowBadge(navPage))
                                      Positioned(
                                        top: nav.navPage == NavPage.Alathar
                                            ? 8.6
                                            : -2.0,
                                        right: -2.0,
                                        child: Transform.rotate(
                                          angle: nav.navPage == NavPage.Alathar
                                              ? .59
                                              : 0,
                                          child: const Icon(
                                            Icons.star,
                                            color: Colors.orange,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                T(
                                  nav.navPage.tkIsimA,
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  w: kSideMenuWidth,
                                ),
                              ],
                            ),
                          ),
                          GetBuilder<NavPageC>(builder: (c) {
                            Color showSettingsColor = Colors.transparent;
                            if (nav.navPage == navPage &&
                                settingsWidgets[c.getLastIdx(nav.navPage)] !=
                                    null) {
                              showSettingsColor = Colors.orange;
                            }
                            return Align(
                              alignment: Alignment.topRight,
                              child: Icon(
                                Icons.settings_applications_outlined,
                                color: showSettingsColor,
                                size: 27,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
