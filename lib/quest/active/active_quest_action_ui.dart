import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/constants/app_themes.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';

class ActiveQuestActionUI extends StatelessWidget {
  late final QUEST _quest;
  late final Widget _callerWidget;

  ActiveQuestActionUI() {
    _quest = Get.arguments['quest'];
    _callerWidget = Get.arguments['widget'];
  }

  @override
  Widget build(BuildContext context) {
    return FabSubPage(
      subPage: SubPage.ACTIVE_QUEST_ACTION,
      child: Container(
        color: AppThemes.logoBackground,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// Title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TODO internationalize/add text
                  Text('pre ' + _quest.salahRow() + ' '),
                  Hero(
                    tag: _quest,
                    child: _callerWidget,
                  ),
                  Text(' post ' + _quest.salahRow()),
                ],
              ),

              /// Body
              Text('body text'),

              /// Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tooltip(
                    message: 'Skip to the next active quest',
                    child: TextButton.icon(
                      label: Text('Skip'),
                      icon: const Icon(Icons.redo_outlined),
                      onPressed: () {
                        cAjrA.setSkip(_quest);
                        cMenu.handleBackButtonHit();
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Tooltip(
                    message: 'Mark this active quest as completed',
                    child: TextButton.icon(
                      label: Text('Done'),
                      icon: const Icon(Icons.check_outlined),
                      onPressed: () {
                        cAjrA.setDone(_quest);
                        cMenu.handleBackButtonHit();
                        cMenu.playConfetti();
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
