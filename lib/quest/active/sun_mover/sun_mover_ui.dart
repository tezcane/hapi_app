import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
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

  final int secondsInADay = 86400; //60 * 60 * 24;

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
    List<Object> currZValues = athan.getZamanTime(Z.Fajr);
    DateTime currZTime = currZValues[0] as DateTime;
    DateTime nextZTime = athan.highNoon;
    double elapsedSecs = nextZTime.difference(currZTime).inMilliseconds / 1000;
    // high noon/Sun zenith is constant at top of circle, at 25%/quarter turn
    double degreeCorrection = 365 * ((elapsedSecs / totalSecs) - .25);
    double radianCorrection = degreesToRadians(degreeCorrection);

    return MultipleColorCircle(colorOccurrences, diameter, radianCorrection);
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

class GumbiAndMe extends StatefulWidget {
  const GumbiAndMe(this.diameter);

  final double diameter;

  @override
  _GumbiAndMeState createState() => _GumbiAndMeState();
}

class _GumbiAndMeState extends State<GumbiAndMe> with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _controller2 =
        AnimationController(vsync: this, duration: const Duration(seconds: 5));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller1,
              builder: (context, snapshot) {
                return Center(
                  child: CustomPaint(
                    painter: AtomPaint(
                      context: context,
                      //value: _controller.value,
                      moon: _controller1.value,
                      sun: _controller2.value,
                      diameter: widget.diameter,
                    ),
                  ),
                );
              },
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: widget.diameter - 58, // top arc
                    height: (widget.diameter - 58) / 2, // half of a circle
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                      ),
                    ),
                  ),
                  Container(
                    width: widget.diameter - 58, // bottom arc
                    height: (widget.diameter - 58) / 2, // half of a circle
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(100),
                        bottomRight: Radius.circular(100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Center(
              child: Icon(Icons.escalator_warning_rounded, size: 50),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.play_arrow),
          onPressed: () {
            _controller1.reset();
            _controller2.reset();
            // _controller1.forward();
            // _controller2.forward();
            _controller1.reverse(from: 1.0);
            _controller2.reverse(from: 1.0);
          },
        ),
      ),
    );
  }
}

class AtomPaint extends CustomPainter {
  AtomPaint({
    required this.context,
    required this.moon,
    required this.sun,
    required this.diameter,
  }) {
    _sunAxisPaint = Paint()
      ..color = ct(context)
      ..strokeWidth = 0.001
      ..style = PaintingStyle.stroke;
    _moonAxisPaint = Paint()
      ..color = ct(context)
      ..strokeWidth = 0.001
      ..style = PaintingStyle.stroke;
  }

  final BuildContext context;
  final double moon, sun, diameter;

  late final Paint _sunAxisPaint;
  late final Paint _moonAxisPaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(const Offset(0, 0), (diameter / 2) - 31,
        Paint()..color = Colors.blueAccent);

    drawAxis(_sunAxisPaint, sun, canvas, (diameter / 2) + 30,
        Paint()..color = Colors.yellow);
    drawAxis(_moonAxisPaint, moon, canvas, (diameter / 2) - 30,
        Paint()..color = Colors.grey.shade500);
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
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class MultipleColorCircle extends StatelessWidget {
  const MultipleColorCircle(
    this.colorOccurrences,
    this.diameter,
    this.radianCorrection,
  );

  final Map<Color, double> colorOccurrences;
  final double diameter, radianCorrection;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: diameter,
        width: diameter,
        child: CustomPaint(
          size: const Size(20, 20),
          child: GumbiAndMe(diameter),
          painter: _MultipleColorCirclePainter(
            colorOccurrences,
            diameter,
            radianCorrection,
          ),
        ),
      ),
    );
  }
}

class _MultipleColorCirclePainter extends CustomPainter {
  _MultipleColorCirclePainter(
    this.colorOccurrences,
    this.diameter,
    this.radianCorrection,
  );

  final Map<Color, double> colorOccurrences;
  final double diameter, radianCorrection;
  double pi = math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 60; // TODO asdf pass this around
    double radius = diameter / 2;
    Rect myRect =
        Rect.fromCircle(center: Offset(radius, radius), radius: radius);

    double radianStart = radianCorrection; // used to be 0
    double radianLength = 0;
    double allOccurrences = 0;
    //set denominator
    colorOccurrences.forEach((color, occurrence) {
      allOccurrences += occurrence;
    });
    l.d('_MultipleColorCirclePainter: allOccurrences=$allOccurrences');
    colorOccurrences.forEach((color, occurrence) {
      double percent = occurrence / allOccurrences;
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
