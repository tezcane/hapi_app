import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_c.dart';
import 'package:hapi/menu/menu_c.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/menu/sub_page.dart';
import 'package:hapi/quest/active/active_quests_ajr_c.dart';
import 'package:hapi/quest/active/active_quests_c.dart';
import 'package:hapi/quest/active/athan/z.dart';

class ActiveQuestActionUI extends StatelessWidget {
  ActiveQuestActionUI() {
    z = Get.arguments['z'];
    q = Get.arguments['quest'];
    callerWidget = Get.arguments['widget'];
  }
  late final Z z;
  late final QUEST q;
  late final Widget callerWidget;

  @override
  Widget build(BuildContext context) {
    const double iconSize = 30;
    const double buttonGap = 5;
    const double fabGap = 85;

    double width = w(context);
    double w1 = width - fabGap * 2;
    double w2 = (width - fabGap * 2 - iconSize * 2 - buttonGap) / 2 - 25;

    return FabSubPage(
      subPage: SubPage.Active_Quest_Action,
      child: Scaffold(
        backgroundColor: cb(context),
        appBar: AppBar(
          elevation: 15, // cool effect under app bar
          shadowColor: AppThemes.ldTextColor,
          centerTitle: true,
          backgroundColor: cf(context),
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: [
              Hero(tag: q, child: callerWidget),
              T(q.name, tsB, w: width / 2),
            ],
          ),
        ),
        body: Text('body text'),
        bottomNavigationBar:
            // Do work in here so if active quest builder so we can update this
            // UI if Quest's time comes in/out while this dialog is open.
            GetBuilder<ActiveQuestsC>(builder: (c) {
          QUEST_STATE questState = q.getActionState();

          String? tk;
          if (questState == QUEST_STATE.DONE) {
            tk = 'Quest was already completed';
          } else if (questState == QUEST_STATE.SKIP) {
            tk = 'Quest skipped, try again tomorrow';
          } else if (questState == QUEST_STATE.MISS) {
            tk = 'Quest expired, try again tomorrow';
          } else if (questState == QUEST_STATE.NOT_ACTIVE_YET) {
            tk = 'Quest is not active yet';
          } // else if (questState == QUEST_STATE.ACTIVE_CURR_QUEST) {
          // } else if (questState == QUEST_STATE.ACTIVE) {}

          if (tk != null) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(width: fabGap),
                    T(tk, tsRe, w: w1),
                    const SizedBox(width: fabGap),
                  ],
                ),
                const SizedBox(height: 21), // put text at FAB height
              ],
            );
          }

          ActiveQuestsAjrC cAjrA = ActiveQuestsAjrC.to;
          bool skipEnabled = !q.isFard; // not allowed to skip fard

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: fabGap),
                  if (skipEnabled)
                    Tooltip(
                      message: at(
                        'at.Tap to skip quest, you will lose {0}',
                        ['a.Ajr'],
                      ),
                      child: TextButton.icon(
                        label: T('Skip'.tr, tsB, w: w2, tv: true),
                        icon: const Icon(Icons.redo_outlined, size: iconSize),
                        onPressed: () {
                          // if (cAjrA.isDone(quest) || cAjrA.isMiss(quest)) {
                          //   if (cAjrA.isDone(quest)) {
                          //     //remove points (once that system is built)
                          //   }
                          //   cAjrA.setClearQuest(quest);
                          // }
                          cAjrA.setSkip(q);
                          // Handle's the sub page back button functionality
                          MenuC.to.handlePressedFAB();
                        },
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                          backgroundColor: AppThemes.unselected,
                        ),
                      ),
                    ),
                  if (skipEnabled) const SizedBox(width: buttonGap),
                  Tooltip(
                    message: 'Tap to complete quest'.tr,
                    child: TextButton.icon(
                      label: T('Done'.tr, tsB, w: w2, tv: true),
                      icon: const Icon(Icons.check_outlined, size: iconSize),
                      onPressed: () {
                        // if (cAjrA.isSkip(q) || cAjrA.isMiss(q)) {
                        //   cAjrA.setClearQuest(q); // doesn't write to DB
                        // }
                        cAjrA.setDone(q); // writes to DB
                        // Handle's the sub page back button functionality
                        MenuC.to.handlePressedFAB();
                        MenuC.to.playConfetti();
                      },
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: AppThemes.selected,
                      ),
                    ),
                  ),
                  const SizedBox(width: fabGap),
                ],
              ),
              const SizedBox(height: 21), // put button(s) at FAB height
            ],
          );
        }),
      ),
    );
  }
}
