import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:get/get.dart';
import 'package:hapi/controllers/auth_controller.dart';

const int kGifAnimationMs = 1801; //1350; // TODO tune
const int kSplashShowTimeMs = 4001; //2350;
const int kLoadingBarShowMs = 3001; // bar will not show up until this time
const int kLoadingBarUpdateMs = 201; // time used to grow/shrink the loading bar

/// splash page gets popped off navigator once app init done in auth controller
class SplashUI extends StatefulWidget {
  @override
  _SplashUIState createState() => _SplashUIState();
}

class _SplashUIState extends State<SplashUI> with TickerProviderStateMixin {
  _SplashUIState();
  final AuthController c = Get.find();

  late GifController cGif;
  late String gifFilename;
  List<List> gifs = [
    [20, 'block'], // TODO cycle through them via cached value instead of random
    [30, 'fade'],
    [30, 'pan'],
    [36, 'photo_flow'],
    [36, 'photo_rise'],
    [37, 'photo_zoom'],
    [30, 'rise'],
    [28, 'tumble']
  ];

  // Track data loading and splash screen display times.
  Stopwatch stopwatch = Stopwatch();
  String _loadingBar = ''; // will show in UI if app fails to load fast enough
  Timer? _loadingBarTimer;

  @override
  void initState() {
    stopwatch.start();

    // handle logo gif playback stuff
    int gifIndex = Random().nextInt(gifs.length);
    double gifFrames = gifs[gifIndex][0].toDouble();
    gifFilename = gifs[gifIndex][1];
    cGif = GifController(vsync: this);

    setupAnimationPlayAndWaitTimer(gifFrames);

    updateLoadingMsg(kLoadingBarShowMs, true);

    super.initState();
  }

  void setupAnimationPlayAndWaitTimer(double gifFrames) {
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      // controller1repeat(min: 0, max: 30, period: Duration(milliseconds: 2000)); // how to repeat
      Stopwatch animationTime = Stopwatch();
      animationTime.start();
      cGif.animateTo(gifFrames,
          duration: Duration(milliseconds: kGifAnimationMs));
      animationTime.stop();

      Timer(Duration(milliseconds: kGifAnimationMs),
          () => c.setGifAnimatingDone());
    });
  }

  @override
  void dispose() {
    stopwatch.stop();

    // Loading is complete so stop timers
    if (_loadingBarTimer != null && _loadingBarTimer!.isActive) {
      _loadingBarTimer!.cancel();
    }

    super.dispose();
  }

  // After updateTimeMs time, refresh the loading bar.
  void updateLoadingMsg(int updateTimeMs, bool isBarGrowing) {
    _loadingBarTimer = Timer(
      Duration(milliseconds: updateTimeMs),
      () => setState(() {
        if (_loadingBar.length == 0) {
          isBarGrowing = true; // bar is blank, start growing again
          _loadingBar = '_';
        } else if (_loadingBar.length == 1) {
          if (isBarGrowing) {
            _loadingBar = '__';
          } else {
            _loadingBar = '';
          }
        } else if (_loadingBar.length == 2) {
          if (isBarGrowing) {
            _loadingBar = '___';
          } else {
            _loadingBar = '_';
          }
        } else if (_loadingBar.length == 3) {
          isBarGrowing = false; // hit end, shrink back down now
          _loadingBar = '__';
        }

        updateLoadingMsg(kLoadingBarUpdateMs, isBarGrowing);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: GetBuilder<AuthController>(
          builder: (c) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (!c.isGifAnimatingDone())
                  GifImage(
                    controller: cGif,
                    image:
                        AssetImage("assets/images/logo/gif/$gifFilename.gif"),
                    width: 250,
                    height: 250,
                  ),
                if (c.isGifAnimatingDone())
                  Hero(
                    tag: 'hapiLogo',
                    child: Image.asset(
                      'assets/images/logo/logo.png',
                      width: 250,
                      height: 250,
                    ),
                  ),
                if (!c.isSplashScreenDone())
                  Text(
                    _loadingBar,
                    style: TextStyle(fontSize: 40.0),
                  ),
              ]),
        ),
      ),
    );
  }
}
