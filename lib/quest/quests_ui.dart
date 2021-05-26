import 'dart:math' as math;

import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/controllers/auth_controller.dart';
import 'package:hapi/menu/fab_nav_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/quest_card.dart';
import 'package:hapi/quest/quest_controller.dart';
import 'package:hapi/services/database.dart';
import 'package:hapi/ui/settings_ui.dart';

class QuestsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FabNavPage(
      navPage: NavPage.QUESTS,
      columnWidget: Column(),
      bottomWidget: HapiShare(),
      foregroundPage: QuestBottomBar(),
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

enum FARD_SALAH {
  Fajr,
  Dhuhr,
  Asr,
  Maghrib,
  Isha,
}

class QuestsActive extends StatelessWidget {
  FARD_SALAH activeSalah = FARD_SALAH.Maghrib;

  TextStyle topTitlesTextStyle =
      const TextStyle(color: Colors.white, fontSize: 20.0);
  TextStyle columnTitlesTextStyle =
      const TextStyle(color: Colors.white, fontSize: 10.0);

  GetBuilder SalahAppBar(FARD_SALAH fardSalah) {
    return GetBuilder<QuestController>(
      init: QuestController(),
      builder: (c) {
        return Column(
          //mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //SizedBox(height: 15),
            Container(
              child: ClipRRect(
                borderRadius: BorderRadius.all(const Radius.circular(15.0)),
                child: Container(
                  //: Colors.lightBlue.shade200.withOpacity(0.50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          //SizedBox(width: 15),
                          Text(fardSalah.toString().split('.').last,
                              style: topTitlesTextStyle),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //SizedBox(width: 20),
                          Icon(Icons.hourglass_bottom_outlined),
                          Text('1:31:45', style: topTitlesTextStyle),
                        ],
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     Icon(Icons.push_pin_outlined),
                      //     SizedBox(width: 15),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            Container(
              //color: Colors.lightBlue.shade200.withOpacity(0.50),
              child: Row(
                children: [
                  Expanded(
                    flex: 1000,
                    child: Text(
                      'Salah',
                      textAlign: TextAlign.center,
                      style: columnTitlesTextStyle,
                    ),
                  ),
                  Expanded(
                    flex: 1000,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Start',
                          textAlign: TextAlign.center,
                          style: columnTitlesTextStyle,
                        ),
                        Divider(
                          height: 2,
                          thickness: 1,
                          color: Colors.white,
                          indent: 6,
                          endIndent: 6,
                        ),
                        Text(
                          'End',
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
                          'Sunnah',
                          textAlign: TextAlign.center,
                          style: columnTitlesTextStyle,
                        ),
                        Text(
                          'Before',
                          textAlign: TextAlign.center,
                          style: columnTitlesTextStyle,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1000,
                    child: Text(
                      'Fard',
                      textAlign: TextAlign.center,
                      style: columnTitlesTextStyle,
                    ),
                  ),
                  Expanded(
                    flex: 1000,
                    child: Column(
                      children: [
                        Text(
                          'Sunnah',
                          textAlign: TextAlign.center,
                          style: columnTitlesTextStyle,
                        ),
                        Text(
                          'After',
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
                        // Checkbox(
                        //   value: c.showSunnahMuak,
                        //   onChanged: (bool? value) {
                        //     c.setShowSunnahMuak(value!);
                        //   },
                        // ),
                        Text(
                          "Show Sunnah?:",
                          style: TextStyle(fontSize: 8),
                        ),
                        InkWell(
                          onTap: () {
                            c.toggleShowSunnahMuak();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Container(
                              color: Colors.green
                                  .withOpacity(c.showSunnahMuak ? 1 : 0),
                              child: Center(
                                child: Text(
                                  "Muakkadah",
                                  style: TextStyle(fontSize: 8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            c.toggleShowSunnahNafl();
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: Container(
                              color: Colors.amber.shade700
                                  .withOpacity(c.showSunnahNafl ? 1 : 0),
                              child: Center(
                                child: Text(
                                  "Nafl",
                                  style: TextStyle(fontSize: 8),
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
            )
          ],
        );
      },
    );
  }

  SliverPersistentHeader SalahActions(
    final FARD_SALAH fardSalah,
    final String rakatNaflBefore,
    final String rakatMuakBefore,
    final String rakatFard,
    final String rakatMuakAfter,
    final String rakatNaflAfter,
  ) {
    const double boxHeight = 75;
    const Color textColor = Colors.white;

    bool isActiveSalah = fardSalah == activeSalah;

    List<String> startTimeList = [
      '05:21:31',
      '12:21:31',
      '17:21:31',
      '19:21:31',
      '21:21:31'
    ];
    List<String> endTimeList = [
      '06:21:31',
      '13:21:31',
      '18:21:31',
      '21:21:31',
      '05:21:31'
    ];

    final String startTime = startTimeList[fardSalah.index];
    final String endTime = endTimeList[fardSalah.index];

    TextStyle actionTextStyle = TextStyle(
        color: Colors.white, fontSize: 10.0, fontWeight: FontWeight.bold);

    int fardFlex = 3000;

    bool showSunnahColumns = false;

    return SliverPersistentHeader(
      pinned: fardSalah == activeSalah,
      delegate: _SliverAppBarDelegate(
        minHeight: boxHeight,
        maxHeight: boxHeight,
        child: GetBuilder<QuestController>(
          init: QuestController(),
          builder: (c) {
            if (c.showSunnahMuak || c.showSunnahNafl) {
              showSunnahColumns = true;
              fardFlex = 1000;
            }
            return Row(
              //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 1000,
                  child: Container(
                    color: isActiveSalah
                        ? Colors.green // make active salah stand out
                        : Colors.black, // hide slivers scrolling behind
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: const Radius.circular(15.0),
                        bottomLeft: const Radius.circular(15.0),
                      ),
                      child: Container(
                        color: Colors.lightBlue.shade800,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              fardSalah.toString().split('.').last,
                              style: actionTextStyle,
                              textAlign: TextAlign.center,
                            ),
                            Icon(Icons.alarm, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1000,
                  child: Container(
                    color: Colors.lightBlue.shade700,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          startTime,
                          style: actionTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        Divider(
                          height: 2,
                          thickness: 1,
                          color: Colors.white,
                          // indent: 8,
                          // endIndent: 8,
                        ),
                        Text(
                          endTime,
                          style: actionTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                if (showSunnahColumns)
                  Expanded(
                    flex: 1000,
                    child: Container(
                      color: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (c.showSunnahMuak && rakatMuakBefore != '')
                            Text(
                              rakatMuakBefore,
                              style: actionTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          if (c.showSunnahNafl && rakatNaflBefore != '')
                            Text(
                              rakatNaflBefore,
                              style: actionTextStyle,
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
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
                if (showSunnahColumns)
                  Expanded(
                    flex: 1000,
                    child: Column(
                      //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (showSunnahColumns &&
                            rakatMuakAfter == '' &&
                            rakatNaflAfter == '')
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
                        if (c.showSunnahNafl && fardSalah == FARD_SALAH.Isha)
                          Expanded(
                            child: Container(
                              color: Colors.amber.shade700,
                              child: Center(
                                child: Text(
                                  '2',
                                  style: actionTextStyle,
                                ),
                              ),
                            ),
                          ),
                        if (c.showSunnahMuak && fardSalah == FARD_SALAH.Isha)
                          Expanded(
                            child: Container(
                              color: Colors.blue.shade700,
                              child: Center(
                                child: Text(
                                  '3 Witr',
                                  style: actionTextStyle,
                                ),
                              ),
                            ),
                          ),
                        if (c.showSunnahNafl && rakatNaflAfter != '')
                          Expanded(
                            child: Container(
                              color: Colors.amber.shade700,
                              child: Center(
                                child: Text(
                                  rakatNaflAfter,
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
                  flex: 1000,
                  child: Container(
                    color: Colors.purple,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Zikr",
                          style: actionTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1000,
                  child: Container(
                    color: isActiveSalah
                        ? Colors.green // make active salah stand out
                        : Colors.black, // hide slivers scrolling behind
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
        ),
      ),
    );
  }

  SliverPersistentHeader spacingHeader(FARD_SALAH fardSalah) {
    return SliverPersistentHeader(
      pinned: fardSalah == activeSalah,
      delegate: _SliverAppBarDelegate(
        minHeight: 5.0,
        maxHeight: 5.0,
        child: Container(
          color: Colors.black,
          // child: Center(
          //   child: Text(''),
          // ),
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
          // child: Center(
          //   child: Text(''),
          // ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isJummah = true;

    return GetBuilder<QuestController>(
      init: QuestController(),
      builder: (c) => Container(
        color: Colors.black,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              backgroundColor: Colors.lightBlue.shade900,
              expandedHeight: 300.0,
              collapsedHeight: 100.0,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: SalahAppBar(activeSalah),
                  background: Swiper(
                    itemCount: 1,
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
            SalahActions(FARD_SALAH.Fajr, '', '2', '2', '', ''),
            spacingHeader(FARD_SALAH.Fajr),
            isJummah
                ? SalahActions(FARD_SALAH.Dhuhr, '', '4', '4', '2', '2')
                : SalahActions(FARD_SALAH.Dhuhr, '', '4', '2', '4+2', '2'),
            spacingHeader(FARD_SALAH.Dhuhr),
            SalahActions(FARD_SALAH.Asr, '4', '', '4', '', ''),
            spacingHeader(FARD_SALAH.Asr),
            SalahActions(FARD_SALAH.Maghrib, '', '', '3', '2', '2'),
            spacingHeader(FARD_SALAH.Maghrib),
            SalahActions(FARD_SALAH.Isha, '4', '', '4', '2', '2'),
            spacingHeader(FARD_SALAH.Isha),
            SliverGrid(
              gridDelegate: new SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 4.0,
              ),
              delegate: new SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return new Container(
                    alignment: Alignment.center,
                    color: Colors.teal[100 * (index % 9)],
                    child: new Text('grid item $index'),
                  );
                },
                childCount: 20,
              ),
            ),
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
