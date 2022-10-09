import 'package:flutter/material.dart';

const String TR_KEY_OLDEST = 'Big Bang';

/// This files data used to be in timeline.json.
class TimelineData {
  const TimelineData({
    required this.tkTitle,
    required this.asset,
    this.tkEra,
    this.start,
    this.end,
    this.startMenu,
    this.endMenu,
    this.date,
    this.accent,
    this.timelineColors,
  });
  final String tkTitle;
  final Asset asset;
  final String? tkEra;
  final double? start;
  final double? end;
  final double? startMenu;
  final double? endMenu;
  final double? date;
  final Color? accent;
  final TimelineColors? timelineColors;
}

class TimelineColors {
  const TimelineColors({
    required this.background,
    required this.ticks,
    required this.header,
  });
  final Color background;
  final TickColors2 ticks;
  final HeaderColors2 header;
}

class TickColors2 {
  const TickColors2({
    required this.background,
    required this.long,
    required this.short,
    required this.text,
  });
  final Color background;
  final Color long;
  final Color short;
  final Color text;
}

class HeaderColors2 {
  const HeaderColors2({required this.background, required this.text});
  final Color background;
  final Color text;
}

class Asset {
  const Asset({
    required this.source,
    required this.width,
    required this.height,
    this.loop = true,
    this.tHorizontalOffset = 0.0,
    this.gap = 0.0,
    this.scale = 1.0,
    this.bounds,
    this.intro,
    this.idle,
  });
  final String source;
  final double width;
  final double height;
  final bool loop;
  final double tHorizontalOffset;
  final double gap;
  final double scale;
  final List<double>? bounds;
  final String? intro;
  final dynamic idle; // can be null, String or list
}

List<TimelineData> getTimelineData() {
  return const [
    TimelineData(
      date: -13800000000,
      tkTitle: TR_KEY_OLDEST,
      asset: Asset(
        source: 'tarikh/flare/Big_Bang.flr',
        width: 3628,
        height: 3620,
        tHorizontalOffset: 1500,
        gap: -1000,
        loop: false,
        bounds: [-1814, -1810, 1814, 1810],
      ),
      tkEra: 'Universe Begins',
      startMenu: -16000000000, // custom timeline locations navigated from menu
      endMenu: -11000000000,
      accent: Color.fromARGB(0xFF, 246, 76, 130),
      timelineColors: TimelineColors(
        background: Color.fromARGB(0xFF, 0, 38, 75),
        ticks: TickColors2(
          background: Color.fromARGB(20, 57, 92, 240),
          long: Color.fromARGB(255, 255, 255, 75),
          short: Color.fromARGB(255, 255, 255, 51),
          text: Color.fromARGB(255, 255, 255, 157),
        ),
        header: HeaderColors2(
          background: Color.fromARGB(11, 47, 81, 94),
          text: Color.fromARGB(255, 255, 255, 157),
        ),
      ),
    ),
    TimelineData(
      date: -13000000000,
      tkTitle: 'Milky Way is Born',
      asset: Asset(
        source: 'tarikh/flare/Milky Way.flr',
        width: 1293,
        height: 1210,
        scale: 0.5,
        bounds: [-1616.5, -115.0, -323.5, 1095.0],
      ),
      tkEra: 'Universe Begins',
    ),
    TimelineData(
      date: -4600000000,
      tkTitle: 'Sun is Born',
      asset: Asset(
        source: 'tarikh/flare/Sun.flr',
        width: 800,
        height: 800,
        tHorizontalOffset: -100,
        intro: 'Sun_in',
        idle: 'Sun_idle',
        bounds: [-400.0, -400.0, 400.0, 400.0],
      ),
      tkEra: 'Universe Begins',
      accent: Color.fromARGB(0xFF, 255, 166, 20),
    ),
    TimelineData(
      date: -4505000000,
      tkTitle: 'Earth is Born',
      asset: Asset(
        source: 'tarikh/flare/HeavyBombardment.flr',
        width: 1210,
        height: 1210,
        scale: 0.25,
        idle: 'Earth_is_born',
        bounds: [-581, -633, 629, 577],
      ),
      tkEra: 'Early Earth',
    ),
    TimelineData(
      date: -4100000000,
      tkTitle: 'Heavy Bombardment',
      asset: Asset(
        source: 'tarikh/flare/HeavyBombardment.flr',
        width: 1210,
        height: 1210,
        scale: 0.25,
        tHorizontalOffset: 1000,
        idle: 'Bombardmnet', // Note: typo is needed
        bounds: [-598.0, -2075.5, 3176, 599.5],
      ),
      accent: Color.fromARGB(0xFF, 255, 63, 0),
      tkEra: 'Early Earth',
    ),
    TimelineData(
      date: -4000000000,
      tkTitle: 'Life on Earth',
      asset: Asset(
        source: 'tarikh/flare/HeavyBombardment.flr',
        width: 1210,
        height: 1210,
        intro: 'Transformation',
        idle: 'Life on Earth',
        scale: 0.5,
        tHorizontalOffset: 500,
        bounds: [-581, -633, 629, 577],
      ),
      tkEra: 'Early Earth',
      timelineColors: TimelineColors(
        background: Color.fromARGB(0xFF, 31, 89, 143),
        ticks: TickColors2(
          background: Color.fromARGB(27, 79, 128, 240),
          long: Color.fromARGB(255, 255, 255, 75),
          short: Color.fromARGB(255, 255, 255, 51),
          text: Color.fromARGB(255, 255, 255, 157),
        ),
        header: HeaderColors2(
          background: Color.fromARGB(27, 79, 128, 240),
          text: Color.fromARGB(255, 255, 255, 157),
        ),
      ),
    ),
    TimelineData(
      date: -3800000000,
      tkTitle: 'Single Celled Organisms',
      asset: Asset(
        source: 'tarikh/nima/Cells.nma',
        width: 800,
        height: 400,
      ),
      tkEra: 'Early Earth',
    ),
    TimelineData(
      date: -600000000,
      tkTitle: 'Animals',
      asset: Asset(
        source: 'tarikh/flare/Animals.flr',
        width: 814,
        height: 564,
        tHorizontalOffset: -100,
        bounds: [0.0, 0.0, 814.0, 664.0],
      ),
      tkEra: 'Life on Earth',
      accent: Color.fromARGB(55, 134, 222, 255),
      timelineColors: TimelineColors(
        background: Color.fromARGB(0xFF, 132, 175, 214),
        ticks: TickColors2(
          background: Color.fromARGB(113, 152, 188, 240),
          long: Color.fromARGB(255, 255, 255, 75),
          short: Color.fromARGB(255, 255, 255, 51),
          text: Color.fromARGB(255, 255, 255, 157),
        ),
        header: HeaderColors2(
          background: Color.fromARGB(113, 152, 188, 240),
          text: Color.fromARGB(255, 255, 255, 157),
        ),
      ),
    ),
    TimelineData(
      date: -530000000,
      tkTitle: 'Fish',
      asset: Asset(
        source: 'tarikh/nima/Fish_and_Stuff.nma',
        width: 1290,
        height: 650,
        scale: 0.65,
        bounds: [-549, -5, 741, 645],
      ),
      tkEra: 'Life on Earth',
      accent: Color.fromARGB(0xFF, 55, 134, 222),
    ),
    TimelineData(
      date: -396000000,
      tkTitle: 'Insects',
      asset: Asset(
        source: 'tarikh/nima/Insects.nma',
        width: 800,
        height: 528,
      ),
      tkEra: 'Life on Earth',
      accent: Color.fromARGB(0xFF, 55, 134, 222),
    ),
    TimelineData(
      date: -312000000,
      tkTitle: 'Reptiles',
      asset: Asset(
        source: 'tarikh/nima/Reptiles.nma',
        width: 400,
        height: 600,
        tHorizontalOffset: -300,
      ),
      tkEra: 'Life on Earth',
      accent: Color.fromARGB(0xFF, 55, 134, 222),
    ),
    TimelineData(
      start: -230000000,
      end: -65000000,
      tkTitle: 'Dinosaur Age',
      asset: Asset(
        source: 'tarikh/flare/Dinosaurs.flr',
        width: 800,
        height: 570,
        tHorizontalOffset: 0,
        gap: 0,
      ),
      tkEra: 'Prehistoric Times',
    ),
    TimelineData(
      date: -200000000,
      tkTitle: 'Mammals',
      asset: Asset(
        source: 'tarikh/nima/Mammals.nma',
        tHorizontalOffset: -200,
        width: 400,
        height: 400,
      ),
      tkEra: 'Prehistoric Times',
    ),
    TimelineData(
      date: -150000000,
      tkTitle: 'Stegosaurus',
      asset: Asset(
        source: 'tarikh/nima/Dinosaurs.nma',
        width: 800,
        height: 570,
        tHorizontalOffset: -200,
        gap: 0,
      ),
      tkEra: 'Prehistoric Times',
      accent: Color.fromARGB(0xFF, 235, 155, 75),
    ),
    TimelineData(
      date: -68000000,
      tkTitle: 'Tyrannosaurus',
      asset: Asset(
        source: 'tarikh/flare/Trex.flr',
        width: 800,
        height: 570,
        tHorizontalOffset: -200,
      ),
      tkEra: 'Prehistoric Times',
      accent: Color.fromARGB(0xFF, 235, 155, 75),
    ),
    TimelineData(
      date: -65000001,
      tkTitle: 'Dinosaur Extinction',
      asset: Asset(
        source: 'tarikh/nima/Dinosaur_Demise.nma',
        width: 700,
        height: 500,
        tHorizontalOffset: -100,
      ),
      tkEra: 'Prehistoric Times',
      accent: Color.fromARGB(0xFF, 235, 155, 75),
    ),
    TimelineData(
      date: -6000000,
      tkTitle: 'Primate Bipedalism',
      asset: Asset(
        source: 'tarikh/nima/Apes.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -40,
      ),
      tkEra: 'Intelligent Life',
      accent: Color.fromARGB(0xFF, 202, 79, 63),
    ),
    TimelineData(
      date: -3300000,
      tkTitle: 'Constructed Tools',
      asset: Asset(
        source: 'tarikh/nima/Constructive_Tools.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -40,
      ),
      tkEra: 'Intelligent Life',
      timelineColors: TimelineColors(
        background: Color.fromARGB(0xFF, 255, 255, 255),
        ticks: TickColors2(
          background: Color.fromARGB(255, 211, 211, 204),
          long: Color.fromARGB(0xFF, 0, 0, 60),
          short: Color.fromARGB(0xFF, 0, 0, 35),
          text: Color.fromARGB(0xFF, 0, 0, 110),
        ),
        header: HeaderColors2(
          background: Color.fromARGB(245, 245, 245, 240),
          text: Color.fromARGB(0xFF, 0, 0, 110),
        ),
      ),
    ),
    TimelineData(
      date: -300000,
      tkTitle: 'Control Fire',
      asset: Asset(
        source: 'tarikh/nima/Fire.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -50,
      ),
      tkEra: 'Intelligent Life',
    ),
    TimelineData(
      date: -12000,
      tkTitle: 'First Temple',
      asset: Asset(
        source: 'tarikh/nima/First_Temple.nma',
        width: 340,
        height: 340,
        tHorizontalOffset: -200,
      ),
      tkEra: 'Ancient Archaeology',
    ),
    TimelineData(
      date: -10000,
      tkTitle: 'Agricultural Revolution',
      asset: Asset(
        source: 'tarikh/nima/Agricultural_evolution.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -40,
        loop: false,
      ),
    ),
    TimelineData(
      date: -5000,
      tkTitle: 'Writing',
      asset: Asset(
        source: 'tarikh/nima/Writing.nma',
        width: 900,
        height: 1200,
        scale: 0.5,
        tHorizontalOffset: -40,
        bounds: [-459, 4, 441, 1204],
      ),
      tkEra: 'Ancient Archaeology',
    ),
    TimelineData(
      date: -3500,
      tkTitle: 'Recorded History',
      asset: Asset(
        source: 'tarikh/nima/Recorded_history.nma',
        width: 400,
        height: 400,
        tHorizontalOffset: -200,
      ),
      tkEra: 'Ancient Archaeology',
    ),
    TimelineData(
      date: -2630,
      tkTitle: 'First Pyramid Built',
      asset: Asset(
        source: 'tarikh/nima/Pyramid.nma',
        width: 400,
        height: 430,
        tHorizontalOffset: -350,
      ),
      tkEra: 'Ancient Egypt',
    ),
    TimelineData(
      date: -27, // TODO need empire length here
      tkTitle: 'Roman Empire',
      asset: Asset(
        source: 'tarikh/nima/Roma.nma',
        width: 2100,
        height: 1375,
        scale: 0.5,
        tHorizontalOffset: 0,
        bounds: [-1030, -7.5, 1070, 1367.5],
      ),
      tkEra: 'Romans',
    ),
    TimelineData(
      start: 1095,
      end: 1291,
      tkTitle: 'Crusades',
      accent: Color.fromARGB(0xFF, 227, 21, 55),
      asset: Asset(
        source: 'tarikh/nima/Crusades.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -60,
      ),
    ),
    TimelineData(
      start: 1347,
      end: 1351,
      tkTitle: 'Black Plague',
      asset: Asset(
        source: 'tarikh/nima/BlackPlague.nma',
        width: 800,
        height: 400,
      ),
    ),
    TimelineData(
      date: 1453,
      tkTitle: 'Constantinople Istanbul',
      asset: Asset(
        source: 'tarikh/nima/Constantinople.nma',
        width: 500,
        height: 500,
      ),
    ),
    TimelineData(
      date: 1687,
      tkTitle: 'Newton and Gravity',
      asset: Asset(
        source: 'tarikh/nima/Newton_v2.nma',
        width: 500,
        height: 500,
        idle: 'apple_falls',
      ),
    ),
    TimelineData(
      date: 1760,
      tkTitle: 'Industrialization',
      asset: Asset(
        source: 'tarikh/nima/Industrialization.nma',
        width: 500,
        height: 500,
        tHorizontalOffset: -100,
      ),
    ),
    TimelineData(
      date: 1859,
      tkTitle: "Darwin's Theory of Evolution",
      asset: Asset(
        source: 'tarikh/nima/Darwin 2.nma',
        width: 1850,
        height: 2100,
        scale: 0.22,
        tHorizontalOffset: 0,
        bounds: [-934, -859, 916, 1241],
      ),
    ),
    TimelineData(
      start: 1914,
      end: 1918,
      tkTitle: 'World War 1',
      asset: Asset(
        source: 'tarikh/nima/World_War_I.nma',
        width: 528,
        height: 528,
      ),
      accent: Color.fromARGB(0xFF, 227, 21, 55),
    ),
    TimelineData(
      start: 1939,
      end: 1945,
      tkTitle: 'World War 2',
      asset: Asset(
        source: 'tarikh/nima/World_War_II.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -140,
      ),
      accent: Color.fromARGB(0xFF, 227, 21, 55),
    ),
    TimelineData(
      start: 1947,
      end: 1991,
      tkTitle: 'Cold War',
      asset: Asset(
        source: 'tarikh/nima/Cold_war.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -80,
      ),
      accent: Color.fromARGB(0xFF, 227, 21, 55),
    ),
    TimelineData(
      date: 1969,
      tkTitle: 'Moon Landing',
      asset: Asset(
        source: 'tarikh/nima/Moon.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -100,
      ),
      accent: Color.fromARGB(0xFF, 115, 132, 205),
    ),
    TimelineData(
      date: 1990,
      tkTitle: 'World Wide Web',
      asset: Asset(
        source: 'tarikh/nima/Internet.nma',
        width: 528,
        height: 528,
        tHorizontalOffset: -140,
      ),
      accent: Color.fromARGB(0xFF, 115, 132, 205),
    ),
  ];
}
