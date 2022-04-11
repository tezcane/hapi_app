import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/toggle_switch.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/settings/theme/app_themes.dart';

typedef OnToggle = void Function(int index);

class ActiveQuestsSettingsUI extends StatelessWidget {
  final TextStyle tsTitle = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
  final TextStyle textStyleBtn = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);

  Widget addSetting({
    required String title,
    required String tooltip,
    required List<String> labels,
    required int initialLabelIndex,
    required OnToggle onToggle,
  }) {
    return Tooltip(
      message: tooltip,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: T(title, tsTitle, w: 150, h: 16, boxFit: BoxFit.contain),
          ),
          const SizedBox(height: 3),
          ToggleSwitch(
            minWidth: 100.0,
            minHeight: 45.0,
            fontSize: 14,
            initialLabelIndex: initialLabelIndex,
            labels: labels,
            //cornerRadius: 20.0,
            activeBgColor: AppThemes.selected,
            activeFgColor: Colors.white,
            inactiveBgColor: Colors.grey, //const Color(0xFF1D1E33),
            inactiveFgColor: Colors.white,
            onToggle: onToggle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        return Column(
          children: [
            Tooltip(
              message: 'Select the salah time calculation method',
              child: Column(
                children: [
                  Center(
                    child: T('Calculation Method', tsTitle,
                        w: 150, h: 16, boxFit: BoxFit.contain),
                  ),
                  const SizedBox(height: 2),
                  DropdownButton<int>(
                    isExpanded: true,
                    isDense: false,
                    value: c.salahCalcMethod,
                    //icon: const Icon(Icons.arrow_downward),
                    iconEnabledColor: Colors.white,
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
                    items: List<int>.generate(
                            CalcMethod.values.length - 1, (i) => i)
                        .map<DropdownMenuItem<int>>(
                      (int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Container(
                            color: AppThemes.selected.withOpacity(
                                c.salahCalcMethod == value ? 1 : 0),
                            child: Center(
                              child: Text(
                                CalcMethod.values[value].niceName,
                                textAlign: TextAlign.center,
                                //textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              ),
            ),
            addSetting(
              title: 'Asr Time',
              tooltip:
                  'Ulema opinions on Asr start time are when an object\'s shadow is either 2 times its lengths (later) or 1 times its length (earlier)',
              labels: ['Later', 'Earlier'],
              initialLabelIndex: c.salahAsrSafe ? 0 : 1,
              onToggle: (index) {
                if (index == 0) {
                  c.salahAsrSafe = true;
                } else {
                  c.salahAsrSafe = false;
                }
              },
            ),
            addSetting(
              title: 'Layl Time',
              tooltip:
                  'For layl time, show last 1/3 of the night or last half of the night',
              labels: ['Last 1/3', 'Last 1/2'],
              initialLabelIndex: c.last3rdOfNight ? 0 : 1,
              onToggle: (index) {
                if (index == 0) {
                  c.last3rdOfNight = true;
                } else {
                  c.last3rdOfNight = false;
                }
              },
            ),
            addSetting(
              title: 'Round Time To',
              tooltip: 'Round times to the minute or second',
              labels: ['Minute', 'Second'],
              initialLabelIndex: c.showSecPrecision ? 1 : 0,
              onToggle: (index) {
                if (index == 0) {
                  c.showSecPrecision = false;
                } else {
                  c.showSecPrecision = true;
                }
              },
            ),
            addSetting(
              title: 'Karahat Minutes',
              tooltip:
                  'Ulema opinions on karahat times are around 40 or 20 for sunset and sunrise karahat times and around 30 or 15 minutes for the noon karahat time',
              labels: ['40, 30, 40', '20, 15, 20'],
              initialLabelIndex: c.salahKarahatSafe ? 0 : 1,
              onToggle: (index) {
                if (index == 0) {
                  c.salahKarahatSafe = true;
                } else {
                  c.salahKarahatSafe = false;
                }
              },
            ),
            addSetting(
              title: 'Friday Default',
              tooltip:
                  'Choice between showing Jummah Salah on Friday (if you go to Jummah) or set to Dhuhr which acts like non-Jummah days',
              labels: ['Jummah', 'Dhuhr'],
              initialLabelIndex: c.showJummahOnFriday ? 0 : 1,
              onToggle: (index) {
                if (index == 0) {
                  c.showJummahOnFriday = true;
                } else {
                  c.showJummahOnFriday = false;
                }
              },
            ),
            addSetting(
              title: 'Clock Type',
              tooltip:
                  'Gives choice between 12 hour clock (AM/PM) or 24 hour clock (military time)',
              labels: ['12 Hour', '24 Hour'],
              initialLabelIndex: c.show12HourClock ? 0 : 1,
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
