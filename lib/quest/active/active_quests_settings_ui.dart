import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/menu/toggle_switch.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/calculation_method.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/settings/theme/app_themes.dart';

typedef OnToggle = void Function(int index);

class ActiveQuestsSettingsUI extends StatelessWidget {
  final TextStyle tsTitle = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);
  final TextStyle textStyleBtn = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14);

  static const double cornerRadius = 5.0;

  Widget addSetting({
    required String trValTitle,
    required String trValTooltip,
    required List<String> trValLabels,
    required int initialLabelIndex,
    required OnToggle onToggle,
  }) {
    return Tooltip(
      message: trValTooltip,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: T(
              trValTitle,
              tsTitle,
              w: 150,
              h: 16,
              boxFit: BoxFit.contain,
              trVal: true,
            ),
          ),
          const SizedBox(height: 3),
          ToggleSwitch(
            minWidth: 100.0,
            minHeight: 45.0,
            fontSize: 14,
            initialLabelIndex: initialLabelIndex,
            trValLabels: trValLabels,
            cornerRadius: cornerRadius,
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
              message: 'tt.calculationMethod'.tr,
              child: Column(
                children: [
                  Center(
                    child: T(
                      'i.Calculation Method',
                      tsTitle,
                      w: 150, // TODO get from slide out menu width
                      h: 16,
                      boxFit: BoxFit.contain,
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
                    borderRadius: BorderRadius.circular(cornerRadius),
                    underline: Container(height: 0),
                    onChanged: (int? newValue) => c.salahCalcMethod = newValue!,
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
              trValTitle: a(Z.Asr.trKey) + ' ' + a('a.Zaman'), // TODO hard tr
              trValTooltip: at('at.asrStartTime', ['a.Sabqan', 'a.Lahiqan']),
              trValLabels: [a('a.Sabqan'), a('a.Lahiqan')], // Earlier/Later
              initialLabelIndex: c.salahAsrEarlier ? 0 : 1,
              onToggle: (index) {
                if (index == 0) {
                  c.salahAsrEarlier = true;
                } else {
                  c.salahAsrEarlier = false;
                }
              },
            ),
            addSetting(
              trValTitle: 'i.Round Time To'.tr,
              trValTooltip: 'tt.roundTimeTo'.tr,
              trValLabels: [a('a.Daqayiq'), a('a.Thawani')], // Minutes/Seconds
              initialLabelIndex: c.showSecPrecision ? 1 : 0,
              onToggle: (index) {
                if (index == 0) {
                  c.showSecPrecision = false;
                } else {
                  c.showSecPrecision = true;
                }
              },
            ),
//          addSetting(
//            trValTitle: at('at.{0} Default', [a('a.Jumah')]),
//            trValTooltip: at('at.showJumah', [
//              a('a.Jumah'),
//              a('a.${Z.Dhuhr.name}'),
//            ]),
//            trValLabels: [
//              a('a.Jumah'),
//              a('a.${Z.Dhuhr.name}'),
//            ],
//            initialLabelIndex: c.showJumahOnFriday ? 0 : 1,
//            onToggle: (index) {
//              if (index == 0) {
//                c.showJumahOnFriday = true;
//              } else {
//                c.showJumahOnFriday = false;
//              }
//            },
//          ),
            addSetting(
              trValTitle: a('a.Saat Hayit'), // Clock
              trValTooltip: 'tt.clockType'.tr,
              trValLabels: [
                cns('12') + ' ' + a('a.Saat'), // 12 Hour, TODO hard tr
                cns('24') + ' ' + a('a.Saat'), // 24 Hour
              ],
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
