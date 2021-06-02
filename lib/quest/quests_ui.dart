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
            ShowSunnahSettings(
              btnHeight: 25,
              btnGap: 5,
              fontSize: 14,
              lrPadding: 0,
            ),
            const SizedBox(height: 45),
            Text(
              'Friday Default:',
              style: textStyleTitle,
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 80.0,
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
            const SizedBox(height: 45),
            Text(
              'Clock Type:',
              style: textStyleTitle,
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 80.0,
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
            Text(
              "Show Sunnah:",
              style: textStyleTitle,
            ),
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
                c.toggleShowSunnahWitr();
              },
              child: Padding(
                padding: EdgeInsets.only(left: lrPadding, right: lrPadding),
                child: Container(
                  height: btnHeight,
                  color: Colors.blue.withOpacity(c.showSunnahWitr ? 1 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 3),
                      c.showSunnahWitr
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
                        'Witr',
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
                c.toggleShowSunnahThjd();
              },
              child: Padding(
                padding: EdgeInsets.only(left: lrPadding, right: lrPadding),
                child: Container(
                  height: btnHeight,
                  color:
                      Colors.pinkAccent.withOpacity(c.showSunnahThjd ? 1 : 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(width: 3),
                      c.showSunnahThjd
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
                        'Tahajjud',
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
  final TextEditingController _textEditingController = TextEditingController();
  int _currentPage = 0;
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
  TextStyle topTitlesTextStyle =
      const TextStyle(color: Colors.white, fontSize: 22.0);
  TextStyle columnTitlesTextStyle =
      const TextStyle(color: Colors.white, fontSize: 11.5);

  static const double SALAH_ACTIONS_HEIGHT = 75;

  GetBuilder SalahAppBar(FARD_SALAH fardSalah) {
    return GetBuilder<QuestController>(
      init: QuestController(),
      builder: (c) {
        bool showSunnahColumns = false;
        int fardFlex = 2000;

        if (c.showSunnahMuak || c.showSunnahNafl) {
          showSunnahColumns = true;
          fardFlex = 1000;
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 5000,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          //SizedBox(width: 15),
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
                        flex: 2200,
                        child: Text(
                          '',
                          textAlign: TextAlign.center,
                          style: columnTitlesTextStyle,
                        ),
                      ),
                      if (showSunnahColumns)
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
                                'Fard',
                                textAlign: TextAlign.center,
                                style: columnTitlesTextStyle,
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        flex: fardFlex,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: showSunnahColumns ? 0.0 : 12.0),
                              child: Text(
                                showSunnahColumns ? 'Fard' : 'Fard Rakat',
                                textAlign: TextAlign.center,
                                style: columnTitlesTextStyle,
                              ),
                            ),
                            if (showSunnahColumns)
                              Text(
                                'Rakat',
                                textAlign: TextAlign.center,
                                style: columnTitlesTextStyle,
                              ),
                          ],
                        ),
                      ),
                      if (showSunnahColumns)
                        Expanded(
                          flex: 1000,
                          child: Column(
                            children: [
                              Text(
                                'After',
                                textAlign: TextAlign.center,
                                style: columnTitlesTextStyle,
                              ),
                              Text(
                                'Fard',
                                textAlign: TextAlign.center,
                                style: columnTitlesTextStyle,
                              ),
                            ],
                          ),
                        ),
                      if (!showSunnahColumns)
                        Expanded(
                          flex: fardFlex,
                          child: Text(''),
                        ),
                      //Expanded(flex: 2000, child: Text('')),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2000,
              child: c.showSunnahKey
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

  /// Used by Fajr, Asr, Maghrib, Isha (All but dhur/jummah)
  SliverPersistentHeader salahActions({
    required final FARD_SALAH fardSalah,
    required final String rakatMuakBefore,
    required final String rakatNaflBefore,
    required final String rakatFard,
    required final String rakatMuakAfter,
    required final String rakatMuakAfter2,
    required final String rakatNaflAfter,
    required final String rakatNaflAfter2,
    required final DateTime? salahTimeStart,
    final DateTime? salahTimeEnd,
  }) {
    return SliverPersistentHeader(
      pinned: fardSalah == cQust.activeSalah, // TODO cQust needed i believe
      delegate: _SliverAppBarDelegate(
        minHeight: SALAH_ACTIONS_HEIGHT,
        maxHeight: SALAH_ACTIONS_HEIGHT,
        child: salahActionsRow(
          fardSalah: fardSalah,
          rakatMuakBefore: rakatMuakBefore,
          rakatNaflBefore: rakatNaflBefore,
          rakatFard: rakatFard,
          rakatMuakAfter: rakatMuakAfter,
          rakatNaflAfter: rakatNaflAfter,
          salahTimeStart: salahTimeStart,
          salahTimeEnd: salahTimeEnd,
          rakatMuakAfter2: rakatMuakAfter2,
          rakatNaflAfter2: rakatNaflAfter2,
          isJummahMode: false,
        ),
      ),
    );
  }

  /// Used by dhur/jummah
  GetBuilder<QuestController> salahActionsRow({
    required final FARD_SALAH fardSalah,
    required final String rakatMuakBefore,
    required final String rakatNaflBefore,
    required final String rakatFard,
    required final String rakatMuakAfter,
    required final String rakatNaflAfter,
    required final DateTime? salahTimeStart,
    required final DateTime? salahTimeEnd,
    required final String rakatMuakAfter2,
    required final String rakatNaflAfter2,
    required final bool isJummahMode,
  }) {
    return GetBuilder<QuestController>(
      init: QuestController(),
      builder: (c) {
        const Color textColor = Colors.white;
        TextStyle actionTextStyle = const TextStyle(
            color: textColor, fontSize: 17.0, fontWeight: FontWeight.bold);
        // TextStyle sunStyle = const TextStyle(
        //     color: textColor, fontSize: 12.0, fontWeight: FontWeight.bold);

        //bool showRightColumnOnly = false; TODO cleanup
        bool showSunnahColumns = false;
        int fardFlex = 2000;

        if (c.showSunnahMuak || c.showSunnahNafl) {
          showSunnahColumns = true;
          fardFlex = 1000;
        }
        // } else {
        //   showRightColumnOnly = true;
        // }
        // if(
        // c.showSunnahWitr ||
        // c.showSunnahThjd ||
        // c.showSunnahDuha) {
        // }

        return Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 2200,
              child: Container(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: const Radius.circular(15.0),
                    bottomLeft: const Radius.circular(15.0),
                  ),
                  child: Container(
                    color: fardSalah == cQust.activeSalah
                        ? Color(0xFF268E0D)
                        : Colors.lightBlue.shade800,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isJummahMode
                              ? 'Jummah'
                              : fardSalah.toString().split('.').last,
                          style: const TextStyle(
                              color: textColor,
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            if (showSunnahColumns)
              Expanded(
                flex: 1000,
                child: Column(
                  children: [
                    if ((rakatMuakBefore == '' && rakatNaflBefore == '') ||
                        (c.showSunnahMuak &&
                            !c.showSunnahNafl &&
                            rakatMuakBefore == '') ||
                        (c.showSunnahNafl &&
                            !c.showSunnahMuak &&
                            rakatNaflBefore == ''))
                      Expanded(
                        child: Container(
                          color: Colors.grey.shade800,
                          child: Center(
                            child: Text(
                              '-',
                              style: actionTextStyle,
                              //textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    if (c.showSunnahMuak && rakatMuakBefore != '')
                      Expanded(
                        child: Container(
                          color: Colors.green,
                          child: Center(
                            child: Text(
                              rakatMuakBefore,
                              style: actionTextStyle,
                            ),
                          ),
                        ),
                      ),
                    if (c.showSunnahNafl && rakatNaflBefore != '')
                      Expanded(
                        child: Container(
                          color: Colors.amber.shade700,
                          child: Center(
                            child: Text(
                              rakatNaflBefore,
                              style: actionTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              flex: fardFlex,
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
            //if (showSunnahColumns)
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
                                child: Icon(Icons.arrow_drop_up_outlined,
                                    color: Colors.yellow, size: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (fardSalah == FARD_SALAH.Asr)
                    Expanded(
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
                                child: Icon(Icons.arrow_drop_down_outlined,
                                    color: Colors.yellow, size: 16),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  if (fardSalah != FARD_SALAH.Asr &&
                      showSunnahColumns &&
                      rakatMuakAfter == '' &&
                      rakatNaflAfter == '')
                    Expanded(
                      child: Container(
                        color: Colors.grey.shade800,
                        child: Center(
                          child: Text(
                            '-',
                            style: actionTextStyle,
                          ),
                        ),
                      ),
                    ),
                  if (c.showSunnahMuak && rakatMuakAfter != '')
                    Expanded(
                      child: Container(
                        color: Colors.green,
                        child: Center(
                          child: Text(
                            rakatMuakAfter,
                            style: actionTextStyle,
                          ),
                        ),
                      ),
                    ),
                  if (c.showSunnahMuak &&
                      rakatMuakAfter2 != '' &&
                      rakatNaflAfter == '')
                    Divider(
                      height: 0.6,
                      thickness: 0.3,
                      color: textColor,
                      // indent: 8,
                      // endIndent: 8,
                    ),
                  if ((c.showSunnahNafl &&
                          rakatNaflAfter != '' &&
                          fardSalah != FARD_SALAH.Fajr) ||
                      fardSalah == FARD_SALAH.Fajr && c.showSunnahDuha)
                    Expanded(
                      child: Container(
                        color: fardSalah == FARD_SALAH.Fajr
                            ? Colors.deepOrangeAccent
                            : Colors.amber.shade700,
                        child: Center(
                          child: Text(
                            rakatNaflAfter,
                            style: actionTextStyle,
                          ),
                        ),
                      ),
                    ),
                  if ( //(c.showSunnahMuak && rakatMuakAfter2 != '') ||
                  (c.showSunnahWitr && fardSalah == FARD_SALAH.Isha))
                    Expanded(
                      child: Container(
                        color: fardSalah == FARD_SALAH.Isha
                            ? Colors.blue
                            : Colors.green,
                        child: Center(
                          child: Text(
                            rakatMuakAfter2,
                            style: actionTextStyle,
                          ),
                        ),
                      ),
                    ),
                  if (c.showSunnahNafl &&
                      !c.showSunnahMuak &&
                      fardSalah == FARD_SALAH.Isha)
                    Divider(
                      height: 0.6,
                      thickness: 0.3,
                      color: textColor,
                      // indent: 8,
                      // endIndent: 8,
                    ),
                  if (c.showSunnahThjd &&
                      rakatNaflAfter2 != '' &&
                      fardSalah == FARD_SALAH.Isha)
                    Expanded(
                      child: Container(
                        color: Colors.pinkAccent,
                        child: Center(
                          child: Text(
                            rakatNaflAfter2,
                            style: actionTextStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  if (fardSalah == FARD_SALAH.Fajr)
                    Expanded(
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
                ],
              ),
            ),
            Expanded(
              flex: 1000,
              child: Container(
                color: Colors.black,
                // color: isActiveSalah
                //     ? Colors.green // make active salah stand out
                //     : Colors.black, // hide slivers scrolling behind
                child: Container(
                  color: Colors.purple,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Thikr', style: actionTextStyle),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1000,
              child: Container(
                color: Colors.black,
                // color: isActiveSalah
                //     ? Colors.green // make active salah stand out
                //     : Colors.black, // hide slivers scrolling behind
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: const Radius.circular(15.0),
                    bottomRight: const Radius.circular(15.0),
                  ),
                  child: Container(
                    color: Colors.cyan,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Dua', style: actionTextStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
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
            //SalahHeader(activeSalah),
            salahActions(
              fardSalah: FARD_SALAH.Fajr,
              rakatMuakBefore: '2',
              rakatNaflBefore: '',
              rakatFard: '2',
              rakatMuakAfter: '',
              rakatNaflAfter: '2', //duha
              salahTimeStart: c.fajr,
              salahTimeEnd: c.sunrise,
              rakatMuakAfter2: '',
              rakatNaflAfter2: '',
            ),
            spacingHeader(FARD_SALAH.Fajr),
            c.isFriday() && c.showJummahOnFriday
                ? SliverPersistentHeader(
                    pinned: c.activeSalah == FARD_SALAH.Dhuhr,
                    delegate: _SliverAppBarDelegate(
                      minHeight: SALAH_ACTIONS_HEIGHT,
                      maxHeight: SALAH_ACTIONS_HEIGHT,
                      child: FlipCard(
                        direction: FlipDirection.HORIZONTAL, // default
                        front: Container(
                          child: salahActionsRow(
                            fardSalah: FARD_SALAH.Dhuhr,
                            rakatMuakBefore: '4',
                            rakatNaflBefore: '',
                            rakatFard: '2',
                            rakatMuakAfter: '4',
                            rakatNaflAfter: '',
                            salahTimeStart: c.dhuhr,
                            salahTimeEnd: null,
                            rakatMuakAfter2: '2',
                            rakatNaflAfter2: '2',
                            isJummahMode: true,
                          ),
                        ),
                        back: Container(
                          child: salahActionsRow(
                            fardSalah: FARD_SALAH.Dhuhr,
                            rakatMuakBefore: '4',
                            rakatNaflBefore: '',
                            rakatFard: '4',
                            rakatMuakAfter: '2',
                            rakatNaflAfter: '2',
                            salahTimeStart: c.dhuhr,
                            salahTimeEnd: null,
                            rakatMuakAfter2: '',
                            rakatNaflAfter2: '',
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
                        direction: FlipDirection.HORIZONTAL, // default
                        front: Container(
                          child: salahActionsRow(
                            fardSalah: FARD_SALAH.Dhuhr,
                            rakatMuakBefore: '4',
                            rakatNaflBefore: '',
                            rakatFard: '4',
                            rakatMuakAfter: '2',
                            rakatNaflAfter: '2',
                            salahTimeStart: c.dhuhr,
                            salahTimeEnd: null,
                            rakatMuakAfter2: '',
                            rakatNaflAfter2: '',
                            isJummahMode: false,
                          ),
                        ),
                        back: Container(
                          child: salahActionsRow(
                            fardSalah: FARD_SALAH.Dhuhr,
                            rakatMuakBefore: '4',
                            rakatNaflBefore: '',
                            rakatFard: '2',
                            rakatMuakAfter: '4',
                            rakatNaflAfter: '',
                            salahTimeStart: c.dhuhr,
                            salahTimeEnd: null,
                            rakatMuakAfter2: '2',
                            rakatNaflAfter2: '2',
                            isJummahMode: true,
                          ),
                        ),
                      ),
                    ),
                  ),
            spacingHeader(FARD_SALAH.Dhuhr),
            salahActions(
              fardSalah: FARD_SALAH.Asr,
              rakatMuakBefore: '',
              rakatNaflBefore: '4',
              rakatFard: '4',
              rakatMuakAfter: '',
              rakatNaflAfter: '',
              salahTimeStart: c.asr,
              salahTimeEnd: null,
              rakatMuakAfter2: '',
              rakatNaflAfter2: '',
            ),
            spacingHeader(FARD_SALAH.Asr),
            salahActions(
              fardSalah: FARD_SALAH.Maghrib,
              rakatMuakBefore: '',
              rakatNaflBefore: '',
              rakatFard: '3',
              rakatMuakAfter: '2',
              rakatNaflAfter: '2',
              salahTimeStart: c.maghrib,
              salahTimeEnd: null,
              rakatMuakAfter2: '',
              rakatNaflAfter2: '',
            ),
            spacingHeader(FARD_SALAH.Maghrib),
            salahActions(
              fardSalah: FARD_SALAH.Isha,
              rakatMuakBefore: '',
              rakatNaflBefore: '4',
              rakatFard: '4',
              rakatMuakAfter: '2',
              rakatNaflAfter: '2',
              salahTimeStart: c.isha,
              salahTimeEnd: null,
              rakatMuakAfter2: '3', // witr
              rakatNaflAfter2: '2', // tahajjud
            ),
            spacingHeader(FARD_SALAH.Isha),
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
