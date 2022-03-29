import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/menu/toggle_switch.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class ActiveQuestsSettingsUI extends StatelessWidget {
  final TextStyle textStyleTitle = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
  final TextStyle textStyleBtn = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ActiveQuestsController>(
      builder: (c) {
        return Column(
          // TODO tune
          //mainAxisSize: MainAxisSize.min,
          //mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Tooltip(
              message: 'Select the salah time calculation method',
              child: Text(
                'Calculation Method',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
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
              items: List<int>.generate(CalcMethod.values.length - 1, (i) => i)
                  .map<DropdownMenuItem<int>>(
                (int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Container(
                      color: AppThemes.selected
                          .withOpacity(c.salahCalcMethod == value ? 1 : 0),
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
            const SizedBox(height: 10),
            Tooltip(
              message:
                  'Ulema opinions on Asr start time are when an object\'s shadow is either 2 times its lengths (later) or 1 times its length (earlier)',
              child: Text(
                'Asr Start',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 45.0,
              fontSize: 14,
              initialLabelIndex: c.salahAsrSafe ? 0 : 1,
              labels: ['Later', 'Earlier'],
              //cornerRadius: 20.0,
              activeBgColor: AppThemes.selected,
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
            const SizedBox(height: 10),
            Tooltip(
              message:
                  'Ulema opinions on karahat times are around 40 or 20 for sunset and sunrise karahat times and around 30 or 15 minutes for the noon karahat time',
              child: Text(
                'Karahat Times (Minutes)',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 45.0,
              fontSize: 14,
              initialLabelIndex: c.salahKarahatSafe ? 0 : 1,
              labels: ['40/30/40', '20/15/20'],
              //cornerRadius: 20.0,
              activeBgColor: AppThemes.selected,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey, //const Color(0xFF1D1E33),
              inactiveFgColor: Colors.white,
              onToggle: (index) {
                if (index == 0) {
                  c.salahKarahatSafe = true;
                } else {
                  c.salahKarahatSafe = false;
                }
              },
            ),
            const SizedBox(height: 10),
            Tooltip(
              message:
                  'Choice between showing Jummah Salah on Friday (if you go to Jummah) or set to Dhuhr which acts like non-Jummah days',
              child: Text(
                'Friday Default',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 45.0,
              fontSize: 14,
              initialLabelIndex: c.showJummahOnFriday ? 0 : 1,
              labels: ['Jummah', 'Dhuhr'],
              //cornerRadius: 20.0,
              activeBgColor: AppThemes.selected,
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
            const SizedBox(height: 10),
            Tooltip(
              message:
                  'Choice between showing Last 1/3 of the night or middle of the night, for Tahajjud alarm',
              child: Text(
                'Night Default',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 45.0,
              fontSize: 14,
              initialLabelIndex: c.showLast3rdOfNight ? 0 : 1,
              labels: ['Last 1/3', 'Middle'],
              //cornerRadius: 20.0,
              activeBgColor: AppThemes.selected,
              activeFgColor: Colors.white,
              inactiveBgColor: Colors.grey, //const Color(0xFF1D1E33),
              inactiveFgColor: Colors.white,
              onToggle: (index) {
                if (index == 0) {
                  c.showLast3rdOfNight = true;
                } else {
                  c.showLast3rdOfNight = false;
                }
              },
            ),
            const SizedBox(height: 10),
            Tooltip(
              message:
                  'Gives choice between 12 hour clock (AM/PM) or 24 hour clock (military time)',
              child: Text(
                'Clock Type',
                textAlign: TextAlign.center,
                style: textStyleTitle,
              ),
            ),
            const SizedBox(height: 3),
            ToggleSwitch(
              minWidth: 100.0,
              minHeight: 45.0,
              fontSize: 14,
              initialLabelIndex: c.show12HourClock ? 0 : 1,
              labels: ['12 hour', '24 hour'],
              //cornerRadius: 20.0,
              activeBgColor: AppThemes.selected,
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
