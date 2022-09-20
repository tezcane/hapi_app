import 'package:flutter/material.dart';

const String TR_KEY_OLDEST = 'i.Big Bang';

/// This files data used to be in timeline.json.
class TimelineData {
  const TimelineData({
    required this.trKeyTitle,
    required this.asset,
    this.start,
    this.end,
    this.date,
    this.actorId,
    this.accent,
    this.timelineColors,
  });
  final String trKeyTitle;
  final Asset asset;
  final double? start;
  final double? end;
  final double? date;
  final String? actorId;
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
    this.offset = 0.0,
    this.gap = 0.0,
    this.bounds,
    this.scale = 1.0,
    this.intro,
    this.idle,
  });
  final String source;
  final double width;
  final double height;
  final bool loop;
  final double offset;
  final double gap;
  final double scale;
  final List<double>? bounds;
  final String? intro;
  final dynamic idle; // can be null, String or list
}

List<TimelineData> getTimelineData() {
  List<TimelineData> rv = [];
  rv.addAll([
    const TimelineData(
      date: -13800000000,
      trKeyTitle: TR_KEY_OLDEST,
      accent: Color.fromARGB(0xFF, 246, 76, 130),
      timelineColors: TimelineColors(
        background: Color.fromARGB(255, 0, 38, 75),
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
      asset: Asset(
        source: 'tarikh/flare/Big_Bang.flr',
        width: 3628,
        height: 3620,
        offset: 1500,
        gap: -1000,
        loop: false,
        bounds: [-1814, -1810, 1814, 1810],
      ),
    ),
    const TimelineData(
      date: -13000000000,
      trKeyTitle: 'i.Milky Way is Born',
      actorId: 'milky',
      asset: Asset(
        source: 'tarikh/flare/Milky Way.flr',
        width: 1293,
        height: 1210,
        scale: 0.5,
        bounds: [-1616.5, -115.0, -323.5, 1095.0],
      ),
    ),
    const TimelineData(
      date: -4600000000,
      trKeyTitle: 'i.Sun is Born',
      accent: Color.fromARGB(0xFF, 255, 166, 20),
      asset: Asset(
        source: 'tarikh/flare/Sun.flr',
        width: 800,
        height: 800,
        offset: -100,
        intro: 'Sun_in',
        idle: 'Sun_idle',
        bounds: [-400.0, -400.0, 400.0, 400.0],
      ),
    ),
    const TimelineData(
      date: -4505000000,
      trKeyTitle: 'i.Earth is Born',
      asset: Asset(
        source: 'tarikh/flare/HeavyBombardment.flr',
        width: 1210,
        height: 1210,
        scale: 0.25,
        idle: 'Earth_is_born',
        bounds: [-581, -633, 629, 577],
      ),
    ),
    const TimelineData(
      date: -4100000000,
      trKeyTitle: 'i.Heavy Bombardment',
      accent: Color.fromARGB(0xFF, 255, 63, 0),
      asset: Asset(
        source: 'tarikh/flare/HeavyBombardment.flr',
        width: 1210,
        height: 1210,
        scale: 0.25,
        idle: 'Bombardmnet',
        bounds: [-598.0, -2075.5, 3176, 599.5],
      ),
    ),
    const TimelineData(
      start: -4000000000,
      trKeyTitle: 'i.Life on Earth',
      timelineColors: TimelineColors(
        background: Color.fromARGB(255, 31, 89, 143),
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
      asset: Asset(
        source: 'tarikh/flare/HeavyBombardment.flr',
        width: 1210,
        height: 1210,
        intro: 'Transformation',
        idle: 'Life on Earth',
        scale: 0.5,
        offset: 500,
        bounds: [-581, -633, 629, 577],
      ),
    ),
    const TimelineData(
      date: -3800000000,
      trKeyTitle: 'i.Single Celled Organisms',
      asset: Asset(
        source: 'tarikh/nima/Cells.nma',
        width: 800,
        height: 400,
      ),
    ),
    const TimelineData(
      start: -600000000,
      trKeyTitle: 'i.Animals',
      asset: Asset(
        source: 'tarikh/flare/Animals.flr',
        width: 814,
        height: 564,
        offset: -100,
        bounds: [0.0, 0.0, 814.0, 664.0],
      ),
      accent: Color.fromARGB(0xFF, 55, 134, 222),
      timelineColors: TimelineColors(
        background: Color.fromARGB(255, 132, 175, 214),
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
    const TimelineData(
      date: -530000000,
      trKeyTitle: 'i.Fish',
      actorId: 'fish',
      accent: Color.fromARGB(0xFF, 55, 134, 222),
      asset: Asset(
        source: 'tarikh/nima/Fish_and_Stuff.nma',
        width: 1290,
        height: 650,
        scale: 0.65,
        bounds: [-549, -5, 741, 645],
      ),
    ),
    const TimelineData(
      date: -396000000,
      trKeyTitle: 'i.Insects',
      accent: Color.fromARGB(0xFF, 55, 134, 222),
      asset: Asset(
        source: 'tarikh/nima/Insects.nma',
        width: 800,
        height: 528,
      ),
    ),
    const TimelineData(
      date: -312000000,
      trKeyTitle: 'i.Reptiles',
      accent: Color.fromARGB(0xFF, 55, 134, 222),
      asset: Asset(
        source: 'tarikh/nima/Reptiles.nma',
        width: 400,
        height: 600,
      ),
    ),
    const TimelineData(
      start: -230000000,
      end: -65000000,
      trKeyTitle: 'i.Dinosaur Age',
      actorId: 'dinosaur',
      asset: Asset(
        source: 'tarikh/flare/Dinosaurs.flr',
        width: 800,
        height: 570,
        offset: 0,
        gap: 0,
      ),
    ),
    const TimelineData(
      date: -200000000,
      trKeyTitle: 'i.Mammals',
      actorId: 'mammal',
      asset: Asset(
        source: 'tarikh/nima/Mammals.nma',
        offset: -200,
        width: 400,
        height: 400,
      ),
    ),
    const TimelineData(
      date: -150000000,
      trKeyTitle: 'i.Stegosaurus',
      accent: Color.fromARGB(0xFF, 235, 155, 75),
      asset: Asset(
        source: 'tarikh/nima/Dinosaurs.nma',
        width: 800,
        height: 570,
        offset: -200,
        gap: 0,
      ),
    ),
    const TimelineData(
      date: -68000000,
      trKeyTitle: 'i.Tyrannosaurus',
      accent: Color.fromARGB(0xFF, 235, 155, 75),
      asset: Asset(
        source: 'tarikh/flare/Trex.flr',
        width: 800,
        height: 570,
        offset: -200,
      ),
    ),
    const TimelineData(
      date: -65000001,
      trKeyTitle: 'i.Dinosaur Extinction',
      accent: Color.fromARGB(0xFF, 235, 155, 75),
      asset: Asset(
        source: 'tarikh/nima/Dinosaur_Demise.nma',
        width: 700,
        height: 500,
        offset: -100,
      ),
    ),
    const TimelineData(
      date: -6000000,
      trKeyTitle: 'i.Primate Bipedalism',
      accent: Color.fromARGB(0xFF, 202, 79, 63),
      asset: Asset(
        source: 'tarikh/nima/Apes.nma',
        width: 528,
        height: 528,
        offset: -40,
      ),
    ),
    const TimelineData(
      start: -3400000,
      trKeyTitle: 'a.Adam',
      timelineColors: TimelineColors(
        background: Color.fromARGB(255, 255, 255, 255),
        ticks: TickColors2(
          background: Color.fromARGB(245, 245, 245, 240),
          long: Color.fromARGB(0, 0, 0, 60),
          short: Color.fromARGB(0, 0, 0, 35),
          text: Color.fromARGB(0, 0, 0, 110),
        ),
        header: HeaderColors2(
          background: Color.fromARGB(245, 245, 245, 240),
          text: Color.fromARGB(0, 0, 0, 110),
        ),
      ),
      asset: Asset(
        source: 'images/anbiya/Adam.png',
        width: 200,
        height: 200,
        offset: 0,
      ),
    ),
    const TimelineData(
      date: -3300000,
      trKeyTitle: 'i.Constructed Tools',
      asset: Asset(
        source: 'tarikh/nima/Constructive_Tools.nma',
        width: 528,
        height: 528,
        offset: -40,
      ),
    ),
    const TimelineData(
      date: -1500000,
      trKeyTitle: 'i.Control Fire',
      asset: Asset(
        source: 'tarikh/nima/Fire.nma',
        width: 528,
        height: 528,
        offset: -50,
      ),
    ),
    const TimelineData(
      date: -12000,
      trKeyTitle: 'i.First Temple',
      asset: Asset(
        source: 'tarikh/nima/First_Temple.nma',
        width: 340,
        height: 340,
        offset: -200,
      ),
    ),
    const TimelineData(
      date: -10000,
      trKeyTitle: 'i.Agricultural Revolution',
      asset: Asset(
        source: 'tarikh/nima/Agricultural_evolution.nma',
        width: 528,
        height: 528,
        offset: -40,
        loop: false,
      ),
    ),
    const TimelineData(
      date: -5000,
      trKeyTitle: 'i.Writing',
      asset: Asset(
        source: 'tarikh/nima/Writing.nma',
        width: 900,
        height: 1200,
        scale: 0.5,
        offset: -40,
        bounds: [-459, 4, 441, 1204],
      ),
    ),
    const TimelineData(
      start: -3500,
      trKeyTitle: 'i.Recorded History',
      asset: Asset(
        source: 'tarikh/nima/Recorded_history.nma',
        width: 400,
        height: 400,
        offset: -200,
      ),
    ),
    const TimelineData(
      date: -2630,
      trKeyTitle: 'i.First Pyramid Built',
      asset: Asset(
        source: 'tarikh/nima/Pyramid.nma',
        width: 400,
        height: 430,
        offset: -350,
      ),
    ),
    const TimelineData(
      date: -27,
      trKeyTitle: 'i.Roman Empire',
      asset: Asset(
        source: 'tarikh/nima/Roma.nma',
        width: 2100,
        height: 1375,
        scale: 0.5,
        offset: 0,
        bounds: [-1030, -7.5, 1070, 1367.5],
      ),
    ),
    const TimelineData(
      start: 1095,
      end: 1291,
      trKeyTitle: 'i.Crusades',
      accent: Color.fromARGB(0xFF, 227, 21, 55),
      asset: Asset(
        source: 'tarikh/nima/Crusades.nma',
        width: 528,
        height: 528,
        offset: -60,
      ),
    ),
    const TimelineData(
      start: 1347,
      end: 1351,
      trKeyTitle: 'i.Black Plague',
      asset: Asset(
        source: 'tarikh/nima/BlackPlague.nma',
        width: 800,
        height: 400,
      ),
    ),
    const TimelineData(
      date: 1453,
      trKeyTitle: 'i.Constantinople/Istanbul',
      asset: Asset(
        source: 'tarikh/nima/Constantinople.nma',
        width: 500,
        height: 500,
      ),
    ),
    const TimelineData(
      date: 1687,
      trKeyTitle: 'i.Newton and Gravity',
      asset: Asset(
        source: 'tarikh/nima/Newton_v2.nma',
        width: 500,
        height: 500,
        idle: 'apple_falls',
      ),
    ),
    const TimelineData(
      date: 1760,
      trKeyTitle: 'i.Industrialization',
      asset: Asset(
        source: 'tarikh/nima/Industrialization.nma',
        width: 500,
        height: 500,
        offset: -100,
      ),
    ),
    const TimelineData(
      date: 1859,
      trKeyTitle: "a.Darwin's\nTheory of Evolution",
      asset: Asset(
        source: 'tarikh/nima/Darwin 2.nma',
        width: 1850,
        height: 2100,
        scale: 0.22,
        offset: 0,
        bounds: [-934, -859, 916, 1241],
      ),
    ),
    const TimelineData(
      start: 1914,
      end: 1918,
      trKeyTitle: 'i.World War 1',
      accent: Color.fromARGB(0xFF, 227, 21, 55),
      asset: Asset(
        source: 'tarikh/nima/World_War_I.nma',
        width: 528,
        height: 528,
      ),
    ),
    const TimelineData(
      start: 1939,
      end: 1945,
      trKeyTitle: 'i.World War 2',
      accent: Color.fromARGB(0xFF, 227, 21, 55),
      asset: Asset(
        source: 'tarikh/nima/World_War_II.nma',
        width: 528,
        height: 528,
        offset: -140,
      ),
    ),
    const TimelineData(
      start: 1947,
      end: 1991,
      trKeyTitle: 'i.Cold War',
      accent: Color.fromARGB(0xFF, 227, 21, 55),
      asset: Asset(
        source: 'tarikh/nima/Cold_war.nma',
        width: 528,
        height: 528,
        offset: -80,
      ),
    ),
    const TimelineData(
      date: 1969,
      trKeyTitle: 'i.Moon Landing',
      accent: Color.fromARGB(0xFF, 115, 132, 205),
      asset: Asset(
        source: 'tarikh/nima/Moon.nma',
        width: 528,
        height: 528,
        offset: -100,
      ),
    ),
    const TimelineData(
      date: 1990,
      trKeyTitle: 'i.World Wide Web',
      accent: Color.fromARGB(0xFF, 115, 132, 205),
      asset: Asset(
        source: 'tarikh/nima/Internet.nma',
        width: 528,
        height: 528,
        offset: -140,
      ),
    ),
  ]);

  return rv;
}
