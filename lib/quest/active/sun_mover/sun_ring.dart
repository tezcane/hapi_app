import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/components/half_filled_icon.dart';
import 'package:hapi/helpers/math_utils.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/z.dart';
import 'package:hapi/quest/active/sun_mover/multi_color_ring.dart';
import 'package:hapi/quest/active/zaman_controller.dart';

// class SunMoverUI extends StatelessWidget {
//   const SunMoverUI(this.athan, this.diameter);
//
//   final Athan athan;
//   final double diameter;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         CircleDayView(athan, diameter, ),
//         //const SizedBox(height: 15),
//         //_PastNowFutureButtonPanel(today)
//         //SizedBox(height: 100),
//       ],
//     );
//   }
// }
//
// class _PastNowFutureButtonPanel extends StatelessWidget {
//   const _PastNowFutureButtonPanel(this.today);
//
//   final DateTime today;
//
//   @override
//   Widget build(BuildContext context) {}
// }

class SunRing extends StatelessWidget {
  const SunRing(
    this.athan,
    this.diameter,
    this.strokeWidth,
    this.colorSlices,
  );

  final Athan athan;
  final double diameter;
  final double strokeWidth;
  final Map<Z, ColorSlice> colorSlices;

  final int secondsInADay = 86400; //60 * 60 * 24;

  // TODO remove
  String fill(String s, int fillLen) {
    while (s.length < fillLen) {
      s += ' ';
    }
    return s;
  }

  void _buildSunRingSlices() {
    double totalSecs = 0.0;
    int lastIdx = Z.values.length - 2; // don't go to FajrTomorrow
    for (var zIdx = lastIdx; zIdx >= 0; zIdx--) {
      Z currZ = Z.values[zIdx];
      Z nextZ = Z.values[zIdx + 1];

      List<Object> currZValues = athan.getZamanTime(currZ);
      DateTime currZTime = currZValues[0] as DateTime;
      Color currZColor = currZValues[1] as Color;

      List<Object> nextZValues = athan.getZamanTime(nextZ);
      DateTime nextZTime = nextZValues[0] as DateTime;

      double elapsedSecs =
          nextZTime.difference(currZTime).inMilliseconds / 1000;
      totalSecs += elapsedSecs;
      colorSlices[currZ] = ColorSlice(elapsedSecs, currZColor);
      l.d('${fill(currZ.niceName(shortenAsrName: false), 10)} secs=$elapsedSecs (mins=${elapsedSecs / 60}), totalSecs=$totalSecs (mins=${totalSecs / 60})');
    }
    ColorSlice.setTotalSecs(totalSecs);

    // calculate high noon degree offset so we align SunMover circle around it
    DateTime currZTime = athan.getZamanTime(Z.Fajr)[0] as DateTime;
    DateTime nextZTime = athan.highNoon;
    double elapsedSecs = nextZTime.difference(currZTime).inMilliseconds / 1000;
    // high noon/Sun zenith is constant at very top of circle (25%=quarter turn)
    double noonDegreeCorrection =
        365 * ((elapsedSecs / ColorSlice.totalSecs) - .25);
    double noonRadianCorrection = degreesToRadians(noonDegreeCorrection);
    ColorSlice.setNoonRadianCorrection(noonRadianCorrection);
  }

  @override
  Widget build(BuildContext context) {
    _buildSunRingSlices();

    double secsOff = secondsInADay - ColorSlice.totalSecs;
    l.d('totalSecs=${ColorSlice.totalSecs} of 86400, $secsOff secs off (mins=${secsOff / 60})');

    // get offset where fajr is so we can rotate sun from correct spot
    double fajrStartPercentCorrection = ColorSlice.noonRadianCorrection / 365;
    //l.d('noonDegreeCorrection=$noonDegreeCorrection, noonCorrection=$noonCorrection, fajrStartCorrection=$fajrStartCorrection');

    // calculate sunrise on the horizon, so we can set horizon right for gumbi and me
    DateTime currZTime = athan.getZamanTime(Z.Fajr)[0] as DateTime;
    DateTime nextZTime = athan.sunrise;
    double elapsedSecs = nextZTime.difference(currZTime).inMilliseconds / 1000;

    // Sunrise is constant at very right of circle, (no turn)
    double sunrisePercentCorrection =
        (((elapsedSecs / ColorSlice.totalSecs) / 365) -
                fajrStartPercentCorrection) /
            2;
    double sunriseCorrection = .5 - sunrisePercentCorrection;
    //double sunriseCorrection = 2 * degreeCorrection * math.pi;

    //l.d('sunriseDegreeCorrection=$sunriseDegreeCorrection, fajrStartCorrection=$fajrStartCorrection->sunriseCorrection=$sunriseCorrection');

    bool isSunAboveHorizon = ZamanController.to.currZ.isAboveHorizon();

    // RepaintBoundary prevents the ALWAYS repaint on ANY page update
    return Center(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: Stack(
          children: [
            // RepaintBoundary needed or it will repaint on every second tick
            Positioned(
              top: 11.125,
              left: 11.125,
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: MultiColorRing(
                      colorSlices, diameter - 22.25, strokeWidth),
                ),
              ),
            ),
            if (isSunAboveHorizon)
              Positioned(
                top: -2.5,
                left: -2.5,
                child: TwoColoredIcon(
                  Icons.circle,
                  diameter + 5,
                  const [Colors.orangeAccent, Colors.red, Colors.transparent],
                  Colors.green,
                  fillPercent: sunriseCorrection,
                ),
              ),
            if (isSunAboveHorizon) const _GumbiAndMeWithFamily(Colors.white),
            GetBuilder<ZamanController>(
              builder: (c) {
                double sunValue = (c.secsSinceFajr / ColorSlice.totalSecs) -
                    fajrStartPercentCorrection;
                l.v('sunValue percent $sunValue = (${c.secsSinceFajr}/${ColorSlice.totalSecs}) - (fajrStartPercentCorrection=$fajrStartPercentCorrection)');
                if (sunValue > 0) {
                  // it's passed fajr time:
                  sunValue = 1 - sunValue; // 1 - to go backward;
                  l.v('1 - sunValue = $sunValue');
                } else {
                  // it's fajr time, so negative number and must take abs of it:
                  sunValue = sunValue.abs();
                  l.v('sunValue.abs = $sunValue');
                }

                return Center(
                  child: CustomPaint(
                    painter: SunMovePainter(
                      context: context,
                      sunValue: sunValue,
                      diameter: diameter - 22.25 - strokeWidth,
                      strokeWidth: strokeWidth,
                    ),
                  ),
                );
              },
            ),
            if (!isSunAboveHorizon)
              Positioned(
                top: -2.5,
                left: -2.5,
                child: TwoColoredIcon(
                  Icons.circle,
                  diameter + 5,
                  const [Colors.orangeAccent, Colors.red, Colors.transparent],
                  Colors.green,
                  fillPercent: sunriseCorrection,
                ),
              ),
            if (!isSunAboveHorizon) const _GumbiAndMeWithFamily(Colors.white),
          ],
        ),
      ),
    );
  }
}

class _GumbiAndMeWithFamily extends StatelessWidget {
  const _GumbiAndMeWithFamily(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          // dad, kid and mom in middle
          left: -17,
          bottom: 0,
          child: Align(
            alignment: Alignment.center,
            child: Transform.scale(
              scaleX: 1,
              scaleY: .98,
              child:
                  Icon(Icons.family_restroom_outlined, size: 45, color: color),
            ),
          ),
        ),
        Positioned.fill(
          // mom and kid on right
          left: 25.6,
          bottom: 0,
          child: Align(
            alignment: Alignment.center,
            child: Transform.scale(
              scaleX: .9,
              scaleY: 1,
              child: Icon(Icons.escalator_warning_outlined,
                  size: 49, color: color),
            ),
          ),
        ),
        Positioned.fill(
          // dad and kid on left
          left: 53,
          bottom: 10.60,
          child: Align(
            alignment: Alignment.center,
            child: Transform(
              alignment: Alignment.bottomLeft,
              transform: Matrix4.rotationY(math.pi),
              child: Icon(Icons.escalator_warning_outlined,
                  size: 60, color: color),
            ),
          ),
        ),
        Positioned.fill(
          // baby car
          left: 82,
          top: 15,
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.child_friendly_rounded, size: 33, color: color),
          ),
        ),
        Positioned.fill(
          // Mom's dress
          left: 14,
          top: 17,
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.warning_sharp, size: 19, color: color),
          ),
        ),
        Positioned.fill(
          // Edi's dress
          left: 44.5,
          top: 17,
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.warning_sharp, size: 17, color: color),
          ),
        ),
        Positioned.fill(
          // Cimi's dress
          left: -15,
          top: 20.5,
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.warning_sharp, size: 14, color: color),
          ),
        ),
        Positioned.fill(
          // Gumbi's head
          left: 75,
          top: 5,
          child: Align(
            alignment: Alignment.center,
            child: Icon(Icons.circle, size: 5.8, color: color),
          ),
        ),
      ],
    );
  }
}

class SunMovePainter extends CustomPainter {
  SunMovePainter({
    required this.context,
    required this.sunValue,
    required this.diameter,
    required this.strokeWidth,
  });

  final BuildContext context;
  final double sunValue, diameter, strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // draw big sun
    drawAxis(
      sunValue,
      canvas,
      (diameter / 2) - 1,
      Paint()..color = Colors.yellowAccent,
      strokeWidth - 1,
    );
    // draw tiny nub on sun's edge to show actual spot of sun easier
    drawAxis(
      sunValue,
      canvas,
      (diameter / 2) + strokeWidth - 2,
      Paint()..color = Colors.yellow,
      1,
    );
  }

  drawAxis(
      double value, Canvas canvas, double radius, Paint paint, double sunSize) {
    var firstAxis = getCirclePath(radius);
    PathMetrics pathMetrics = firstAxis.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      Path extractPath = pathMetric.extractPath(0.0, pathMetric.length * value);
      try {
        var metric = extractPath.computeMetrics().first;
        final offset = metric.getTangentForOffset(metric.length)!.position;
        canvas.drawCircle(offset, sunSize, paint);
      } catch (e) {
        l.w('AtomPaint.drawAxis caught e: $e');
      }
    }
  }

  Path getCirclePath(double radius) => Path()
    ..addOval(Rect.fromCircle(center: const Offset(0, 0), radius: radius));

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true; // leave as true
}

/*
class DrawGradientCircle extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(colors: [
        Colors.blue,
        Colors.black,
      ]).createShader(
          Rect.fromCircle(center: const Offset(0.0, 0.0), radius: 50));
    canvas.drawCircle(const Offset(0.0, 0.0), 50, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
*/

/*
class Circles extends StatefulWidget {
  @override
  _CirclesState createState() => _CirclesState();
}

class _CirclesState extends State<Circles> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double circles = 5.0;
  bool showDots = false, showPath = true;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h(context) / 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, snapshot) {
                      return Center(
                        child: CustomPaint(
                          painter: CirclesPainter(
                            circles,
                            _controller.value,
                            showDots,
                            showPath,
                          ),
                        ),
                      );
                    }),
              ),
              Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 0.0),
                    child: Text('Show Dots'),
                  ),
                  Switch(
                    value: showDots,
                    onChanged: (value) {
                      setState(() {
                        showDots = value;
                      });
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 0.0),
                    child: Text('Show Path'),
                  ),
                  Switch(
                    value: showPath,
                    onChanged: (value) {
                      setState(() {
                        showPath = value;
                      });
                    },
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Circles'),
              ),
              Slider(
                value: circles,
                min: 1.0,
                max: 10.0,
                divisions: 9,
                label: circles.toInt().toString(),
                onChanged: (value) {
                  setState(() {
                    circles = value;
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Progress'),
              ),
              Slider(
                value: _controller.value,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  setState(() {
                    _controller.value = value;
                  });
                },
              ),
              Center(
                child: RaisedButton(
                  child: const Text('Animate'),
                  onPressed: () {
                    _controller.reset();
                    _controller.forward();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CirclesPainter extends CustomPainter {
  CirclesPainter(this.circles, this.progress, this.showDots, this.showPath);

  final double circles, progress;
  bool showDots, showPath;

  var myPaint = Paint()
    ..color = Colors.purple
    ..style = PaintingStyle.stroke
    ..strokeWidth = 5.0;

  double radius = 80;

  @override
  void paint(Canvas canvas, Size size) {
    var path = createPath();
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      Path extractPath = pathMetric.extractPath(
        0.0,
        pathMetric.length * progress,
      );
      if (showPath) {
        canvas.drawPath(extractPath, myPaint);
      }
      if (showDots) {
        try {
          var metric = extractPath.computeMetrics().first;
          final offset = metric.getTangentForOffset(metric.length)!.position;
          canvas.drawCircle(offset, 8.0, Paint());
        } catch (e) {}
      }
    }
  }

  Path createPath() {
    var path = Path();
    int n = circles.toInt();
    var range = List<int>.generate(n, (i) => i + 1);
    double angle = 2 * math.pi / n;
    for (int i in range) {
      double x = radius * math.cos(i * angle);
      double y = radius * math.sin(i * angle);
      path.addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));
    }
    return path;
  }

  @override
  bool shouldRepaint(CirclesPainter oldDelegate) {
    return true;
  }
}
*/

/*
class Spiral extends StatefulWidget {
  @override
  _SpiralState createState() => _SpiralState();
}

class _SpiralState extends State<Spiral> with SingleTickerProviderStateMixin {
  bool showDots = false, showPath = true;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  l.v('${_controller.value}');
                  return Expanded(
                    child: Center(
                      child: CustomPaint(
                        painter: SpiralPainter(
                          _controller.value,
                          showPath,
                          showDots,
                        ),
                      ),
                    ),
                  );
                },
              ),
              Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 0.0),
                    child: Text('Show Dots'),
                  ),
                  Switch(
                    value: showDots,
                    onChanged: (value) {
                      setState(() {
                        showDots = value;
                      });
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 24.0, right: 0.0),
                    child: Text('Show Path'),
                  ),
                  Switch(
                    value: showPath,
                    onChanged: (value) {
                      setState(() {
                        showPath = value;
                      });
                    },
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 24.0),
                child: Text('Progress'),
              ),
              Slider(
                value: _controller.value,
                min: 0.0,
                max: 1.0,
                onChanged: (value) {
                  setState(() {
                    _controller.value = value;
                  });
                },
              ),
              Center(
                child: RaisedButton(
                  onPressed: () {
                    _controller.reset();
                    _controller.forward();
                  },
                  child: Text('Animate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SpiralPainter extends CustomPainter {
  SpiralPainter(this.progress, this.showPath, this.showDots);

  final double progress;
  bool showDots, showPath;

  final Paint _paint = Paint()
    ..color = Colors.deepPurple
    ..strokeWidth = 4.0
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    Path path = createSpiralPath(size);
    PathMetric pathMetric = path.computeMetrics().first;
    Path extractPath =
        pathMetric.extractPath(0.0, pathMetric.length * progress);
    if (showPath) {
      canvas.drawPath(extractPath, _paint);
    }
    if (showDots) {
      try {
        var metric = extractPath.computeMetrics().first;
        final offset = metric.getTangentForOffset(metric.length)!.position;
        canvas.drawCircle(offset, 8.0, Paint());
      } catch (e) {}
    }
  }

  Path createSpiralPath(Size size) {
    double radius = 0, angle = 0;
    Path path = Path();
    for (int n = 0; n < 200; n++) {
      radius += 0.75;
      angle += (math.pi * 2) / 50;
      var x = size.width / 2 + radius * math.cos(angle);
      var y = size.height / 2 + radius * math.sin(angle);
      path.lineTo(x, y);
    }
    return path;
  }

  // Path createSpiralPath(Size size) {
  //   double radius = 0, angle = 0;
  //   Path path = Path();
  //   for (int n = 0; n < 365; n++) {
  //     radius += 0.10;
  //     angle += (math.pi * 2) / 50;
  //     var x = size.width / 2 + radius * math.cos(angle);
  //     var y = size.height / 2 + radius * math.sin(angle);
  //     path.lineTo(x, y);
  //   }
  //   return path;
  // }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
*/

/*
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: TweenAnimationBuilder(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (BuildContext context, dynamic value, Widget? child) {
            return CustomPaint(
              painter: OpenPainter(
                  totalQuestions: 300,
                  learned: 75,
                  notLearned: 75,
                  range: value),
            );
          },
        ),
      ),
    );
  }
}

class OpenPainter extends CustomPainter {
  final learned;
  final notLearned;
  final range;
  final totalQuestions;
  double pi = math.pi;

  OpenPainter({this.learned, this.totalQuestions, this.notLearned, this.range});
  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 7;
    Rect myRect = const Offset(-50.0, -50.0) & const Size(100.0, 100.0);

    var paint1 = Paint()
      ..color = Colors.red
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    var paint2 = Paint()
      ..color = Colors.green
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    var paint3 = Paint()
      ..color = Colors.yellow
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    double firstLineRadianStart = 0;
    double _unAnswered =
        (totalQuestions - notLearned - learned) * range / totalQuestions;
    double firstLineRadianEnd = (360 * _unAnswered) * math.pi / 180;
    canvas.drawArc(
        myRect, firstLineRadianStart, firstLineRadianEnd, false, paint1);

    double _learned = (learned) * range / totalQuestions;
    double secondLineRadianEnd = getRadians(_learned);
    canvas.drawArc(
        myRect, firstLineRadianEnd, secondLineRadianEnd, false, paint2);
    double _notLearned = (notLearned) * range / totalQuestions;
    double thirdLineRadianEnd = getRadians(_notLearned);
    canvas.drawArc(myRect, firstLineRadianEnd + secondLineRadianEnd,
        thirdLineRadianEnd, false, paint3);

    //drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter, Paint paint)
  }

  double getRadians(double value) {
    return (360 * value) * pi / 180;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

 */
