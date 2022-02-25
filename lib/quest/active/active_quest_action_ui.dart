import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/TOD.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class ActiveQuestActionUI extends StatelessWidget {
  final ActiveQuestsController cQstA = Get.find();

  late final QUEST _quest;
  late final Widget _callerWidget;
  late final bool _pinned;

  bool skipEnabled = true;
  bool doneEnabled = true;
  String? noActionMsg;

  static const TextStyle tsBtn = TextStyle(fontSize: 32);
  static const TextStyle tsMsg = TextStyle(fontSize: 15, color: Colors.red);

  ActiveQuestActionUI() {
    _quest = Get.arguments['quest'];
    _callerWidget = Get.arguments['widget'];
    _pinned = Get.arguments['pinned'];

    // not allowed to skip fard
    if (_quest.isFard()) {
      skipEnabled = false;
    }

    // if active quest is not completed, we can undo last quest
    bool isPreviousQuest = cAjrA.getPrevQuest() == _quest;

    // ACTUALLY: it is ok to change last time ALWAYS (to be nice)
    // // don't count as previous quest if it was in another salah row/time:
    // if (isPreviousQuest) {
    //   if (cAjrA.getPrevQuest().salahRow() != cAjrA.getCurrQuest().salahRow()) {
    //     isPreviousQuest = false;
    //   }
    // }

    // TODO Cleanup logic when mind is fresh
    if (!isPreviousQuest || cAjrA.isDone(_quest)) {
      if (!cAjrA.isQuestActive(_quest)) {
        skipEnabled = false;
        doneEnabled = false;
        noActionMsg = 'Complete other quests first';
      }

      if (cAjrA.isMiss(_quest)) {
        skipEnabled = false;
        doneEnabled = false;
        noActionMsg = 'Quest expired, try again tomorrow';
        // if all row quests done, don't allow next row to be started yet
      } else {
        TOD currTOD = cQstA.tod!.currTOD;
        if ((!_pinned && !isPreviousQuest) ||
            // For Adhkhar/Duha times we don't allow user to start task until
            // the quest's time comes in:
            (_quest.isQuestCellTimeBound() &&
                _quest.index != currTOD.getFirstQuest().index)) {
          skipEnabled = false;
          doneEnabled = false;
          noActionMsg = 'Quest not active yet';
        }
      }

      if (cAjrA.isSkip(_quest)) {
        skipEnabled = false;
        doneEnabled = false;
        noActionMsg = 'Quest was skipped';
      }

      if (cAjrA.isDone(_quest)) {
        skipEnabled = false;
        doneEnabled = false;
        noActionMsg = 'Quest already completed';
      }
    }
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
                  if (skipEnabled)
                    Tooltip(
                      message: 'Skip to the next active quest',
                      child: TextButton.icon(
                        label: Text('Skip', style: tsBtn),
                        icon: const Icon(Icons.redo_outlined),
                        onPressed: () {
                          if (cAjrA.isDone(_quest) || cAjrA.isMiss(_quest)) {
                            if (cAjrA.isDone(_quest)) {
                              //TODO remove points
                            }
                            cAjrA.clearQuest(_quest);
                          }
                          cAjrA.setSkip(_quest);
                          cMenu.handleBackButtonHit();
                        },
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ),
                  if (skipEnabled && doneEnabled) SizedBox(width: 20),
                  if (doneEnabled)
                    Tooltip(
                      message: 'Mark this active quest as completed',
                      child: TextButton.icon(
                        label: Text('Done', style: tsBtn),
                        icon: const Icon(Icons.check_outlined),
                        onPressed: () {
                          if (cAjrA.isSkip(_quest) || cAjrA.isMiss(_quest)) {
                            cAjrA.clearQuest(_quest);
                          }
                          cAjrA.setDone(_quest); //TODO add points
                          cMenu.handleBackButtonHit();
                          cMenu.playConfetti();
                        },
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  if (skipEnabled && doneEnabled) SizedBox(width: 40),
                  if (noActionMsg != null)
                    Column(
                      children: [
                        Text(noActionMsg!, style: tsMsg),
                        SizedBox(height: 16),
                      ],
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
