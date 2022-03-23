import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/zaman_controller.dart';

class ActiveQuestActionUI extends StatelessWidget {
  late final QUEST _quest;
  late final Widget _callerWidget;
  late final bool _isActive;

  static const TextStyle tsBtn = TextStyle(fontSize: 32);
  static const TextStyle tsMsg = TextStyle(fontSize: 15, color: Colors.red);

  ActiveQuestActionUI() {
    _quest = Get.arguments['quest'];
    _callerWidget = Get.arguments['widget'];
    _isActive = Get.arguments['isActive'];
  }

  @override
  Widget build(BuildContext context) {
    bool skipEnabled = true;
    bool doneEnabled = true;
    String noActionMsg = '';

    // not allowed to skip fard
    if (_quest.isFard()) {
      skipEnabled = false;
    }

    ActiveQuestsAjrController cAjrA = ActiveQuestsAjrController.to;

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
        Z currZ = ZamanController.to.currZ;
        if ((!_isActive && !isPreviousQuest) ||
            // For Adhkhar/Duha times we don't allow user to start task until
            // the quest's time comes in:
            (_quest.isQuestCellTimeBound() &&
                _quest.index != currZ.getFirstQuest().index)) {
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

    return FabSubPage(
      subPage: SubPage.Active_Quest_Action,
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
                        // Handle's the sub page back button functionality
                        MenuController.to.handlePressedFAB();
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
                if (skipEnabled && doneEnabled) const SizedBox(width: 20),
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
                        // Handle's the sub page back button functionality
                        MenuController.to.handlePressedFAB();
                        MenuController.to.playConfetti();
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                if (skipEnabled && doneEnabled) const SizedBox(width: 40),
                if (noActionMsg != '')
                  Column(
                    children: [
                      Text(noActionMsg, style: tsMsg),
                      const SizedBox(height: 16),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
