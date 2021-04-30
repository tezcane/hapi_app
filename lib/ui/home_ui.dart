import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hapi/constants/app_routes.dart';
import 'package:hapi/controllers/menu_controller.dart';
import 'package:hapi/ui/components/menu.dart';
import 'package:hapi/ui/components/menu_nav.dart';
import 'package:hapi/ui/quests_ui.dart';

class HomeUI extends StatelessWidget {
  final MenuController c = Get.find();
  final store = GetStorage();

  int _navIdx = _kNavs.length - 2;
  Widget foregroundPage = QuestsUI();
  bool initNeeded = true;

  @override
  Widget build(BuildContext context) {
    if (initNeeded) {
      _navIdx = store.read('lastNavIdx') ?? _navIdx; //Quests
      _navigateToPage(_navIdx); // set foreground to last opened page
      initNeeded = false; //TODO this is a hack but who cares
    }

    return Scaffold(
      body: MenuNav(
        builder: (showMenu) {
          return Scaffold(
            body: Menu(
              onPressed: showMenu,
              foregroundPage: foregroundPage, // Main page
              columnWidget: Column(), // preferably Column
              bottomWidget: Row(), // preferably Row
            ),
          );
        },
        selectedIndexAtInit: _navIdx,
        items: _kNavs
            .map(
              (nav) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      if (nav.page != '/relic')
                        Icon(nav.icon, color: Colors.white, size: 40), //THEME
                      if (nav.page != '/relic')
                        Icon(Icons.star, color: Colors.orange, size: 18),
                      if (nav.page == '/relic')
                        Transform.rotate(
                          angle: 2.8,
                          child: Icon(nav.icon, color: Colors.white, size: 40),
                        ),
                      if (nav.page == '/relic')
                        Positioned(
                          top: 6.7,
                          left: 23.6,
                          //right: 0.0,
                          //bottom: 0.0,
                          child: Transform.rotate(
                            angle: .59,
                            child: Icon(Icons.star,
                                color: Colors.orange, size: 18),
                          ),
                        ),
                    ],
                  ),
                  Text(nav.label), //THEME
                ],
              ),
            )
            .toList(),
        onItemSelected: (value) {
          if (_navIdx == value) {
            print('navIdx selected index did not change, is $value');
          } else {
            _navIdx = value;
            print('selected index changed to $_navIdx');
            //foregroundPage.dispose(); //TODO <- LOOKS LIKE NOT NEEDED
            _navigateToPage(_navIdx);
          }
        },
      ),
    );
  }

  void _navigateToPage(int navIdx) {
    bool didNotFindPage = true;
    for (GetPage getPage in AppRoutes.routes) {
      if (getPage.name == _kNavs[navIdx].page) {
        didNotFindPage = false;
        print('Going to ${_kNavs[navIdx].page}');
        foregroundPage = getPage.page(); // set the foreground in homepage
        store.write('lastNavIdx', navIdx); // save so app restarts at this idx
        break;
      }
    }
    if (didNotFindPage) print('ERROR: page not found "${_kNavs[navIdx].page}"');
  }
}

class Nav {
  const Nav({required this.label, required this.page, required this.icon});
  final String label;
  final String page;
  final IconData icon;
}

const _kNavs = const [
  Nav(label: 'Settings', page: '/setting', icon: Icons.settings_outlined),
//Nav(label: 'Stats', page: '/stat', icon: Icons.assessment_outlined),
//Nav(label: 'Stats', page: '/stat', icon: Icons.analytics_outlined),
//Nav(label: 'Stats', page: '/stat', icon: Icons.leaderboard_rounded),
//Nav(label: 'Stats', page: '/stat', icon: Icons.bar_chart_outlined),
//Nav(label: 'Tools', page: '/tool', icon: Icons.construction_outlined),
//Nav(label: 'Tools', page: '/tool', icon: Icons.build_outlined),
//Nav(label: 'Tools', page: '/tool', icon: Icons.explore),
  Nav(label: 'Tools', page: '/tool', icon: Icons.explore_outlined),
//Nav(label: 'Hadith', page: '/hadith', icon: Icons.local_library_outlined),
  Nav(label: 'Hadith', page: '/hadith', icon: Icons.menu_book_outlined),
//Nav(label: 'Quran', page: '/quran', icon: Icons.menu_book_outlined),
  Nav(label: 'Quran', page: '/quran', icon: Icons.auto_stories),
  Nav(label: 'Tarikh', page: '/tarikh', icon: Icons.history_edu_outlined),
//Nav(label: 'Relics', page: '/relic', icon: Icons.nights_stay_outlined),
//Nav(label: 'Relics', page: '/relic', icon: Icons.bedtime_outlined),
//Nav(label: 'Relics', page: '/relic', icon: Icons.brightness_3),
  Nav(label: 'Relics', page: '/relic', icon: Icons.brightness_3_outlined),
  Nav(label: 'Quests', page: '/quest', icon: Icons.how_to_reg_outlined),
  Nav(label: 'Quests', page: '/quest', icon: Icons.how_to_reg_outlined), //dummy
];

// icons for later:
const _dummy = const [
  //Moon/Star/Sun
  Icon(Icons.brightness_2),
  Icon(Icons.brightness_2_outlined),
  Icon(Icons.brightness_3),
  Icon(Icons.brightness_3_outlined),
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
