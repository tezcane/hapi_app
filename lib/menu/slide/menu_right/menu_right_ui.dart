import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/nav_page_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/menu_controller.dart';
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
    return GetBuilder<MenuController>(
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
                        confettiController:
                            MenuController.to.confettiController(),
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
                        createParticlePath: MenuController.to.drawStar,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController:
                            MenuController.to.confettiController(),
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
            items: navPageValues
                .map(
                  // resize menu icons/text if keyboard shows
                  (nav) => SingleChildScrollView(
                    child: Tooltip(
                      message: nav.navPage.trValTooltip,
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
                                      angle: nav.navPage == NavPage.Relics
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
                                        top: nav.navPage == NavPage.Relics
                                            ? 8.6
                                            : -2.0,
                                        right: -2.0,
                                        child: Transform.rotate(
                                          angle: nav.navPage == NavPage.Relics
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
                                  nav.navPage.trKey,
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  w: kSideMenuWidth,
                                ),
                              ],
                            ),
                          ),
                          GetBuilder<NavPageController>(builder: (c) {
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

/*
// icons for later:
const _dummy = const [
  //Moon/Star/Sun
  Icon(Icons.brightness_2),
  Icon(Icons.brightness_2_outlined),
  Icon(Icons.brightness_3),
  Icon(Icons.brightness_3_outlined),
  Icon(Icons.nights_stay_outlined),
  Icon(Icons.bedtime_outlined),
  Icon(Icons.bedtime_rounded),
  Icon(Icons.star_border),
  Icon(Icons.brightness_7),
  Icon(Icons.brightness_high_outlined),
  Icon(Icons.wb_sunny_outlined),
  Icon(Icons.public_outlined),
  //Prayer time, say no to dunya
  Icon(Icons.public_off_outlined),
  //Shield
  Icon(Icons.security_outlined),
  Icon(Icons.shield),
  Icon(Icons.beenhere_outlined),
  Icon(Icons.verified_user_outlined),
  //Stats
  Icon(Icons.assessment_outlined),
  Icon(Icons.analytics_outlined),
  Icon(Icons.leaderboard_rounded),
  Icon(Icons.bar_chart_outlined),
  //Grid view
  Icon(Icons.view_comfy),
  Icon(Icons.apps_outlined),
  Icon(Icons.dashboard),
  Icon(Icons.dashboard_outlined),
  Icon(Icons.blur_linear_outlined),
  Icon(Icons.blur_on_outlined),
  Icon(Icons.view_module_sharp),
  Icon(Icons.table_chart_rounded),
  Icon(Icons.auto_awesome_mosaic),
  //Account
  Icon(Icons.perm_identity_outlined),
  Icon(Icons.portrait_outlined),
  Icon(Icons.account_circle_outlined),
  Icon(Icons.assignment_ind_outlined),
  //Sunnah work
  Icon(Icons.engineering_outlined),
  //Sunnah fix house
  Icon(Icons.house_outlined),
  //Sunnah Time with Family
  Icon(Icons.family_restroom_outlined),
  Icon(Icons.escalator_warning_outlined),
  Icon(Icons.elderly_outlined),
  Icon(Icons.supervised_user_circle_outlined),
  Icon(Icons.supervisor_account_outlined),
  //Sunnah try to have a baby
  Icon(Icons.pregnant_woman_outlined),
  //Sunnah child care
  Icon(Icons.baby_changing_station_outlined),
  //Sunnah take care of kids
  Icon(Icons.child_care_outlined),
  Icon(Icons.child_friendly_outlined),
  //Time No electronics
  Icon(Icons.phonelink_erase_outlined),
  Icon(Icons.phonelink_off_outlined),
  Icon(Icons.power_off_outlined),
  Icon(Icons.screen_lock_portrait_outlined),
  //Sunnah fix house
  Icon(Icons.plumbing_outlined),
  //Sunnah Call family
  Icon(Icons.connect_without_contact_outlined),
  //Sunnah Sport
  Icon(Icons.pool_outlined),
  Icon(Icons.sports_kabaddi_outlined),
  Icon(Icons.directions_car_outlined), //ride a horse
  Icon(Icons.sports_soccer_outlined),
  Icon(Icons.directions_bike_outlined),
  Icon(Icons.directions_run),
  Icon(Icons.run_circle_outlined),
  Icon(Icons.sports_soccer_sharp),
  Icon(Icons.rowing_outlined),
  //Sunnah take family on trop
  Icon(Icons.rv_hookup_outlined),
  //Sunnah wash hands
  Icon(Icons.do_not_touch_outlined),
  Icon(Icons.soap_outlined),
  Icon(Icons.wash_outlined),
  Icon(Icons.soap),
  Icon(Icons.soap),
  Icon(Icons.clean_hands_outlined),
  //Sunnah ghusul/take shower
  Icon(Icons.bathtub_outlined),
  //Give charity/donate
  Icon(Icons.volunteer_activism),
  Icon(Icons.favorite),
  Icon(Icons.favorite_border_outlined),
  //Share
  Icon(Icons.share_outlined),
  Icon(Icons.account_tree_outlined),
  Icon(Icons.thumb_up_alt_outlined),
  Icon(Icons.thumb_down_outlined),
  //Sunnah fast
  Icon(Icons.restaurant_menu_outlined),
  Icon(Icons.restaurant_outlined),
  //Sunnah visit sick
  Icon(Icons.local_library_outlined), // FOR STUDY QURAN/HADITH
  Icon(Icons.sick),
  Icon(Icons.sick_outlined),
  Icon(Icons.spa_outlined),
  //Sunnah eclipse
  Icon(Icons.fiber_smart_record),
  //Add to list
  Icon(Icons.post_add_outlined),
  Icon(Icons.add_circle_outline),
  // Checked off
  Icon(Icons.check_box_outlined),
  Icon(Icons.check_circle_outline),
  Icon(Icons.verified_outlined),
  Icon(Icons.check_outlined),
  //Warnings
  Icon(Icons.remove_circle_outline),
  Icon(Icons.report_gmailerrorred_outlined),
  Icon(Icons.warning_amber_outlined),
  Icon(Icons.report_problem_outlined),
  Icon(Icons.block_flipped),
  //Download
  Icon(Icons.file_download),
  Icon(Icons.save_alt_outlined),
  Icon(Icons.arrow_circle_down_outlined),
  //Expandable
  Icon(Icons.arrow_drop_down_circle_outlined),
  Icon(Icons.expand_more_outlined),
  Icon(Icons.expand_less_outlined),
  Icon(Icons.swap_vert_outlined),
  // Save
  Icon(Icons.save_outlined),
  // History
  Icon(Icons.restore_outlined),
  Icon(Icons.room_outlined),
  // Time
  Icon(Icons.room_service_outlined),
  Icon(Icons.access_time_outlined),
  Icon(Icons.schedule_outlined),
  Icon(Icons.watch_later_outlined),
  Icon(Icons.snooze_outlined),
  Icon(Icons.alarm_on_sharp),
  Icon(Icons.timer_outlined),
  Icon(Icons.access_alarm_outlined),
  Icon(Icons.timer_off_outlined),
  Icon(Icons.circle_notifications),
  // Settings
  Icon(Icons.settings),
  Icon(Icons.settings_outlined),
  Icon(Icons.settings_applications_outlined),
  Icon(Icons.tune_outlined),
  Icon(Icons.rtt),
  Icon(Icons.rule_outlined),
  //Search
  Icon(Icons.saved_search),
  Icon(Icons.search_outlined),
  Icon(Icons.search_off_outlined),
  //Tools
  Icon(Icons.construction_outlined),
  Icon(Icons.build_outlined),
  Icon(Icons.explore),
  Icon(Icons.thermostat_outlined),
  //Sound
  Icon(Icons.volume_down_outlined),
  Icon(Icons.volume_mute_outlined),
  Icon(Icons.volume_off_outlined),
  Icon(Icons.volume_up_outlined),
  //Other Features
  //Quiz
  Icon(Icons.psychology_outlined),
  //Might need
  Icon(Icons.account_balance_outlined),
  Icon(Icons.refresh_outlined),
  Icon(Icons.remove_red_eye_outlined),
  Icon(Icons.visibility_off_outlined),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
  Icon(Icons.close),
];
*/
