import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hapi/components/half_filled_icon.dart';
import 'package:hapi/helpers/math_utils.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/athan/z.dart';

class SunMoverUI extends StatelessWidget {
  const SunMoverUI(this.athan, this.diameter);

  final Athan athan;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CircleDayView(athan, diameter),
        //const SizedBox(height: 15),
        //_PastNowFutureButtonPanel(today)
        //SizedBox(height: 100),
      ],
    );
  }
}

class CircleDayView extends StatelessWidget {
  const CircleDayView(this.athan, this.diameter);

  final Athan athan;
  final double diameter;

  final double strokeWidth = 30;
  final int secondsInADay = 86400; //60 * 60 * 24;

  // TODO remove
  String fill(String s, int fillLen) {
    while (s.length < fillLen) {
      s += ' ';
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    // c.timeToNextZaman

    Map<Color, double> colorOccurrences = {};

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
      colorOccurrences[currZColor] = elapsedSecs;
      totalSecs += elapsedSecs;
      l.d('${fill(currZ.niceName, 10)} secs=$elapsedSecs (mins=${elapsedSecs / 60}), totalSecs=$totalSecs (mins=${totalSecs / 60})');
    }
    double secsOff = secondsInADay - totalSecs;
    l.d('totalSecs=$totalSecs of 86400, $secsOff secs off (mins=${secsOff / 60})');

    // calculate high noon degree offset so we align SunMover circle around it
    DateTime currZTime = athan.getZamanTime(Z.Fajr)[0] as DateTime;
    DateTime nextZTime = athan.highNoon;
    double elapsedSecs = nextZTime.difference(currZTime).inMilliseconds / 1000;
    // high noon/Sun zenith is constant at very top of circle (25%=quarter turn)
    double degreeCorrection = 365 * ((elapsedSecs / totalSecs) - .25);
    double noonCorrection = degreesToRadians(degreeCorrection);

    // calculate sunrise on the horizon
    currZTime = athan.getZamanTime(Z.Fajr)[0] as DateTime;
    nextZTime = athan.sunrise;
    elapsedSecs = nextZTime.difference(currZTime).inMilliseconds / 1000;
    // Sunrise is constant at very right of circle, (no turn)
    degreeCorrection = 365 * (elapsedSecs / totalSecs);
    //degreeCorrection = elapsedSecs / totalSecs;
    //double sunriseCorrection = degreeCorrection / 2; // TODO check
    double sunriseCorrection = (.5 - degreesToRadians(degreeCorrection)) / 2;
    l.d('degreeCorrection=$degreeCorrection->sunriseCorrection=$sunriseCorrection');

    // RepaintBoundary prevents the ALWAYS repaint on ANY page update
    return RepaintBoundary(
      child: MultipleColorCircle(
        diameter,
        strokeWidth,
        colorOccurrences,
        totalSecs,
        noonCorrection,
        sunriseCorrection,
      ),
    );
  }
}

// class _PastNowFutureButtonPanel extends StatelessWidget {
//   const _PastNowFutureButtonPanel(this.today);
//
//   final DateTime today;
//
//   @override
//   Widget build(BuildContext context) {}
// }

class GumbiAndMeWithFamily extends StatelessWidget {
  const GumbiAndMeWithFamily(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        // dad, kid and mom in middle
        left: -17,
        bottom: 0,
        child: Align(
          alignment: Alignment.center,
          child: Transform.scale(
            scaleX: 1,
            scaleY: .98,
            child: Icon(Icons.family_restroom_outlined, size: 45, color: color),
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
            child:
                Icon(Icons.escalator_warning_outlined, size: 49, color: color),
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
            child:
                Icon(Icons.escalator_warning_outlined, size: 60, color: color),
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
    ]);
  }
}

class GumbiAndMe extends StatefulWidget {
  const GumbiAndMe(this.diameter, this.strokeWidth, this.sunriseCorrection);

  final double diameter, strokeWidth, sunriseCorrection;

  @override
  _GumbiAndMeState createState() => _GumbiAndMeState();
}

class _GumbiAndMeState extends State<GumbiAndMe> with TickerProviderStateMixin {
  late final AnimationController _sunController;

  @override
  void initState() {
    super.initState();
    _sunController =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Center(
              child: TwoColoredIcon(
                Icons.circle,
                widget.diameter,
                const [Colors.orangeAccent, Colors.red, Colors.transparent],
                Colors.green,
                fillPercent: .5 + widget.sunriseCorrection,
              ),
            ),
            const GumbiAndMeWithFamily(Colors.white),
            AnimatedBuilder(
              animation: _sunController,
              builder: (context, snapshot) {
                return Center(
                  child: CustomPaint(
                    painter: AtomPaint(
                      context: context,
                      //value: _sunController.value,
                      sun: _sunController.value,
                      diameter: widget.diameter,
                      strokeWidth: widget.strokeWidth,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.play_arrow),
          onPressed: () {
            _sunController.reset();
            // _controller2.forward();
            _sunController.reverse(from: 1.0);
          },
        ),
      ),
    );
  }
}

class AtomPaint extends CustomPainter {
  AtomPaint({
    required this.context,
    required this.sun,
    required this.diameter,
    required this.strokeWidth,
  }) {
    _sunAxisPaint = Paint()
      ..color = ct(context)
      ..strokeWidth = .5
      ..style = PaintingStyle.stroke;
  }

  final BuildContext context;
  final double sun, diameter, strokeWidth;

  late final Paint _sunAxisPaint;

  @override
  void paint(Canvas canvas, Size size) {
    drawAxis(
      _sunAxisPaint,
      sun,
      canvas,
      (diameter / 2) - (strokeWidth / 2),
      Paint()..color = Colors.yellow,
    );
  }

  drawAxis(
      Paint axis, double value, Canvas canvas, double radius, Paint paint) {
    var firstAxis = getCirclePath(radius);
    canvas.drawPath(firstAxis, axis);
    PathMetrics pathMetrics = firstAxis.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      Path extractPath = pathMetric.extractPath(0.0, pathMetric.length * value);
      try {
        var metric = extractPath.computeMetrics().first;
        final offset = metric.getTangentForOffset(metric.length)!.position;
        canvas.drawCircle(offset, 12.0, paint);
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

class MultipleColorCircle extends StatelessWidget {
  const MultipleColorCircle(
    this.diameter,
    this.strokeWidth,
    this.colorOccurrences,
    this.totalSecs,
    this.noonCorrection,
    this.sunriseCorrection,
  );

  final double diameter, strokeWidth;
  final Map<Color, double> colorOccurrences;
  final double totalSecs, noonCorrection, sunriseCorrection;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: diameter,
        width: diameter,
        child: CustomPaint(
          size: const Size(20, 20),
          // prevent other painting when this is updating
          child: RepaintBoundary(
            child: GumbiAndMe(diameter, strokeWidth, sunriseCorrection),
          ),
          painter: _MultipleColorCirclePainter(
            colorOccurrences,
            totalSecs,
            diameter,
            noonCorrection,
            strokeWidth,
          ),
        ),
      ),
    );
  }
}

class _MultipleColorCirclePainter extends CustomPainter {
  const _MultipleColorCirclePainter(
    this.colorOccurrences,
    this.totalSecs,
    this.diameter,
    this.noonCorrection,
    this.strokeWidth,
  );

  final Map<Color, double> colorOccurrences;
  final double totalSecs, diameter, noonCorrection;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    double radius = diameter / 2;
    Rect myRect =
        Rect.fromCircle(center: Offset(radius, radius), radius: radius);

    double radianStart = noonCorrection; // used to be 0
    double radianLength = 0;

    l.d('_MultipleColorCirclePainter: allOccurrences=$totalSecs');
    colorOccurrences.forEach((color, occurrence) {
      double percent = occurrence / totalSecs;
      radianLength = 2 * percent * math.pi;
      canvas.drawArc(
          myRect,
          radianStart,
          radianLength,
          false,
          Paint()
            ..color = color
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke);
      radianStart += radianLength;
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

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
