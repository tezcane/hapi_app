import 'dart:math' as math;

import 'package:bottom_bar/bottom_bar.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/menu/toggle_switch.dart';
import 'package:hapi/quest/quest_card.dart';
import 'package:hapi/quest/quest_controller.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/ui/settings_ui.dart';

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
      init: QuestController(),
      builder: (c) {
        return Column(
          // TODO tune
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Show Sunnah:',
              textAlign: TextAlign.center,
              style: textStyleTitle,
            ),
            ShowSunnahSettings(
              btnHeight: 25,
              btnGap: 5,
              fontSize: 14,
              lrPadding: 0,
            ),
            const SizedBox(height: 25),
            Text(
              'Sunnah Key',
              textAlign: TextAlign.center,
              style: textStyleTitle,
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
            const SizedBox(height: 25),
            Text(
              'Asr Start',
              textAlign: TextAlign.center,
              style: textStyleTitle,
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 50.0,
              fontSize: 14,
              initialLabelIndex: c.salahAsrSafe ? 0 : 1,
              labels: ['2 shadow length', '1 shadow length'],
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
            const SizedBox(height: 25),
            Text(
              'Kerahat Times (Minutes)',
              textAlign: TextAlign.center,
              style: textStyleTitle,
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 50.0,
              fontSize: 14,
              initialLabelIndex: c.salahKerahatSafe ? 0 : 1,
              labels: ['45/30/45', '20/10/20'],
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
            const SizedBox(height: 25),
            Text(
              'Friday Default',
              textAlign: TextAlign.center,
              style: textStyleTitle,
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
            const SizedBox(height: 25),
            Text(
              'Clock Type',
              textAlign: TextAlign.center,
              style: textStyleTitle,
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
    final TextStyle textStyleTitle = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize);
    final TextStyle textStyleBtn = TextStyle(
        color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize);

    return GetBuilder<QuestController>(
      init: QuestController(),
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
                  color: Colors.green.withOpacity(c.showSunnahMuak ? 1 : 0),
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
                        style: textStyleBtn,
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
                  color: Colors.amber.shade700
                      .withOpacity(c.showSunnahNafl ? 1 : 0),
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
                        style: textStyleBtn,
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
                  color: Colors.deepOrangeAccent
                      .withOpacity(c.showSunnahDuha ? 1 : 0),
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
                        style: textStyleBtn,
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
                  color: Colors.pinkAccent.withOpacity(
                    c.showSunnahLayl ? 1 : 0,
                  ),
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
                        style: textStyleBtn,
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
          Container(color: Colors.greenAccent.shade700),
          Container(color: Colors.orange),
          Container(color: Colors.red),
          // UserQuest(textEditingController: _textEditingController),
        ],
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
      ),
      bottomNavigationBar: Row(
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
              ),
              BottomBarItem(
                icon: Icon(Icons.brightness_high_outlined),
                title: Text('Daily Quests'),
                activeColor: Colors.greenAccent.shade700,
                darkActiveColor: Colors.greenAccent.shade400,
              ),
              BottomBarItem(
                icon: Icon(Icons.timer_outlined),
                title: Text('Time Quests'),
                activeColor: Colors.greenAccent.shade700,
                darkActiveColor: Colors.greenAccent.shade400,
              ),
              BottomBarItem(
                icon: Transform.rotate(
                  angle: 2.8,
                  child: Icon(Icons.brightness_3_outlined),
                ),
                title: Text('hapi Quests'),
                activeColor: Colors.red,
                darkActiveColor: Colors.red.shade400,
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
    );
  }
}

class UserQuest extends StatelessWidget {
  const UserQuest({
    Key? key,
    required TextEditingController textEditingController,
  })   : _textEditingController = textEditingController,
        super(key: key);

  final TextEditingController _textEditingController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(
      init: AuthController(), // TODO why init AuthController here?
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
              init: Get.put<QuestController>(QuestController()),
              builder: (QuestController questController) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: questController.quests.length,
                    itemBuilder: (_, index) {
                      return QuestCard(quest: questController.quests[index]);
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
  })   : _authController = authController,
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
  static const double SALAH_ACTIONS_HEIGHT = 55;

  final TextStyle topTitlesTextStyle =
      const TextStyle(color: Colors.white, fontSize: 21.0);
  final TextStyle columnTitlesTextStyle =
      const TextStyle(color: Colors.white, fontSize: 11.5);

  GetBuilder SalahAppBar(FARD_SALAH fardSalah) {
    return GetBuilder<QuestController>(
      init: QuestController(),
      builder: (c) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 4000,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          Text(fardSalah.toString().split('.').last,
                              style: topTitlesTextStyle),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          c.initLocation(); //TODO
                        },
                        child: Row(
                          children: [
                            Icon(Icons.hourglass_top_outlined, // TODO animate
                                color: Colors.green.shade500),
                            Text(c.timeToNextPrayer, style: topTitlesTextStyle),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1000,
                        child: Column(
                          children: [
                            Text(
                              'Before',
                              textAlign: TextAlign.center,
                              style: columnTitlesTextStyle,
                            ),
                            Text(
                              'Sunnah',
                              textAlign: TextAlign.center,
                              style: columnTitlesTextStyle,
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
                              style: columnTitlesTextStyle,
                            ),
                            Text(
                              'Rakat',
                              textAlign: TextAlign.center,
                              style: columnTitlesTextStyle,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2000,
                        child: Column(
                          children: [
                            Text(
                              'After',
                              textAlign: TextAlign.center,
                              style: columnTitlesTextStyle,
                            ),
                            Text(
                              'Sunnah',
                              textAlign: TextAlign.center,
                              style: columnTitlesTextStyle,
                            ),
                          ],
                        ),
                      ),
                      // Expanded(
                      //   flex: fardFlex,
                      //   child: Text(''),
                      // ),
                      //Expanded(flex: 2000, child: Text('')),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2000,
              child: c.showSunnahKeys
                  ? ShowSunnahSettings(
                      btnHeight: 19,
                      btnGap: 0,
                      fontSize: 9,
                      lrPadding: 5,
                    )
                  : Text(''),
            ),
          ],
        );
      },
    );
  }

  String getTime(DateTime? time) {
    return getTimeRange(time, null);
  }

  String getTimeRange(DateTime? startTime, DateTime? endTime) {
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

  /// Used by Fajr, Asr, Maghrib, Isha (All but dhur/jummah must pass in here)
  SliverPersistentHeader actionsSalah({
    required final String rakatFard,
    required final FARD_SALAH fardSalah,
    final DateTime? salahTimeStart,
    final DateTime? salahTimeEnd,
    final String rakatMuakBefore = '',
    final String rakatMuakAfter = '',
    final String rakatNaflBefore = '',
    final String rakatNaflAfter = '',
  }) {
    return SliverPersistentHeader(
      pinned: fardSalah == cQust.activeSalah, // TODO cQust needed i believe
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

  /// Used by dhur/jummah directly (others use through salahActions())
  GetBuilder<QuestController> actionsSalahRow({
    required final String rakatFard,
    required final FARD_SALAH fardSalah,
    final DateTime? salahTimeStart,
    final DateTime? salahTimeEnd,
    final String rakatMuakBefore = '',
    final String rakatMuakAfter = '',
    final String rakatNaflBefore = '',
    final String rakatNaflAfter = '',
    required final bool isJummahMode,
  }) {
    return GetBuilder<QuestController>(
      init: QuestController(),
      builder: (c) {
        const Color textColor = Colors.white;
        const TextStyle actionTextStyle = const TextStyle(
            color: textColor, fontSize: 17.0, fontWeight: FontWeight.bold);

        return Column(
          children: [
            ///
            /// First row is title of salah, with times, etc.
            ///
            Row(
              children: [
                Expanded(
                  flex: 7000,
                  child: Container(
                    color: Colors.black, // hide scroll of items behind
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: const Radius.circular(15.0),
                        topRight: const Radius.circular(15.0),
                      ),
                      child: Container(
                        color: fardSalah == cQust.activeSalah
                            ? Color(0xFF268E0D)
                            : Colors.lightBlue.shade800,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isJummahMode
                                  ? 'Jummah'
                                  : fardSalah.toString().split('.').last,
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
                                  getTimeRange(
                                    salahTimeStart,
                                    // if duha showing, it has sunrise already
                                    c.showSunnahDuha ? null : salahTimeEnd,
                                  ),
                                  style: actionTextStyle,
                                  textAlign: TextAlign.center,
                                ),
                                InkWell(
                                  onTap: () {
                                    c.toggleSalahAlarm(fardSalah);
                                  },
                                  child: Icon(Icons.alarm_outlined,
                                      size: 20, color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ///
                  /// 1 of 4. sunnah before fard column items:
                  ///
                  Expanded(
                    flex: 1000,
                    child: Row(
                      children: [
                        if (rakatMuakBefore != '')
                          Expanded(
                            child: Container(
                              color:
                                  Colors.black, // hide scroll of items behind
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: const Radius.circular(15.0),
                                ),
                                child: Container(
                                  color: c.showSunnahMuak
                                      ? Colors.green
                                      : Colors.grey.shade800,
                                  child: Center(
                                    child: Text(
                                      c.showSunnahMuak ? rakatMuakBefore : '',
                                      style: actionTextStyle,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (rakatNaflBefore != '')
                          Expanded(
                            child: Container(
                              color:
                                  Colors.black, // hide scroll of items behind
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: const Radius.circular(15.0),
                                ),
                                child: Container(
                                  color: c.showSunnahNafl
                                      ? Colors.amber.shade700
                                      : Colors.grey.shade800,
                                  child: Center(
                                    child: Text(
                                      c.showSunnahNafl ? rakatNaflBefore : '',
                                      style: actionTextStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (fardSalah == FARD_SALAH.Maghrib)
                          Expanded(
                            child: Container(
                              color: Colors.black,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: const Radius.circular(15.0),
                                ),
                                child: Container(
                                  color: Colors.grey.shade800,
                                  child: Center(
                                    child: Stack(
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
                                          child: Icon(
                                              Icons.arrow_drop_down_outlined,
                                              color: Colors.yellow,
                                              size: 16),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  ///
                  /// 2 of 4. fard column item:
                  ///
                  Expanded(
                    flex: 1000,
                    child: Container(
                      color: Colors.red,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(rakatFard, style: actionTextStyle),
                        ],
                      ),
                    ),
                  ),

                  ///
                  /// 3 of 4. sunnah after fard column items:
                  ///
                  Expanded(
                    flex: 2000,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (fardSalah == FARD_SALAH.Fajr)
                          Expanded(
                            child: Container(
                              color: Colors.grey.shade800,
                              child: Center(
                                child: Text('Morning Adhkar'),
                              ),
                            ),
                          ),
                        if (fardSalah == FARD_SALAH.Asr)
                          Expanded(
                            child: Container(
                              color: Colors.grey.shade800,
                              child: Center(
                                child: Text('Evening Adhkar'),
                              ),
                            ),
                          ),
                        if (rakatMuakAfter != '')
                          Expanded(
                            child: Container(
                              color: c.showSunnahMuak
                                  ? Colors.green
                                  : Colors.grey.shade800,
                              child: Center(
                                child: Text(
                                  c.showSunnahMuak ? rakatMuakAfter : '',
                                  style: actionTextStyle,
                                ),
                              ),
                            ),
                          ),
                        if (rakatNaflAfter != '')
                          Expanded(
                            child: Container(
                              color: c.showSunnahNafl
                                  ? Colors.amber.shade700
                                  : Colors.grey.shade800,
                              child: Center(
                                child: Text(
                                  c.showSunnahNafl ? rakatNaflAfter : '',
                                  style: actionTextStyle,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  ///
                  /// 4 of 4. Thikr and Dua after fard:
                  ///
                  Expanded(
                    flex: 2000,
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.purple,
                            child: Stack(
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
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: Colors.black,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                //topRight: const Radius.circular(15.0),
                                bottomRight: const Radius.circular(15.0),
                              ),
                              child: Container(
                                color: Colors.teal,
                                child: //Text('Dua', style: actionTextStyle),
                                    Center(
                                  child: Icon(
                                    Icons.volunteer_activism,
                                    color: Colors.white,
                                    size: 25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  SliverPersistentHeader actionsDuha({
    required final FARD_SALAH fardSalah,
    final DateTime? timeStart,
  }) {
    return SliverPersistentHeader(
      pinned: fardSalah == cQust.activeSalah, // TODO cQust needed i believe
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: GetBuilder<QuestController>(
          init: QuestController(),
          builder: (c) {
            const Color textColor = Colors.white;
            TextStyle actionTextStyle = const TextStyle(
                color: textColor, fontSize: 17.0, fontWeight: FontWeight.bold);
            // TextStyle sunStyle = const TextStyle(
            //     color: textColor, fontSize: 12.0, fontWeight: FontWeight.bold);

            return Column(
              children: [
                ///
                /// First row is title with times, etc.
                ///
                Row(
                  children: [
                    Expanded(
                      //flex: 7000,
                      child: Container(
                        color: Colors.black, // hide scroll of items behind
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: const Radius.circular(15.0),
                            topRight: const Radius.circular(15.0),
                          ),
                          child: Container(
                            color: fardSalah == cQust.activeSalah
                                ? Color(0xFF268E0D)
                                : Colors.lightBlue.shade800,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Duha',
                                  style: const TextStyle(
                                      color: textColor,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      getTime(timeStart),
                                      style: actionTextStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        c.toggleSalahAlarm(fardSalah);
                                      },
                                      child: Icon(Icons.alarm_outlined,
                                          size: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        //flex: 7000,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                color:
                                    Colors.black, // hide scroll of items behind
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: const Radius.circular(15.0),
                                  ),
                                  child: Container(
                                    color: Colors.grey.shade800,
                                    child: Center(
                                      child: Stack(
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
                                            ),
                                          ),
                                          Positioned(
                                            top: 5.5,
                                            left: .9,
                                            child: Icon(
                                                Icons.arrow_drop_up_outlined,
                                                color: Colors.yellow,
                                                size: 16),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color: Colors.deepOrangeAccent,
                                child: Center(
                                  child: Text(
                                    'Duha',
                                    style: actionTextStyle,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                color:
                                    Colors.black, // hide scroll of items behind
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomRight: const Radius.circular(15.0),
                                  ),
                                  child: Container(
                                    color: Colors.grey.shade800,
                                    child: Center(
                                      child: Icon(
                                        Icons.brightness_7_outlined,
                                        color: Colors.yellow,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  SliverPersistentHeader actionsLaylIbadah({
    required final FARD_SALAH fardSalah,
    final DateTime? salahTimeStart, // TODO
    final DateTime? salahTimeEnd,
  }) {
    return SliverPersistentHeader(
      pinned: fardSalah == cQust.activeSalah, // TODO cQust needed i believe
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: GetBuilder<QuestController>(
          init: QuestController(),
          builder: (c) {
            const Color textColor = Colors.white;
            TextStyle actionTextStyle = const TextStyle(
                color: textColor, fontSize: 17.0, fontWeight: FontWeight.bold);
            // TextStyle sunStyle = const TextStyle(
            //     color: textColor, fontSize: 12.0, fontWeight: FontWeight.bold);

            return Column(
              children: [
                ///
                /// First row is title with times, etc.
                ///
                Row(
                  children: [
                    Expanded(
                      flex: 7000,
                      child: Container(
                        color: Colors.black, // hide scroll of items behind
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: const Radius.circular(15.0),
                            topRight: const Radius.circular(15.0),
                          ),
                          child: Container(
                            color: fardSalah == cQust.activeSalah
                                ? Color(0xFF268E0D)
                                : Colors.lightBlue.shade800,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Layl Ibadah',
                                  style: const TextStyle(
                                      color: textColor,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(width: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      getTime(salahTimeStart),
                                      style: actionTextStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        c.toggleSalahAlarm(fardSalah);
                                      },
                                      child: Icon(Icons.alarm_outlined,
                                          size: 20, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  flex: 7000,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: const Radius.circular(15.0),
                            ),
                            child: Container(
                              color: Colors.cyan,
                              child: Center(
                                child: Text(
                                  'Qiyam',
                                  style: actionTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      ///
                      /// Thikr and Dua before bed:
                      ///
                      Expanded(
                        child: Container(
                          color: Colors.purple,
                          child: Stack(
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
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.teal,
                          child: //Text('Dua', style: actionTextStyle),
                              Center(
                            child: Icon(
                              Icons.volunteer_activism,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        ),
                      ),

                      ///
                      /// Tahhajud and Witr after waking up
                      ///
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: Container(
                            color: Colors.grey.shade800,
                            child: Center(
                              child: Text('Sleep', style: actionTextStyle),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.blue,
                          child: Center(
                            child: InkWell(
                              onTap: () {
                                //c.toggleSalahAlarm(fardSalah);
                              },
                              child: Text(
                                'Tahajjud',
                                style: actionTextStyle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.black,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomRight: const Radius.circular(15.0),
                            ),
                            child: Container(
                              color: Colors.pinkAccent,
                              child: Center(
                                child: Text(
                                  'Witr',
                                  style: actionTextStyle,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

  SliverPersistentHeader spacingHeader(FARD_SALAH fardSalah) {
    return SliverPersistentHeader(
      pinned: fardSalah == cQust.activeSalah,
      delegate: _SliverAppBarDelegate(
        minHeight: 5.0,
        maxHeight: 5.0,
        child: Container(
          color: Colors.black,
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
          color: Colors.black,
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
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuestController>(
      init: QuestController(),
      builder: (c) => Container(
        color: Colors.black,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.lightBlue.shade900,
              expandedHeight: 300.0,
              collapsedHeight: 130.0,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: SalahAppBar(c.activeSalah),
                  background: Swiper(
                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) =>
                        Image.asset(
                      'assets/images/quests/active$index.jpg', //TODO add more images
                      fit: BoxFit.cover,
                    ),
                    autoplay: true,
                    autoplayDelay: 10000,
                  )),
            ),
            sliverSpaceHeader(true),
            actionsSalah(
              rakatFard: '2',
              fardSalah: FARD_SALAH.Fajr,
              salahTimeStart: c.fajr,
              salahTimeEnd: c.sunrise,
              rakatMuakBefore: '2',
            ),
            spacingHeader(FARD_SALAH.Fajr),
            if (c.showSunnahDuha)
              actionsDuha(fardSalah: FARD_SALAH.Fajr, timeStart: c.sunrise),
            if (c.showSunnahDuha) spacingHeader(FARD_SALAH.Fajr),
            c.isFriday() && c.showJummahOnFriday
                ? SliverPersistentHeader(
                    pinned: c.activeSalah == FARD_SALAH.Dhuhr,
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        front: Container(
                          child: actionsSalahRow(
                            rakatFard: '2', // Jummah Mode
                            fardSalah: FARD_SALAH.Dhuhr,
                            salahTimeStart: c.dhuhr,
                            rakatMuakBefore: '4',
                            rakatMuakAfter: '6',
                            rakatNaflAfter: '2',
                            isJummahMode: true,
                          ),
                        ),
                        back: Container(
                          child: actionsSalahRow(
                            rakatFard: '4',
                            fardSalah: FARD_SALAH.Dhuhr,
                            salahTimeStart: c.dhuhr,
                            rakatMuakBefore: '4',
                            rakatMuakAfter: '2',
                            rakatNaflAfter: '2',
                            isJummahMode: false,
                          ),
                        ),
                      ),
                    ),
                  )
                : SliverPersistentHeader(
                    pinned: c.activeSalah == FARD_SALAH.Dhuhr,
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        direction: FlipDirection.HORIZONTAL,
                        front: Container(
                          child: actionsSalahRow(
                            rakatFard: '4',
                            fardSalah: FARD_SALAH.Dhuhr,
                            salahTimeStart: c.dhuhr,
                            rakatMuakBefore: '4',
                            rakatMuakAfter: '2',
                            rakatNaflAfter: '2',
                            isJummahMode: false,
                          ),
                        ),
                        back: Container(
                          child: actionsSalahRow(
                            rakatFard: '2', // Jummah Mode
                            fardSalah: FARD_SALAH.Dhuhr,
                            salahTimeStart: c.dhuhr,
                            rakatMuakBefore: '4',
                            rakatMuakAfter: '6',
                            rakatNaflAfter: '2',
                            isJummahMode: true,
                          ),
                        ),
                      ),
                    ),
                  ),
            spacingHeader(FARD_SALAH.Dhuhr),
            actionsSalah(
              rakatFard: '4',
              fardSalah: FARD_SALAH.Asr,
              salahTimeStart: c.asr,
              rakatNaflBefore: '4',
            ),
            spacingHeader(FARD_SALAH.Asr),
            actionsSalah(
              rakatFard: '3',
              fardSalah: FARD_SALAH.Maghrib,
              salahTimeStart: c.maghrib,
              rakatMuakAfter: '2',
              rakatNaflAfter: '2',
            ),
            spacingHeader(FARD_SALAH.Maghrib),
            actionsSalah(
              rakatFard: '4',
              fardSalah: FARD_SALAH.Isha,
              salahTimeStart: c.isha,
              rakatNaflBefore: '4',
              rakatMuakAfter: '2',
              rakatNaflAfter: '2',
            ),
            spacingHeader(FARD_SALAH.Isha),
            if (c.showSunnahLayl) actionsLaylIbadah(fardSalah: FARD_SALAH.Isha),
            if (c.showSunnahLayl) spacingHeader(FARD_SALAH.Isha),
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
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
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
