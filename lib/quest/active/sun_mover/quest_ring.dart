import 'package:flutter/material.dart';
import 'package:hapi/quest/active/active_quests_ajr_controller.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/multi_color_ring.dart';
import 'package:hapi/settings/theme/app_themes.dart';

class QuestRing extends StatelessWidget {
  const QuestRing(this.diameter, this.strokeWidth, this.colorSlices);

  final double diameter;
  final double strokeWidth;
  final Map<Z, ColorSlice> colorSlices;

  // TODO clean this up
  Map<Z, ColorSlice> _buildQuestRingSlices() {
    Map<Z, ColorSlice> questRingSlices = {};

    Map<Z, int> questRingColors = ActiveQuestsAjrController.to.questRingColors;

    Z z;
    double elapsedSecs;
    Color color;

    z = Z.Last_3rd_of_Night;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Last_3rd_of_Night]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Middle_of_Night;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Middle_of_Night]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Isha;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Isha]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Maghrib;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Maghrib]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Ghurub]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Asr;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Asr]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Dhuhr;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Dhuhr]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Duha;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Istiwa]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Duha]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Ishraq]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Shuruq]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Fajr;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Fajr]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdx[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    return questRingSlices;
  }

  @override
  Widget build(BuildContext context) {
    final Map<Z, ColorSlice> questRingSlices = _buildQuestRingSlices();

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
