import 'package:flutter/material.dart';
import 'package:hapi/menu/slide/menu_bottom/settings/theme/app_themes.dart';
import 'package:hapi/quest/active/active_quests_ajr_c.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/multi_color_ring.dart';

class QuestRing extends StatelessWidget {
  const QuestRing(this.diameter, this.strokeWidth, this.colorSlices);
  final double diameter;
  final double strokeWidth;
  final Map<Z, ColorSlice> colorSlices;

  // TODO clean this up
  Map<Z, ColorSlice> _buildQuestRingSlices() {
    Map<Z, ColorSlice> questRingSlices = {};

    Map<Z, int> questRingColors = ActiveQuestsAjrC.to.questRingColors;

    Z z;
    double elapsedSecs;
    Color color;

    z = Z.Last_3rd_of_Night;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Last_3rd_of_Night]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdxForQuestRing[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Middle_of_Night;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Middle_of_Night]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdxForQuestRing[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Isha;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Isha]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdxForQuestRing[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Maghrib;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Maghrib]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Ghurub]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdxForQuestRing[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Asr;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Asr]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdxForQuestRing[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Dhuhr;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Dhuhr]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdxForQuestRing[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Duha;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Istiwa]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Duha]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Ishraq]!.elapsedSecs;
    elapsedSecs += colorSlices[Z.Shuruq]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdxForQuestRing[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    z = Z.Fajr;
    elapsedSecs = 0;
    elapsedSecs += colorSlices[Z.Fajr]!.elapsedSecs;
    color = AppThemes.ajrColorsByIdxForQuestRing[questRingColors[z]!];
    questRingSlices[z] = ColorSlice(elapsedSecs, color);

    return questRingSlices;
  }

  @override
  Widget build(BuildContext context) {
    final Map<Z, ColorSlice> questRingSlices = _buildQuestRingSlices();

    return Center(
      child: Directionality(
        textDirection: TextDirection.ltr, // needed, or ring is off center
        child: SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            children: [
              // RepaintBoundary prevents ALWAYS repainting on ANY page update
              RepaintBoundary(
                child: CustomPaint(
                  painter:
                      MultiColorRing(questRingSlices, diameter, strokeWidth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
