import 'dart:math' as math;

import 'package:bottom_bar/bottom_bar.dart';
import 'package:flutter/material.dart';
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
  Maghrib,
  Isha,
  Fajr,
  Dhuhr,
  Asr,
}

class QuestsActive extends StatelessWidget {
  FARD_SALAH activeSalah = FARD_SALAH.Maghrib;

  SliverPersistentHeader SalahHeader(FARD_SALAH fardSalah) {
    return SliverPersistentHeader(
      pinned: fardSalah == activeSalah,
      delegate: _SliverAppBarDelegate(
        minHeight: fardSalah == activeSalah ? 80.0 : 40,
        maxHeight: fardSalah == activeSalah ? 80.0 : 40,
        child: Container(
          color: Colors.black, // hide slivers scrolling behind
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topRight: const Radius.circular(15.0),
              topLeft: const Radius.circular(15.0),
            ),
            child: Container(
              color: Colors.lightBlue.shade200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(height: 10),
                  Container(
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 20),
                        Text(fardSalah.toString().split('.').last,
                            style: TextStyle(
                                color: Colors.blue.shade700, fontSize: 20.0)),
                        SizedBox(width: 20),
                        Text('8:31 - 9:47 PM',
                            style: TextStyle(color: Colors.white)),
                        if (fardSalah == activeSalah)
                          Row(
                            children: [
                              SizedBox(width: 20),
                              Icon(Icons.hourglass_bottom_outlined),
                              Text('1:31:45',
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      //mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.alarm),
                        SizedBox(width: 20),
                        Icon(Icons.push_pin_outlined),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  SliverPersistentHeader SalahActions(
    final FARD_SALAH fardSalah,
    final fardFlex,
    final rakatNalfBefore,
    final rakatMuakBefore,
    final rakatFard,
    final rakatMuakAfter,
    final rakatNalfAfter,
  ) {
    const double boxHeight = 50;
    const Color textColor = Colors.white;

    // int fardFlex = 1000;
    //
    // if (fardSalah == FARD_SALAH.Maghrib) {
    //   rakatMuakAfter = 2;
    //   fardFlex = 2000;
    // } else if (fardSalah == FARD_SALAH.Isha) {
    //   rakatMuakAfter = 2;
    //   fardFlex = 2000;
    // } else if (fardSalah == FARD_SALAH.Fajr) {
    //   rakatMuakBefore = 2;
    //   fardFlex = 2000;
    // } else if (fardSalah == FARD_SALAH.Dhuhr) {
    //   rakatMuakBefore = 4;
    //   rakatMuakAfter = 2;
    //   fardFlex = 1000;
    // } else if (fardSalah == FARD_SALAH.Asr) {
    //   fardFlex = 3000;
    // }

    return SliverPersistentHeader(
      pinned: fardSalah == activeSalah,
      delegate: _SliverAppBarDelegate(
        minHeight: boxHeight,
        maxHeight: boxHeight,
        child: Row(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Expanded(
            //   flex: 1000,
            //   child: Container(
            //     color: Colors.black, // hide slivers scrolling behind
            //     child: ClipRRect(
            //       borderRadius: const BorderRadius.only(
            //         bottomLeft: const Radius.circular(15.0),
            //       ),
            //       child: Container(
            //         color: Colors.yellow,
            //         child: Column(
            //           mainAxisAlignment: MainAxisAlignment.center,
            //           children: [Icon(Icons.alarm)],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            if (rakatMuakBefore != 0)
              Expanded(
                flex: 1000,
                child: Container(
                  color: Colors.green,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sunnah", style: TextStyle(color: textColor)),
                      SizedBox(height: 5),
                      Text("$rakatMuakBefore Rakat",
                          style: TextStyle(color: textColor)),
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
                    Text("Fard", style: TextStyle(color: textColor)),
                    SizedBox(height: 5),
                    Text("$rakatFard Rakat",
                        style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ),
            if (rakatMuakAfter != 0)
              Expanded(
                flex: 1000,
                child: Container(
                  color: Colors.green,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Sunnah", style: TextStyle(color: textColor)),
                      SizedBox(height: 5),
                      Text("$rakatMuakAfter Rakat",
                          style: TextStyle(color: textColor)),
                    ],
                  ),
                ),
              ),
            Expanded(
              flex: 1000,
              child: Container(
                color: Colors.purple,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Dhikr", style: TextStyle(color: textColor)),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1000,
              child: Container(
                color: Colors.black, // hide slivers scrolling behind
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomRight: const Radius.circular(15.0),
                  ),
                  child: Container(
                    color: Colors.orange,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Dua", style: TextStyle(color: textColor)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
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
          child: Center(
            child: Text(' '),
          ),
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
          child: Center(
            child: Text(' '),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 150.0,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text("Salah",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                    )),
                background: Swiper(
                  itemCount: 1,
                  itemBuilder: (BuildContext context, int index) => Image.asset(
                    'assets/images/quests/active$index.jpg', //TODO add more images
                    fit: BoxFit.cover,
                  ),
                  autoplay: true,
                  autoplayDelay: 10000,
                )),
          ),
          sliverSpaceHeader(true),
          SalahHeader(FARD_SALAH.Fajr),
          SalahActions(FARD_SALAH.Fajr, 2000, 0, 2, 2, 0, 0),
          spacingHeader(FARD_SALAH.Fajr),
          SalahHeader(FARD_SALAH.Dhuhr),
          SalahActions(FARD_SALAH.Dhuhr, 1000, 0, 4, 4, 2, 2),
          spacingHeader(FARD_SALAH.Dhuhr),
          SalahHeader(FARD_SALAH.Asr),
          SalahActions(FARD_SALAH.Asr, 3000, 4, 0, 4, 0, 0),
          spacingHeader(FARD_SALAH.Asr),
          SalahHeader(FARD_SALAH.Maghrib),
          SalahActions(FARD_SALAH.Maghrib, 2000, 0, 0, 3, 2, 2),
          spacingHeader(FARD_SALAH.Maghrib),
          SalahHeader(FARD_SALAH.Isha),
          SalahActions(FARD_SALAH.Isha, 2000, 4, 0, 4, 2, 2),
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
