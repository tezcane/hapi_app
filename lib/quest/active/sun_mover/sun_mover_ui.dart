import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/time_controller.dart';
import 'package:hapi/main_controller.dart';
import 'package:hapi/quest/active/athan/athan.dart';
import 'package:hapi/quest/active/zaman_controller.dart';

class SunMoverUI extends StatelessWidget {
  //SunMoverUI(this.today);

  final DateTime today = TimeController.to.now2();
  final Athan athan = ZamanController.to.athan!;

  @override
  Widget build(BuildContext context) {
    final double height = h(context);

    return SizedBox(
      height: height,
      child: Column(
        children: [
          _CircleDayView(today, athan),
          //const SizedBox(height: 10),
          //_PastNowFutureButtonPanel(today)
        ],
      ),
    );
  }
}

class _CircleDayView extends StatelessWidget {
  const _CircleDayView(this.today, this.athan);

  final DateTime today;
  final Athan athan;

  final int secondsInADay = 86400; //60 * 60 * 24;

  @override
  Widget build(BuildContext context) {
    // c.timeToNextZaman

    return GetBuilder<ZamanController>(builder: (c) {
      return Planets();
      //return Circles();
      //return Spiral();
    });
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

class Planets extends StatefulWidget {
  @override
  _PlanetsState createState() => _PlanetsState();
}

class _PlanetsState extends State<Planets> with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _controller2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = h(context);
    return SizedBox(
      height: height / 2, // needed
      child: Scaffold(
        backgroundColor: cb(context),
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
                    ),
                  ),
                );
              },
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 140,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                      ),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 70,
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
              child: Icon(
                Icons.escalator_warning_rounded,
                size: 50,
              ),
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
  final double moon, sun;

  late final Paint _sunAxisPaint;
  late final Paint _moonAxisPaint;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
        const Offset(0, 0), 72.0, Paint()..color = Colors.blueAccent);

    drawAxis(_sunAxisPaint, sun, canvas, 138, Paint()..color = Colors.yellow);
    drawAxis(_moonAxisPaint, moon, canvas, 105,
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
      } catch (e) {}
    }
  }

  Path getCirclePath(double radius) => Path()
    ..addOval(Rect.fromCircle(center: const Offset(0, 0), radius: radius));

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
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
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h(context) / 2,
      child: Scaffold(
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
                  child: Text('Animate'),
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
      duration: Duration(seconds: 5),
    );
    _controller.value = 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: h(context) / 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  print('${_controller.value}');
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
                  constPadding(
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
