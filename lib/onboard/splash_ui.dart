import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:get/get.dart';
import 'package:hapi/onboard/auth/auth_controller.dart';

// NOTE YOU CAN SKIP THIS WITH isFastStartupMode in MenuController:
const int kGifAnimationMs = 1501; // time it takes to play animated gif
const int kSplashShowTimeMs = 3001; // time to show splash screen
const int kLoadingBarShowMs = 5001; // loading bar won't show until after this
const int kLoadingBarUpdateMs = 201; // time used to grow/shrink the loading bar

/// contains the initial loading screen.
/// splash page gets popped off navigator once app init done in auth controller
class SplashUI extends StatefulWidget {
  @override
  _SplashUIState createState() => _SplashUIState();
}

class _SplashUIState extends State<SplashUI> with TickerProviderStateMixin {
  _SplashUIState();

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
    cGif = GifController(vsync: this); // do fast for dipose()

    stopwatch.start();

    // handle logo gif playback stuff
    int gifIndex = Random().nextInt(gifs.length);
    double gifFrames = gifs[gifIndex][0].toDouble();
    gifFilename = gifs[gifIndex][1];

    setupAnimationPlayAndWaitTimer(gifFrames);

    updateLoadingMsg(kLoadingBarShowMs, true);

    super.initState();
  }

  void setupAnimationPlayAndWaitTimer(double gifFrames) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // controller1repeat(min: 0, max: 30, period: Duration(milliseconds: 2000)); // how to repeat
      cGif.animateTo(gifFrames,
          duration: const Duration(milliseconds: kGifAnimationMs));
      Timer(const Duration(milliseconds: kGifAnimationMs + 81),
          () => AuthController.to.setGifAnimatingDone());
    });
  }

  @override
  void dispose() {
    stopwatch.stop();
    cGif.dispose(); // needed for fast startup mode

    // Loading is complete so stop timers
    if (_loadingBarTimer != null && _loadingBarTimer!.isActive) {
      _loadingBarTimer!.cancel();
    }

    super.dispose();
  }

  // After updateTimeMs time, refresh the loading bar.
  // TODO use Loading() progress bar instead?
  void updateLoadingMsg(int updateTimeMs, bool isBarGrowing) {
    if (AuthController.to.isSplashScreenDone()) {
      _loadingBar = ''; // hide loading bar so hero/init navigation is cleaner
      return;
    }

    _loadingBarTimer = Timer(
      Duration(milliseconds: updateTimeMs),
      () => setState(() {
        if (_loadingBar.isEmpty) {
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

        // show next loading animation/text update
        updateLoadingMsg(kLoadingBarUpdateMs, isBarGrowing);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: GetBuilder<AuthController>(
          builder: (c) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20),
              if (!c.isGifAnimatingDone())
                GifImage(
                  controller: cGif,
                  image: AssetImage('assets/images/logo/gif/$gifFilename.gif'),
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
              const SizedBox(height: 20),
              const Text(
                'بِسْمِ ٱللَّٰهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                style: TextStyle(fontSize: 15.0),
              ),
              const SizedBox(height: 20),
              const Text(
                'ٱلسَّلَامُ عَلَيْكُمْ وَرَحْمَةُ ٱللَّٰ وَبَرَكَاتُهُ',
                style: TextStyle(fontSize: 15.0),
              ),
              const SizedBox(height: 20),
              Text(
                _loadingBar,
                style: const TextStyle(fontSize: 30.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
