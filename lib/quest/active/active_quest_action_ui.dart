import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/fab_sub_page.dart';
import 'package:hapi/menu/menu_controller.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/zaman_controller.dart';

class ActiveQuestActionUI extends StatelessWidget {
  late final Z z;
  late final QUEST quest;
  late final Widget callerWidget;
  late final bool isCurrQuestOriginal;

  static const TextStyle tsBtn = TextStyle(fontSize: 32);
  static const TextStyle tsMsg = TextStyle(fontSize: 15, color: Colors.red);

  ActiveQuestActionUI() {
    z = Get.arguments['z'];
    quest = Get.arguments['quest'];
    callerWidget = Get.arguments['widget'];
    isCurrQuestOriginal = Get.arguments['isCurrQuest'];
  }

  @override
  Widget build(BuildContext context) {
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
                Text('pre ' + quest.salahRow() + ' '),
                Hero(
                  tag: quest,
                  child: callerWidget,
                ),
                Text(' post ' + quest.salahRow()),
              ],
            ),

            /// Body
            Text('body text'),

            /// Action Buttons
            /// Do work in here so if active quest changes we can update UI so
            /// user can't submit/break quests if they expire. Also, has added
            /// benefit of waking enabling action buttons if quest wasn't
            /// active yet.
            GetBuilder<ActiveQuestsController>(builder: (c) {
              bool isCurrQuest = ZamanController.to.isCurrQuest(z, quest);
              if (isCurrQuestOriginal != isCurrQuest) {
                // TODO hapi quest to break UI?
                l.w('Quest has started or expired, user left dialog open during zaman transition');
              }

              bool skipEnabled = true;
              bool doneEnabled = true;
              String noActionMsg = '';

              // not allowed to skip fard
              if (quest.isFard) {
                skipEnabled = false;
              }

              ActiveQuestsAjrController cAjrA = ActiveQuestsAjrController.to;

              // if active quest is not completed, we can undo last quest
              bool isPreviousQuest = cAjrA.getPrevQuest() == quest;

              // ACTUALLY: it is ok to change last time ALWAYS (to be nice)
              // // don't count as previous quest if it was in another salah row/time:
              // if (isPreviousQuest) {
              //   if (cAjrA.getPrevQuest().salahRow() != cAjrA.getCurrQuest().salahRow()) {
              //     isPreviousQuest = false;
              //   }
              // }

              // TODO Cleanup logic when mind is fresh
              if (!isPreviousQuest || cAjrA.isDone(quest)) {
                if (!cAjrA.isQuestActive(quest)) {
                  skipEnabled = false;
                  doneEnabled = false;
                  noActionMsg = 'Complete other quests first';
                }

                if (cAjrA.isMiss(quest)) {
                  skipEnabled = false;
                  doneEnabled = false;
                  noActionMsg = 'Quest expired, try again tomorrow';
                  // if all row quests done, don't allow next row to be started yet
                } else {
                  if ((!isCurrQuest && !isPreviousQuest) ||
                      // For Ishraq, Duha and Maghrib fard, we don't allow user
                      // to start task until the quest's time comes in:
                      (quest.isQuestCellTimeBound &&
                          quest != ZamanController.to.currZ.getFirstQuest())) {
                    skipEnabled = false;
                    doneEnabled = false;
                    noActionMsg = 'Quest not active yet';
                  }
                }

                if (cAjrA.isSkip(quest)) {
                  skipEnabled = false;
                  doneEnabled = false;
                  noActionMsg = 'Quest was skipped';
                }

                if (cAjrA.isDone(quest)) {
                  skipEnabled = false;
                  doneEnabled = false;
                  noActionMsg = 'Quest already completed';
                }
              }

              return Row(
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
                          if (cAjrA.isDone(quest) || cAjrA.isMiss(quest)) {
                            if (cAjrA.isDone(quest)) {
                              //TODO remove points (once that system is built)
                            }
                            cAjrA.setClearQuest(quest);
                          }
                          cAjrA.setSkip(quest);
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
                          if (cAjrA.isSkip(quest) || cAjrA.isMiss(quest)) {
                            cAjrA.setClearQuest(quest); // doesn't write to DB
                          }
                          cAjrA.setDone(quest); // writes to DB
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
              );
            }),
          ],
        ),
      ),
    );
  }
}
