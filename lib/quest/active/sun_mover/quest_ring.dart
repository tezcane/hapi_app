import 'package:flutter/material.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/active_quests_controller.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/multi_color_ring.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class QuestRing extends StatelessWidget {
  const QuestRing(this.diameter, this.strokeWidth, this.colorSlices);

  final double diameter;
  final double strokeWidth;
  final Map<Z, ColorSlice> colorSlices;

  Map<ZR, ColorSlice> _buildQuestRingSlices() {
    Map<ZR, ColorSlice> questRingSlices = {};

    Map<ZR, int> questRingColors = ActiveQuestsAjrController.to.questRingColors;

    ZR zR;
    double elapsedSecs = 0;
    Color color;

    if (ActiveQuestsController.to.last3rdOfNight) {
      zR = ZR.Layl;
      elapsedSecs = 0;
      elapsedSecs += colorSlices[Z.Layl__3]!.elapsedSecs;
      color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
      questRingSlices[zR] = ColorSlice(elapsedSecs, color);

      zR = ZR.Isha;
      elapsedSecs = 0;
      elapsedSecs += colorSlices[Z.Layl__2]!.elapsedSecs;
      elapsedSecs += colorSlices[Z.Isha]!.elapsedSecs;
      color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
      questRingSlices[zR] = ColorSlice(elapsedSecs, color);
    } else {
      zR = ZR.Layl;
      elapsedSecs = 0;
      elapsedSecs += colorSlices[Z.Layl__3]!.elapsedSecs;
      elapsedSecs += colorSlices[Z.Layl__2]!.elapsedSecs;
      color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
      questRingSlices[zR] = ColorSlice(elapsedSecs, color);

      zR = ZR.Isha;
      elapsedSecs = 0;
      elapsedSecs += colorSlices[Z.Isha]!.elapsedSecs;
      color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
      questRingSlices[zR] = ColorSlice(elapsedSecs, color);
    }

    zR = ZR.Maghrib;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Maghrib]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
    questRingSlices[zR] = ColorSlice(elapsedSecs, color);

    if (!ActiveQuestsController.to.salahAsrEarlier) {
      zR = ZR.Asr;
      elapsedSecs = 0;
      elapsedSecs += colorSlices[Z.Karahat_Evening_Adhkar]!.elapsedSecs;
      elapsedSecs += colorSlices[Z.Asr_Later]!.elapsedSecs;
      color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
      questRingSlices[zR] = ColorSlice(elapsedSecs, color);

      zR = ZR.Dhuhr;
      elapsedSecs = 0;
      elapsedSecs += colorSlices[Z.Asr_Earlier]!.elapsedSecs;
      elapsedSecs += colorSlices[Z.Dhuhr]!.elapsedSecs;
      color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
      questRingSlices[zR] = ColorSlice(elapsedSecs, color);
    } else {
      zR = ZR.Asr;
      elapsedSecs = 0;
      elapsedSecs += colorSlices[Z.Karahat_Evening_Adhkar]!.elapsedSecs;
      elapsedSecs += colorSlices[Z.Asr_Later]!.elapsedSecs;
      elapsedSecs += colorSlices[Z.Asr_Earlier]!.elapsedSecs;
      color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
      questRingSlices[zR] = ColorSlice(elapsedSecs, color);

      zR = ZR.Dhuhr;
      elapsedSecs = 0;
      elapsedSecs += colorSlices[Z.Dhuhr]!.elapsedSecs;
      color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
      questRingSlices[zR] = ColorSlice(elapsedSecs, color);
    }

    zR = ZR.Duha;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Karahat_Istiwa]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Duha]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Ishraq]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Karahat_Morning_Adhkar]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
    questRingSlices[zR] = ColorSlice(elapsedSecs, color);

    zR = ZR.Fajr;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Fajr]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[zR]!];
    questRingSlices[zR] = ColorSlice(elapsedSecs, color);

    return questRingSlices;
  }

  @override
  Widget build(BuildContext context) {
    final Map<ZR, ColorSlice> questRingSlices = _buildQuestRingSlices();

    // RepaintBoundary prevents the ALWAYS repaint on ANY page update
    return Center(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          children: [
            // RepaintBoundary needed or it will repaint on every second tick
            RepaintBoundary(
              child: CustomPaint(
                painter: MultiColorRing(questRingSlices, diameter, strokeWidth),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
