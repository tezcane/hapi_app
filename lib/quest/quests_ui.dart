import 'dart:math' as math;

import 'package:bottom_bar/bottom_bar.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/menu/toggle_switch.dart';
import 'package:hapi/quest/athan/CalculationMethod.dart';
import 'package:hapi/quest/athan/Prayer.dart';
import 'package:hapi/quest/quest_card.dart';
import 'package:hapi/quest/quest_controller.dart';
import 'package:hapi/quest/time_controller.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/ui/settings_ui.dart';
import 'package:im_animations/im_animations.dart';

class QuestsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FabNavPage(
      navPage: NavPage.QUESTS,
      settingsWidget: ActiveQuestSettings(),
      bottomWidget: HapiShare(),
      foregroundPage: QuestBottomBar(),
    );
  }
}

class ActiveQuestSettings extends StatelessWidget {
  final TextStyle textStyleTitle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
  final TextStyle textStyleBtn =
      TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuestController>(
      builder: (c) {
        return Column(
          // TODO tune
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tooltip(
              message: 'Select the salah time calculation method',
              child: Text(
                'Calculation Method',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            DropdownButton<int>(
              isExpanded: true,
              isDense: false,
              value: c.salahCalcMethod,
              //icon: const Icon(Icons.arrow_downward),
              iconEnabledColor: Colors.white, //const Color(0xFF268E0D),
              //focusColor: const Color(0xFF268E0D),
              iconSize: 25,
              style: textStyleBtn,
              dropdownColor: Colors.grey,
              //itemHeight: 55.0,
              menuMaxHeight: 700.0,
              underline: Container(
                height: 0,
              ),
              onChanged: (int? newValue) {
                c.salahCalcMethod = newValue!;
              },
              items: List<int>.generate(SalahMethod.values.length - 1, (i) => i)
                  .map<DropdownMenuItem<int>>(
                (int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Container(
                      color: const Color(0xFF268E0D)
                          .withOpacity(c.salahCalcMethod == value ? 1 : 0),
                      child: Center(
                        child: Text(
                          SalahMethod.values[value].name(),
                          textAlign: TextAlign.center,
                          //textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
            const SizedBox(height: 15),
            Tooltip(
              message: 'Show/Hide Sunnah actions',
              child: Text(
                'Show Sunnah:',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            ShowSunnahSettings(
              btnHeight: 25,
              btnGap: 0,
              fontSize: 14,
              lrPadding: 0,
            ),
            const SizedBox(height: 15),
            Tooltip(
              message: 'Show/Hide Labels and Sunnah Key',
              child: Text(
                'Labels/Key',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 50.0,
              fontSize: 14,
              initialLabelIndex: c.showSunnahKeys ? 0 : 1,
              labels: ['Show', 'Hide'],
              //cornerRadius: 20.0,
              activeBgColor: const Color(0xFF268E0D),
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey, //const Color(0xFF1D1E33),
              inactiveFgColor: Colors.white,
              onToggle: (index) {
                if (index == 0) {
                  c.showSunnahKeys = true;
                } else {
                  c.showSunnahKeys = false;
                }
              },
            ),
            const SizedBox(height: 15),
            Tooltip(
              message:
                  "Ulema opinions on Asr start time are when an object's shadow is either 2 times its lengths (later) or 1 times its length (earlier)",
              child: Text(
                'Asr Start',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 50.0,
              fontSize: 14,
              initialLabelIndex: c.salahAsrSafe ? 0 : 1,
              labels: ['Later', 'Earlier'],
              //cornerRadius: 20.0,
              activeBgColor: const Color(0xFF268E0D),
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey, //const Color(0xFF1D1E33),
              inactiveFgColor: Colors.white,
              onToggle: (index) {
                if (index == 0) {
                  c.salahAsrSafe = true;
                } else {
                  c.salahAsrSafe = false;
                }
              },
            ),
            const SizedBox(height: 15),
            Tooltip(
              message:
                  "Ulema opinions on kerahat times are around 40 or 20 for sunset and sunrise kerahat times and around 30 or 15 minutes for the noon kerahat time",
              child: Text(
                'Kerahat Times (Minutes)',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 50.0,
              fontSize: 14,
              initialLabelIndex: c.salahKerahatSafe ? 0 : 1,
              labels: ['40/30/40', '20/15/20'],
              //cornerRadius: 20.0,
              activeBgColor: const Color(0xFF268E0D),
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey, //const Color(0xFF1D1E33),
              inactiveFgColor: Colors.white,
              onToggle: (index) {
                if (index == 0) {
                  c.salahKerahatSafe = true;
                } else {
                  c.salahKerahatSafe = false;
                }
              },
            ),
            const SizedBox(height: 15),
            Tooltip(
              message:
                  "Choice between showing Jummah Salah on Friday (if you go to Jummah) or set to Dhuhr which acts like non-Jummah days",
              child: Text(
                'Friday Default',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 50.0,
              fontSize: 14,
              initialLabelIndex: c.showJummahOnFriday ? 0 : 1,
              labels: ['Jummah', 'Dhuhr'],
              //cornerRadius: 20.0,
              activeBgColor: const Color(0xFF268E0D),
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey, //const Color(0xFF1D1E33),
              inactiveFgColor: Colors.white,
              onToggle: (index) {
                if (index == 0) {
                  c.showJummahOnFriday = true;
                } else {
                  c.showJummahOnFriday = false;
                }
              },
            ),
            const SizedBox(height: 15),
            Tooltip(
              message:
                  "Gives choice between 12 hour clock (AM/PM) or 24 hour clock (military time)",
              child: Text(
                'Clock Type',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 50.0,
              fontSize: 14,
              initialLabelIndex: c.show12HourClock ? 0 : 1,
              labels: ['12 hour', '24 hour'],
              //cornerRadius: 20.0,
              activeBgColor: const Color(0xFF268E0D),
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey, //const Color(0xFF1D1E33),
              inactiveFgColor: Colors.white,
              onToggle: (index) {
                if (index == 0) {
                  c.show12HourClock = true;
                } else {
                  c.show12HourClock = false;
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class ShowSunnahSettings extends StatelessWidget {
  ShowSunnahSettings({
    required this.btnHeight,
    required this.btnGap,
    required this.fontSize,
    required this.lrPadding, // left right padding
  });
  final double btnHeight;
  final double btnGap;
  final double fontSize;
  final double lrPadding;

  @override
  Widget build(BuildContext context) {
    // final TextStyle textStyleTitle = TextStyle(
    //     color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize);
    final TextStyle textStyleBtnMuak = TextStyle(
        color: Colors.green, fontWeight: FontWeight.bold, fontSize: fontSize);
    final TextStyle textStyleBtnNafl = TextStyle(
        color: Colors.amber.shade700,
        fontWeight: FontWeight.bold,
        fontSize: fontSize);
    final TextStyle textStyleBtnDuha = TextStyle(
        color: Colors.yellow.shade300,
        fontWeight: FontWeight.bold,
        fontSize: fontSize);
    final TextStyle textStyleBtnLayl = TextStyle(
        color: Colors.pinkAccent,
        fontWeight: FontWeight.bold,
        fontSize: fontSize);

    return GetBuilder<QuestController>(
      builder: (c) {
        return Column(
          // TODO tune
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Text(
            //   "Sunnah Key:",
            //   style: textStyleTitle,
            // ),
            SizedBox(height: btnGap > 2 ? btnGap - 2 : 0),
            InkWell(
              onTap: () {
                c.toggleShowSunnahMuak();
              },
              child: Padding(
                padding: EdgeInsets.only(left: lrPadding, right: lrPadding),
                child: Container(
                  height: btnHeight,
                  //color: Colors.green.withOpacity(c.showSunnahMuak ? 1 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 3),
                      c.showSunnahMuak
                          ? Icon(
                              Icons.check_box_outlined,
                              size: 12,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                      Text(
                        'Muakkadah',
                        style: textStyleBtnMuak,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: btnGap),
            InkWell(
              onTap: () {
                c.toggleShowSunnahNafl();
              },
              child: Padding(
                padding: EdgeInsets.only(left: lrPadding, right: lrPadding),
                child: Container(
                  height: btnHeight,
                  // color: Colors.amber.shade700
                  //     .withOpacity(c.showSunnahNafl ? 1 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 3),
                      c.showSunnahNafl
                          ? Icon(
                              Icons.check_box_outlined,
                              size: 12,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                      Text(
                        'Nafl',
                        style: textStyleBtnNafl,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: btnGap),
            InkWell(
              onTap: () {
                c.toggleShowSunnahDuha();
              },
              child: Padding(
                padding: EdgeInsets.only(left: lrPadding, right: lrPadding),
                child: Container(
                  height: btnHeight,
                  // color: Colors.yellow.shade300
                  //     .withOpacity(c.showSunnahDuha ? 1 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 3),
                      c.showSunnahDuha
                          ? Icon(
                              Icons.check_box_outlined,
                              size: 12,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                      Text(
                        'Duha',
                        style: textStyleBtnDuha,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: btnGap),
            InkWell(
              onTap: () {
                c.toggleShowSunnahLayl();
              },
              child: Padding(
                padding: EdgeInsets.only(left: lrPadding, right: lrPadding),
                child: Container(
                  height: btnHeight,
                  // color: Colors.pinkAccent.withOpacity(
                  //   c.showSunnahLayl ? 1 : 0,
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 3),
                      c.showSunnahLayl
                          ? Icon(
                              Icons.check_box_outlined,
                              size: 12,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.check_box_outline_blank_outlined,
                              size: 12,
                              color: Colors.white,
                            ),
                      Text(
                        'Layl Ibadah',
                        style: textStyleBtnLayl,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class QuestBottomBar extends StatefulWidget {
  @override
  _QuestBottomBarState createState() => _QuestBottomBarState();
}

class _QuestBottomBarState extends State<QuestBottomBar> {
//final TextEditingController _textEditingController = TextEditingController();
  int _currentPage = 0; // TODO turn off settings on other quest pages
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: [
          QuestsActive(),
          Container(color: AppThemes.logoBackground),
          Container(color: AppThemes.logoBackground),
          Container(color: AppThemes.logoBackground),
          // UserQuest(textEditingController: _textEditingController),
        ],
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
      ),
      bottomNavigationBar: Container(
        color: AppThemes.logoBackground,
        child: Row(
          children: [
            BottomBar(
              selectedIndex: _currentPage,
              onTap: (int index) {
                _pageController.jumpToPage(index);
                setState(() => _currentPage = index);
              },
              items: [
                BottomBarItem(
                  icon: Icon(Icons.how_to_reg_outlined),
                  title: Text('Active Quests'),
                  activeColor: Colors.blue,
                  inactiveColor: Colors.white,
                ),
                BottomBarItem(
                  icon: Icon(Icons.brightness_high_outlined),
                  title: Text('Daily Quests'),
                  activeColor: Colors.greenAccent.shade700,
                  //darkActiveColor: Colors.greenAccent.shade400,
                  inactiveColor: Colors.white,
                ),
                BottomBarItem(
                  icon: Icon(Icons.timer_outlined),
                  title: Text('Time Quests'),
                  activeColor: Colors.orange,
                  //darkActiveColor: Colors.greenAccent.shade400,
                  inactiveColor: Colors.white,
                ),
                BottomBarItem(
                  icon: Transform.rotate(
                    angle: 2.8,
                    child: Icon(Icons.brightness_3_outlined),
                  ),
                  title: Text('hapi Quests'),
                  activeColor: Colors.red,
                  //darkActiveColor: Colors.red.shade400,
                  inactiveColor: Colors.white,
                ),
                // BottomBarItem(
                //   icon: Icon(Icons.add_circle_outline),
                //   title: Text('Add'),
                //   activeColor: Colors.orange,
                // ),
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

class UserQuest extends StatelessWidget {
  const UserQuest({
    Key? key,
    required TextEditingController textEditingController,
  })  : _textEditingController = textEditingController,
        super(key: key);

  final TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      builder: (controller) => Scaffold(
        appBar: AppBar(
          title: Text(
            'hapi',
            style: TextStyle(
              fontFamily: 'Lobster',
              color: AppThemes.logoText,
              fontSize: 28,
            ),
          ),
          actions: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Get.to(() => SettingsUI());
                }),
          ],
        ),
        body: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            AddQuest(
                authController: controller,
                textEditingController: _textEditingController),
            GetX<QuestController>(
              builder: (QuestController c) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: c.quests.length,
                    itemBuilder: (_, index) {
                      return QuestCard(quest: c.quests[index]);
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class AddQuest extends StatelessWidget {
  const AddQuest({
    Key? key,
    required AuthController authController,
    required TextEditingController textEditingController,
  })  : _authController = authController,
        _textEditingController = textEditingController,
        super(key: key);

  final AuthController _authController;
  final TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _textEditingController,
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                if (_textEditingController.text != "") {
                  Database().addQuest(_textEditingController.text,
                      _authController.firestoreUser.value!.uid);
                  _textEditingController.clear();
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

class QuestsActive extends StatelessWidget {
  static const double SALAH_ACTIONS_HEIGHT = 62;

  static const TextStyle textStyleAppBar =
      const TextStyle(fontSize: 9.5, color: Colors.white);
  static const TextStyle textStyleAppBarTime =
      const TextStyle(fontSize: 24.0, color: Colors.white);

  static const Color textColor = Colors.white;
  static const TextStyle textStyleWhite = const TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.white);
  static const TextStyle textStyleFard = const TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.red);
  static const TextStyle textStyleMuak = const TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.green);
  static final TextStyle textStyleNafl = TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
      color: Colors.amber.shade700);
  static final TextStyle textStyleDuha = TextStyle(
      fontSize: 17.0,
      fontWeight: FontWeight.bold,
      color: Colors.yellow.shade300);

  static final TextStyle textStyleQiyam = TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.cyan.shade300);
  static final TextStyle textStyleTahajjud = TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.blue.shade100);
  static const TextStyle textStyleWitr = TextStyle(
      fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.pinkAccent);

  static final FlipCardController flipCardControllerFajr = FlipCardController();
  static final FlipCardController flipCardControllerDhuhr =
      FlipCardController();

  GetBuilder salahAppBar() {
    return GetBuilder<QuestController>(
      builder: (c) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: [
                              Text(
                                  c.prayerTimes!.currPrayerName
                                      .toString()
                                      .split('.')
                                      .last
                                      .replaceAll('_', ' '),
                                  style: textStyleAppBar),
                              Text(' ends', style: textStyleAppBar),
                              SizedBox(width: 1),
                              Icon(Icons.arrow_right_alt_rounded,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 5),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                  c.prayerTimes!.nextPrayerName
                                      .toString()
                                      .split('.')
                                      .last
                                      .replaceAll('_', ' '),
                                  style: textStyleAppBar),
                              Text(' in', style: textStyleAppBar),
                              SizedBox(width: 1),
                              Icon(Icons.arrow_right_alt_rounded,
                                  color: Colors.white, size: 12),
                              SizedBox(width: 5),
                            ],
                          ),
                        ],
                      ),
                      GetX<TimeController>(builder: (TimeController c) {
                        return Row(
                          children: [
                            Text(c.timeToNextPrayer,
                                style: textStyleAppBarTime),
                          ],
                        );
                      }),
                    ],
                  ),
                  //if (c.showSunnahKeys) SizedBox(height: 1),
                  SizedBox(height: 5.5),
                  if (c.showSunnahKeys)
                    Row(
                      children: [
                        Expanded(
                          flex: 1000,
                          child: Column(
                            children: [
                              Text(
                                'Before',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                              Text(
                                'Sunnah',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1000,
                          child: Column(
                            children: [
                              Text(
                                'Fard',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                              Text(
                                'Rakat',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                            ],
                          ),
                        ),
                        Expanded(flex: 100, child: const Text('')),
                        Expanded(
                          flex: 1900,
                          child: Column(
                            children: [
                              Text(
                                'After',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                              Text(
                                'Sunnah',
                                textAlign: TextAlign.center,
                                style: textStyleAppBar,
                              ),
                            ],
                          ),
                        ),
                        Expanded(flex: 400, child: const Text('')),
                      ],
                    )
                ],
              ),
            ),
            Expanded(
              flex: c.showSunnahKeys ? 1600 : 0,
              child: c.showSunnahKeys
                  ? ShowSunnahSettings(
                      btnHeight: 19,
                      btnGap: 0,
                      fontSize: 9,
                      lrPadding: 0,
                    )
                  : const Text(''),
            ),
          ],
        );
      },
    );
  }

  static String getTime(DateTime? time) {
    return getTimeRange(time, null);
  }

  static String getTimeRange(DateTime? startTime, DateTime? endTime) {
    if (startTime == null) {
      return '-';
    }

    //"${d.year.toString()}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')} ${d.hour.toString()}-${d.minute.toString()}";

    int startHour = startTime.hour;
    int startMinute = startTime.minute;
    String startAmPm = '';
    if (cQust.show12HourClock) {
      if (startHour > 12) {
        startHour -= 12;
        startAmPm = ' PM';
      } else {
        startAmPm = ' AM';
      }
    }

    String endTimeString = '';
    if (endTime != null) {
      int endHour = endTime.hour;
      int endMinute = endTime.minute;
      String endAmPm = '';

      if (cQust.show12HourClock) {
        if (endHour > 12) {
          endHour -= 12;
          endAmPm = ' PM';
        } else {
          endAmPm = ' AM';
        }
        endTimeString =
            '-${endHour.toString()}:${endMinute.toString().padLeft(2, '0')}$endAmPm';

        if (startAmPm == endAmPm) {
          startAmPm = ''; // if AM/PM are same, don't show twice
        }
      } else {
        endTimeString =
            '-${endHour.toString()}:${endMinute.toString().padLeft(2, '0')}';
      }
    }

    return '${startHour.toString()}:${startMinute.toString().padLeft(2, '0')}$startAmPm$endTimeString';
  }

  /// Used by Asr, Maghrib, Isha (All but fajr/dhur is passed in here).
  /// Note: returns SliverPersistentHeader.
  SliverPersistentHeader actionsSalah({
    required final String rakatFard,
    required final Prayer fardSalah,
    required final DateTime salahTimeStart,
    final DateTime? salahTimeEnd,
    final String rakatMuakBefore = '',
    final String rakatMuakAfter = '',
    final String rakatNaflBefore = '',
    final String rakatNaflAfter = '',
  }) {
    return SliverPersistentHeader(
      pinned: fardSalah ==
          cQust.prayerTimes!.currPrayerName, // TODO cQust needed i believe
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: actionsSalahRow(
          rakatFard: rakatFard,
          fardSalah: fardSalah,
          salahTimeStart: salahTimeStart,
          salahTimeEnd: salahTimeEnd,
          rakatMuakBefore: rakatMuakBefore,
          rakatMuakAfter: rakatMuakAfter,
          rakatNaflBefore: rakatNaflBefore,
          rakatNaflAfter: rakatNaflAfter,
          isJummahMode: false,
        ),
      ),
    );
  }

  /// Needed so fajr/fajr_tomorrow and dhur/jummah can use FlipCard().
  /// Note: returns GetBuilder.
  GetBuilder<QuestController> actionsSalahRow({
    required final String rakatFard,
    required final Prayer fardSalah,
    required final DateTime salahTimeStart,
    final DateTime? salahTimeEnd,
    final String rakatMuakBefore = '',
    final String rakatMuakAfter = '',
    final String rakatNaflBefore = '',
    final String rakatNaflAfter = '',
    required final bool isJummahMode,
    final FlipCardController? flipCardController,
  }) {
    return GetBuilder<QuestController>(
      builder: (c) {
        return Column(
          children: [
            ///
            /// First row is title of salah, with times, etc.
            ///
            salahHeader(
              fardSalah,
              c,
              isJummahMode,
              salahTimeStart,
              !c.showSunnahDuha || fardSalah == Prayer.Fajr_Tomorrow
                  ? salahTimeEnd
                  : null,
              flipCardController,
            ),
            Expanded(
              child: Row(
                children: [
                  ///
                  /// 1 of 4. sunnah before fard column items:
                  ///
                  if (rakatMuakBefore != '')
                    SalahActionCellStart(
                      c.showSunnahMuak ? rakatMuakBefore : '',
                      textStyleMuak,
                      true,
                    ),
                  if (rakatNaflBefore != '')
                    SalahActionCellStart(
                      c.showSunnahNafl ? rakatNaflBefore : '',
                      textStyleNafl,
                      true,
                    ),
                  if (fardSalah == Prayer.Maghrib)
                    SalahActionCellStart(
                      '',
                      textStyleNafl,
                      false,
                    ),

                  ///
                  /// 2 of 4. fard column item:
                  ///
                  SalahActionCellCenter(
                    rakatFard,
                    textStyleFard,
                    true,
                  ),

                  ///
                  /// 3 of 4. Option 1: sunnah after fard column items:
                  ///
                  if (fardSalah == Prayer.Asr)
                    SalahActionCellCenterWidget(
                      IconThikr(),
                      true,
                    ),
                  if (fardSalah == Prayer.Asr)
                    SalahActionCellCenterWidget(
                      Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 25,
                      ),
                      true,
                    ),

                  ///
                  /// 3 of 4. Option 2: sunnah after fard column items:
                  ///
                  if (fardSalah == Prayer.Asr)
                    SalahActionCellEndWidget(
                      SunCell(IconSunset(), 'Evening Adhkar',
                          c.prayerTimes!.sunSetting, c.prayerTimes!.maghrib),
                      true,
                      flex: 2000,
                    ),

                  if (rakatMuakAfter != '' || fardSalah != Prayer.Asr)
                    SalahActionCellCenter(
                      c.showSunnahMuak ? rakatMuakAfter : '',
                      textStyleMuak,
                      true,
                    ),
                  if (rakatNaflAfter != '' || fardSalah != Prayer.Asr)
                    SalahActionCellCenter(
                      c.showSunnahNafl ? rakatNaflAfter : '',
                      textStyleNafl,
                      true,
                    ),

                  ///
                  /// 4 of 4. Thikr and Dua after fard:
                  ///
                  if (fardSalah != Prayer.Asr)
                    SalahActionCellCenterWidget(
                      IconThikr(),
                      true,
                    ),
                  if (fardSalah != Prayer.Asr)
                    SalahActionCellEndWidget(
                      Icon(
                        Icons.volunteer_activism,
                        color: Colors.white,
                        size: 25,
                      ),
                      true,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  SliverPersistentHeader actionsDuha(QuestController c) {
    return SliverPersistentHeader(
      // TODO cQust needed i believe
      pinned: Prayer.Sunrise == c.prayerTimes!.currPrayerName ||
          Prayer.Duha == c.prayerTimes!.currPrayerName ||
          Prayer.Zawal == c.prayerTimes!.currPrayerName,
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: Column(
          children: [
            ///
            /// First row is title with times, etc.
            ///
            salahHeader(
              Prayer.Duha,
              c,
              false,
              c.prayerTimes!.sunrise,
              null,
              null,
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SalahActionCellStartWidget(
                    SunCell(
                      IconSunrise(),
                      'Morning Adhkar',
                      c.prayerTimes!.sunrise,
                      c.prayerTimes!.duha,
                    ),
                    true,
                    flex: 2000,
                  ),
                  SalahActionCellCenter(
                    'Ishraq',
                    textStyleDuha,
                    true,
                  ),
                  SalahActionCellCenter(
                    'Duha',
                    textStyleDuha,
                    true,
                  ),
                  SalahActionCellEndWidget(
                    SunCell(
                      Icon(
                        Icons.brightness_7_outlined,
                        color: Colors.yellow,
                        size: 18,
                      ),
                      "Zawal",
                      c.prayerTimes!.zawal,
                      c.prayerTimes!.dhuhr,
                    ),
                    true,
                    flex: 2000,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPersistentHeader actionsLaylIbadah({
    required final Prayer fardSalah,
    final DateTime? salahTimeStart, // TODO
    final DateTime? salahTimeEnd,
  }) {
    return SliverPersistentHeader(
      pinned: fardSalah ==
          cQust.prayerTimes!.currPrayerName, // TODO cQust needed i believe
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: GetBuilder<QuestController>(
          builder: (c) {
            return Column(
              children: [
                ///
                /// First row is title with times, etc.
                ///
                salahHeader(
                  Prayer.Isha, // 'Layl Ibadah' TODO
                  c,
                  false,
                  c.prayerTimes!.lastThirdOfNight,
                  null,
                  null,
                ),
                Expanded(
                  child: Row(
                    children: [
                      SalahActionCellStart('Qiyam', textStyleQiyam, true),

                      ///
                      /// Thikr and Dua before bed:
                      ///
                      SalahActionCellCenterWidget(IconThikr(), true),
                      SalahActionCellCenterWidget(
                          Icon(
                            Icons.volunteer_activism,
                            color: Colors.white,
                            size: 25,
                          ),
                          true),

                      ///
                      /// Tahhajud and Witr after waking up
                      ///
                      SalahActionCellCenter('Sleep', textStyleWhite, true),
                      SalahActionCellCenter(
                          'Tahajjud', textStyleTahajjud, true),
                      SalahActionCellEnd('Witr', textStyleWitr, true),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  SliverPersistentHeader spacingHeader(Prayer fardSalah) {
    return SliverPersistentHeader(
      pinned: fardSalah == cQust.prayerTimes!.currPrayerName,
      delegate: _SliverAppBarDelegate(
        minHeight: 5.0,
        maxHeight: 5.0,
        child: Container(
          color: AppThemes.logoBackground,
        ),
      ),
    );
  }

  SliverPersistentHeader sliverSpaceHeader(bool pinned) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: 5.0,
        maxHeight: 5.0,
        child: Container(
          color: AppThemes.logoBackground,
        ),
      ),
    );
  }

  SliverPersistentHeader sliverSpaceHeader2(bool pinned) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _SliverAppBarDelegate(
        minHeight: 100.0,
        maxHeight: 100.0,
        child: Container(
          color: AppThemes.logoBackground,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuestController>(builder: (c) {
      if (c.prayerTimes == null) {
        return Container(); // TODO show spinner
      }
      return Container(
        color: AppThemes.logoBackground,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.lightBlue.shade900,
              expandedHeight: 260.0,
              collapsedHeight: c.showSunnahKeys ? 90.0 : 56,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.all(7.0),
                title: salahAppBar(),
                background: Swiper(
                  itemCount: 3,
                  itemBuilder: (BuildContext context, int index) => Image.asset(
                    'assets/images/quests/active$index.jpg',
                    //TODO add more images
                    fit: BoxFit.cover,
                  ),
                  autoplay: true,
                  autoplayDelay: 10000,
                ),
              ),
            ),
            sliverSpaceHeader(true),
            SliverPersistentHeader(
              pinned: c.prayerTimes!.currPrayerName == Prayer.Fajr,
              delegate: _SliverAppBarDelegate(
                minHeight: SALAH_ACTIONS_HEIGHT,
                maxHeight: SALAH_ACTIONS_HEIGHT,
                child: FlipCard(
                  flipOnTouch: false,
                  controller: flipCardControllerFajr,
                  direction: FlipDirection.HORIZONTAL,
                  front: actionsSalahRow(
                    rakatFard: '2',
                    fardSalah: Prayer.Fajr,
                    salahTimeStart: c.prayerTimes!.fajr,
                    salahTimeEnd: c.prayerTimes!.sunrise,
                    rakatMuakBefore: '2',
                    isJummahMode: false,
                    flipCardController: flipCardControllerFajr,
                  ),
                  back: actionsSalahRow(
                    rakatFard: '2',
                    fardSalah: Prayer.Fajr_Tomorrow,
                    salahTimeStart: c.prayerTimes!.fajrTomorrow,
                    salahTimeEnd: c.prayerTimes!.sunriseTomorrow,
                    rakatMuakBefore: '2',
                    isJummahMode: false,
                    flipCardController: flipCardControllerFajr,
                  ),
                ),
              ),
            ),
            spacingHeader(Prayer.Fajr),
            if (c.showSunnahDuha) actionsDuha(c),
            if (c.showSunnahDuha) spacingHeader(Prayer.Sunrise),
            c.isFriday() && c.showJummahOnFriday
                ? SliverPersistentHeader(
                    pinned: c.prayerTimes!.currPrayerName == Prayer.Dhuhr,
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        flipOnTouch: false, // TODO flip on icon hit
                        controller: flipCardControllerDhuhr,
                        direction: FlipDirection.HORIZONTAL,
                        front: actionsSalahRow(
                          rakatFard: '2', // Jummah Mode
                          fardSalah: Prayer.Dhuhr,
                          salahTimeStart: c.prayerTimes!.dhuhr,
                          rakatMuakBefore: '4',
                          rakatMuakAfter: '6',
                          rakatNaflAfter: '2',
                          isJummahMode: true,
                          flipCardController: flipCardControllerDhuhr,
                        ),
                        back: actionsSalahRow(
                          rakatFard: '4',
                          fardSalah: Prayer.Dhuhr,
                          salahTimeStart: c.prayerTimes!.dhuhr,
                          rakatMuakBefore: '4',
                          rakatMuakAfter: '2',
                          rakatNaflAfter: '2',
                          isJummahMode: false,
                          flipCardController: flipCardControllerDhuhr,
                        ),
                      ),
                    ),
                  )
                : SliverPersistentHeader(
                    pinned: c.prayerTimes!.currPrayerName == Prayer.Dhuhr,
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        flipOnTouch: false,
                        controller: flipCardControllerDhuhr,
                        direction: FlipDirection.HORIZONTAL,
                        front: actionsSalahRow(
                          rakatFard: '4',
                          fardSalah: Prayer.Dhuhr,
                          salahTimeStart: c.prayerTimes!.dhuhr,
                          rakatMuakBefore: '4',
                          rakatMuakAfter: '2',
                          rakatNaflAfter: '2',
                          isJummahMode: false,
                          flipCardController: flipCardControllerDhuhr,
                        ),
                        back: actionsSalahRow(
                          rakatFard: '2', // Jummah Mode
                          fardSalah: Prayer.Dhuhr,
                          salahTimeStart: c.prayerTimes!.dhuhr,
                          rakatMuakBefore: '4',
                          rakatMuakAfter: '6',
                          rakatNaflAfter: '2',
                          isJummahMode: true,
                          flipCardController: flipCardControllerDhuhr,
                        ),
                      ),
                    ),
                  ),
            spacingHeader(Prayer.Dhuhr),
            actionsSalah(
              rakatFard: '4',
              fardSalah: Prayer.Asr,
              salahTimeStart: c.prayerTimes!.asr,
              rakatNaflBefore: '4',
            ),
            spacingHeader(Prayer.Asr),
            actionsSalah(
              rakatFard: '3',
              fardSalah: Prayer.Maghrib,
              salahTimeStart: c.prayerTimes!.maghrib,
              rakatMuakAfter: '2',
              rakatNaflAfter: '2',
            ),
            spacingHeader(Prayer.Maghrib),
            actionsSalah(
              rakatFard: '4',
              fardSalah: Prayer.Isha,
              salahTimeStart: c.prayerTimes!.isha,
              rakatNaflBefore: '4',
              rakatMuakAfter: '2',
              rakatNaflAfter: '2',
            ),
            spacingHeader(Prayer.Isha),
            if (c.showSunnahLayl) actionsLaylIbadah(fardSalah: Prayer.Isha),
            if (c.showSunnahLayl) spacingHeader(Prayer.Isha),
            sliverSpaceHeader(true),
            sliverSpaceHeader2(false),
            sliverSpaceHeader2(false),
            sliverSpaceHeader2(false),
            sliverSpaceHeader2(false),
            sliverSpaceHeader2(false),
            sliverSpaceHeader2(false),
            sliverSpaceHeader2(false),
            sliverSpaceHeader2(false),
          ],
        ),
      );
    });
  }

  Expanded salahHeader(
    final Prayer fardSalah,
    final QuestController c,
    final bool isJummahMode,
    final DateTime salahTimeStart,
    final DateTime? salahTimeEnd,
    final FlipCardController? flipCardController,
  ) {
    return Expanded(
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(15.0),
            topRight: const Radius.circular(15.0),
          ),
          child: Container(
            color: fardSalah == c.prayerTimes!.currPrayerName &&
                    ((!isJummahMode) || (isJummahMode && c.isFriday()))
                ? Color(0xFF268E0D)
                : Colors.lightBlue.shade600,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (flipCardController != null)
                  InkWell(
                    child: Transform.rotate(
                      angle: 1.5708, // <- radian = 90 degrees
                      child: Icon(Icons.swap_vert_outlined),
                    ),
                    onTap: () => c.toggleFlipCard(flipCardController),
                  ),
                Text(
                  isJummahMode
                      ? 'Jummah'
                      : fardSalah
                          .toString()
                          .split('.')
                          .last
                          .replaceAll('_', ' '),
                  style: const TextStyle(
                      color: textColor,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(width: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      getTimeRange(salahTimeStart, salahTimeEnd),
                      style: textStyleWhite,
                      textAlign: TextAlign.center,
                    ),
                    InkWell(
                      onTap: () {
                        c.toggleSalahAlarm(fardSalah);
                      },
                      child: Icon(
                        Icons.alarm_outlined, // TODO
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  const _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => math.max(maxHeight, minHeight);
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

class SalahActionCellStart extends StatelessWidget {
  const SalahActionCellStart(this._text, this._textStyle, this._isActive);

  final String _text;
  final TextStyle _textStyle;
  final bool _isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1000,
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: const Radius.circular(15.0),
          ),
          child: Container(
            color: Colors.grey.shade800,
            child: Center(
                // child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700),duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: Text('Duha',style: actionDuhaTextStyle,),),
                child: _isActive
                    ? HeartBeat(
                        beatsPerMinute: 60,
                        child: Text(_text, style: _textStyle),
                      )
                    : Text(_text, style: _textStyle)),
            //child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700), duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: HeartBeat(beatsPerMinute: 120,//radius: 100,child: Text('Duha',style: actionDuhaTextStyle,),),
          ),
        ),
      ),
    );
  }
}

class SalahActionCellStartWidget extends StatelessWidget {
  const SalahActionCellStartWidget(this._widget, this._isActive,
      {this.flex = 1000});

  final Widget _widget;
  final bool _isActive;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: const Radius.circular(15.0),
          ),
          child: Container(
            color: Colors.grey.shade800,
            child: Center(
                child: _isActive
                    ? HeartBeat(
                        beatsPerMinute: 60,
                        child: _widget,
                      )
                    : _widget),
          ),
        ),
      ),
    );
  }
}

class SalahActionCellCenter extends StatelessWidget {
  const SalahActionCellCenter(this._text, this._textStyle, this._isActive);

  final String _text;
  final TextStyle _textStyle;
  final bool _isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1000,
      child: Container(
        color: Colors.grey.shade800,
        child: Center(
            child: _isActive
                ? HeartBeat(
                    beatsPerMinute: 60,
                    child: Text(_text, style: _textStyle),
                  )
                : Text(_text, style: _textStyle)),
      ),
    );
  }
}

class SalahActionCellCenterWidget extends StatelessWidget {
  const SalahActionCellCenterWidget(this._widget, this._isActive,
      {this.flex = 1000});

  final Widget _widget;
  final bool _isActive;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        color: Colors.grey.shade800,
        child: Center(
            child: _isActive
                ? HeartBeat(
                    beatsPerMinute: 60,
                    child: _widget,
                  )
                : _widget),
      ),
    );
  }
}

class SalahActionCellEnd extends StatelessWidget {
  const SalahActionCellEnd(this._text, this._textStyle, this._isActive);

  final String _text;
  final TextStyle _textStyle;
  final bool _isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1000,
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomRight: const Radius.circular(15.0),
          ),
          child: Container(
            color: Colors.grey.shade800,
            child: Center(
                // child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700),duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: Text('Duha',style: actionDuhaTextStyle,),),
                child: _isActive
                    ? HeartBeat(
                        beatsPerMinute: 60,
                        child: Text(_text, style: _textStyle),
                      )
                    : Text(_text, style: _textStyle)),
            //child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700), duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: HeartBeat(beatsPerMinute: 120,//radius: 100,child: Text('Duha',style: actionDuhaTextStyle,),),
          ),
        ),
      ),
    );
  }
}

class SalahActionCellEndWidget extends StatelessWidget {
  const SalahActionCellEndWidget(this._widget, this._isActive,
      {this.flex = 1000});

  final Widget _widget;
  final bool _isActive;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        color: AppThemes.logoBackground, // hide scroll of items behind
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomRight: const Radius.circular(15.0),
          ),
          child: Container(
            color: Colors.grey.shade800,
            child: Center(
                // child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700),duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: Text('Duha',style: actionDuhaTextStyle,),),
                child: _isActive
                    ? HeartBeat(
                        beatsPerMinute: 60,
                        child: _widget,
                      )
                    : _widget),
            //child: AvatarGlow(endRadius: 100.0, showTwoGlows: true, glowColor: const Color(0xFFFFD700), duration: Duration(milliseconds: 1000), //shape: CircleBorder(),child: HeartBeat(beatsPerMinute: 120,//radius: 100,child: Text('Duha',style: actionDuhaTextStyle,),),
          ),
        ),
      ),
    );
  }
}

class IconThikr extends StatelessWidget {
  const IconThikr();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //Text('Thikr', style: actionTextStyle),
        Center(
          child: Icon(
            Icons.favorite_outlined,
            color: Colors.red,
            size: 33,
          ),
        ),
        Center(
          child: Icon(
            Icons.psychology_outlined,
            color: Colors.white,
            size: 21,
          ),
        ),
      ],
    );
  }
}

class IconSunrise extends StatelessWidget {
  const IconSunrise();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.rotate(
          //angle: 1.5708,
          angle: 4.71239,
          child: Icon(
            Icons.brightness_medium_outlined,
            color: Colors.yellow,
            size: 18,
          ),
        ),
        Positioned(
          top: 9,
          left: 0,
          child: Container(
            color: Colors.grey.shade800,
            height: 10,
            width: 20,
            //child: SizedBox(height: 10),
          ),
        ),
        Positioned(
          top: 5.5,
          left: .9,
          child: Icon(Icons.arrow_drop_up_outlined,
              color: Colors.yellow, size: 16),
        )
      ],
    );
  }
}

class IconSunset extends StatelessWidget {
  const IconSunset();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.rotate(
          //angle: 1.5708,
          angle: 4.71239,
          child: Icon(
            Icons.brightness_medium_outlined,
            color: Colors.yellow,
            size: 18,
          ),
        ),
        Positioned(
          top: 9,
          left: 0,
          child: Container(
            color: Colors.grey.shade800,
            height: 10,
            width: 20,
            //child: SizedBox(height: 10),
          ),
        ),
        Positioned(
          top: 5.5,
          left: .9,
          child: Icon(Icons.arrow_drop_down_outlined,
              color: Colors.yellow, size: 16),
        )
      ],
    );
  }
}

class SunCell extends StatelessWidget {
  const SunCell(this._sunIcon, this._label, this._time1, this._time2);

  final Widget _sunIcon;
  final String _label;
  final DateTime _time1;
  final DateTime? _time2;

  static const TextStyle _textStyleAdhkar = const TextStyle(
      color: Colors.white, fontSize: 11.0, fontWeight: FontWeight.normal);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sunIcon,
            SizedBox(width: 3),
            Text(
              QuestsActive.getTimeRange(_time1, _time2),
              style: _textStyleAdhkar,
            ),
          ],
        ),
        if (_label != '') Text(_label, style: _textStyleAdhkar),
      ],
    );
  }
}
